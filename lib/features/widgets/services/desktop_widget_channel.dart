import 'package:flutter/services.dart';

class DesktopWidgetChannel {
  static const MethodChannel _channel = MethodChannel('com.f1app.apex/desktop_widgets');

  static Future<void> startDragging() async {
    try {
      await _channel.invokeMethod('startDragging');
    } catch (_) {}
  }

  static Future<void> closeWidget() async {
    try {
      await _channel.invokeMethod('closeWidget');
    } catch (_) {}
  }

  static Future<void> setAlwaysOnTop(bool top) async {
    try {
      await _channel.invokeMethod('setAlwaysOnTop', top);
    } catch (_) {}
  }
}
