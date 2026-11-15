#include "widget_window.h"

#include <dwmapi.h>
#include <optional>

#include "flutter/generated_plugin_registrant.h"

#pragma comment(lib, "dwmapi.lib")

extern void NotifyWidgetClosed(WidgetWindow* window);

WidgetWindow::WidgetWindow(const flutter::DartProject& project, const std::string& widgetType)
    : project_(project), widget_type_(widgetType) {
  std::vector<std::string> args = project_.dart_entrypoint_arguments();
  args.push_back("--widget-type=" + widgetType);
  project_.set_dart_entrypoint_arguments(args);
}

WidgetWindow::~WidgetWindow() {}

void WidgetWindow::ApplyRoundedCorners() {
  HWND hwnd = GetHandle();
  if (!hwnd) return;

  RECT rect;
  GetClientRect(hwnd, &rect);
  int width = rect.right - rect.left;
  int height = rect.bottom - rect.top;
  if (width <= 0 || height <= 0) return;

  UINT dpi = GetDpiForWindow(hwnd);
  if (dpi == 0) dpi = 96;
  float scale = static_cast<float>(dpi) / 96.0f;
  int diameter = static_cast<int>(48 * scale);

  HRGN rgn = CreateRoundRectRgn(0, 0, width + 1, height + 1, diameter, diameter);
  SetWindowRgn(hwnd, rgn, TRUE);

  HWND childHwnd = (flutter_controller_ && flutter_controller_->view())
                       ? flutter_controller_->view()->GetNativeWindow()
                       : nullptr;
  if (childHwnd) {
    HRGN childRgn = CreateRoundRectRgn(0, 0, width + 1, height + 1, diameter, diameter);
    SetWindowRgn(childHwnd, childRgn, TRUE);
  }
}

bool WidgetWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  HWND hwnd = GetHandle();

  LONG_PTR style = GetWindowLongPtr(hwnd, GWL_STYLE);
  style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
  style |= WS_POPUP | WS_VISIBLE;
  SetWindowLongPtr(hwnd, GWL_STYLE, style);

  LONG_PTR exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
  exStyle &= ~WS_EX_APPWINDOW;
  exStyle |= WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE;
  SetWindowLongPtr(hwnd, GWL_EXSTYLE, exStyle);

  MARGINS margins = {-1, -1, -1, -1};
  DwmExtendFrameIntoClientArea(hwnd, &margins);

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);

  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  auto setupHandler = [this, hwnd](const flutter::MethodCall<flutter::EncodableValue>& call,
                                   std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (call.method_name() == "closeWidget" ||
        call.method_name() == "closeClockWidget" ||
        call.method_name() == "closeScheduleWidget") {
      result->Success(flutter::EncodableValue(true));
      this->Destroy();
    } else if (call.method_name() == "startDragging") {
      ReleaseCapture();
      SendMessage(hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0);
      result->Success(flutter::EncodableValue(true));
    } else if (call.method_name() == "setAlwaysOnTop") {
      bool top = false;
      if (call.arguments() && std::holds_alternative<bool>(*call.arguments())) {
        top = std::get<bool>(*call.arguments());
      }
      SetWindowPos(hwnd, top ? HWND_TOPMOST : HWND_BOTTOM, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
      result->Success(flutter::EncodableValue(true));
    } else {
      result->NotImplemented();
    }
  };

  widget_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "com.f1app.apex/desktop_widgets",
      &flutter::StandardMethodCodec::GetInstance());
  widget_channel_->SetMethodCallHandler(setupHandler);

  legacy_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "f1_desktop_widget",
      &flutter::StandardMethodCodec::GetInstance());
  legacy_channel_->SetMethodCallHandler(setupHandler);

  flutter_controller_->engine()->SetNextFrameCallback([this, hwnd]() {
    this->Show();
    this->ApplyRoundedCorners();
    SetWindowPos(hwnd, HWND_BOTTOM, 0, 0, 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
  });

  flutter_controller_->ForceRedraw();
  return true;
}

void WidgetWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }
  Win32Window::OnDestroy();
}

LRESULT
WidgetWindow::MessageHandler(HWND hwnd, UINT const message,
                             WPARAM const wparam,
                             LPARAM const lparam) noexcept {
  if (message == WM_GETMINMAXINFO) {
    return 0;
  }

  if (message == WM_MOUSEACTIVATE) {
    return MA_NOACTIVATE;
  }

  if (message == WM_WINDOWPOSCHANGING) {
    auto pos = reinterpret_cast<WINDOWPOS*>(lparam);
    pos->hwndInsertAfter = HWND_BOTTOM;
  }

  if (message == WM_SIZE) {
    ApplyRoundedCorners();
  }

  if (message == WM_ACTIVATE && LOWORD(wparam) == WA_INACTIVE) {
    SetWindowPos(hwnd, HWND_BOTTOM, 0, 0, 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
  }

  if (message == WM_DESTROY) {
    NotifyWidgetClosed(this);
    return 0;
  }

  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
