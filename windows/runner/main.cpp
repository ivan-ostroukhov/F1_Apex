#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

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
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}