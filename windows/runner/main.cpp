#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <algorithm>
#include <memory>
#include <vector>

#include "flutter_window.h"
#include "utils.h"
#include "widget_window.h"

FlutterWindow* g_main_window = nullptr;
static std::vector<std::unique_ptr<WidgetWindow>> g_widget_windows;

bool HasActiveWidgets() {
  return !g_widget_windows.empty();
}

void NotifyWidgetClosed(WidgetWindow* window) {
  g_widget_windows.erase(
      std::remove_if(g_widget_windows.begin(), g_widget_windows.end(),
                     [window](const std::unique_ptr<WidgetWindow>& ptr) {
                       return ptr.get() == window;
                     }),
      g_widget_windows.end());

  if (g_main_window == nullptr && g_widget_windows.empty()) {
    PostQuitMessage(0);
  }
}

void CloseAllWidgetWindows() {
  for (auto& widgetWindow : g_widget_windows) {
    if (widgetWindow) {
      widgetWindow->Destroy();
    }
  }
  g_widget_windows.clear();
  if (g_main_window == nullptr) {
    PostQuitMessage(0);
  }
}

void RegisterDesktopWidgetChannel(flutter::FlutterEngine* engine) {
  if (!engine) return;

  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(),
      "com.f1app.apex/desktop_widgets",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "createRaceScheduleWidget" ||
            call.method_name() == "createClockWidget") {
          if (!g_widget_windows.empty()) {
            HWND existingHwnd = g_widget_windows.front()->GetHandle();
            if (existingHwnd && IsWindow(existingHwnd)) {
              SetWindowPos(existingHwnd, HWND_TOP, 0, 0, 0, 0,
                           SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
              result->Success(flutter::EncodableValue(true));
              return;
            }
            CloseAllWidgetWindows();
          }

          flutter::DartProject project(L"data");
          auto widgetWindow = std::make_unique<WidgetWindow>(project, "schedule");

          RECT workArea;
          SystemParametersInfo(SPI_GETWORKAREA, 0, &workArea, 0);

          int widgetWidth = 540;
          int widgetHeight = 245;
          int originX = workArea.right - widgetWidth - 40;
          int originY = workArea.top + 50;

          Win32Window::Point origin(originX, originY);
          Win32Window::Size size(widgetWidth, widgetHeight);

          if (widgetWindow->Create(L"Apex Race Widget", origin, size, true)) {
            widgetWindow->SetQuitOnClose(false);
            g_widget_windows.push_back(std::move(widgetWindow));
            result->Success(flutter::EncodableValue(true));
          } else {
            result->Error("CREATE_FAILED", "Failed to create widget window");
          }
        } else if (call.method_name() == "closeWidget" ||
                   call.method_name() == "closeClockWidget" ||
                   call.method_name() == "closeScheduleWidget") {
          CloseAllWidgetWindows();
          result->Success(flutter::EncodableValue(true));
        } else {
          result->NotImplemented();
        }
      });
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  g_main_window = &window;

  RECT workArea;
  SystemParametersInfo(SPI_GETWORKAREA, 0, &workArea, 0);

  int workWidth = workArea.right - workArea.left;
  int workHeight = workArea.bottom - workArea.top;

  int windowWidth = 440;
  int windowHeight = 780;

  int originX = workArea.left + (workWidth - windowWidth) / 2;
  int originY = workArea.top + (workHeight - windowHeight) / 2 - 30;

  if (originX < workArea.left) originX = workArea.left + 10;
  if (originY < workArea.top + 10) originY = workArea.top + 10;

  Win32Window::Point origin(originX, originY);
  Win32Window::Size size(windowWidth, windowHeight);
  if (!window.Create(L"Apex", origin, size)) {
    return EXIT_FAILURE;
  }

  RegisterDesktopWidgetChannel(window.GetEngine());
  window.SetQuitOnClose(false);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  g_main_window = nullptr;
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
