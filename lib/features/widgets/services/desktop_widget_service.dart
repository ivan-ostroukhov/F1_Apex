import 'package:flutter/services.dart';

class DesktopWidgetService {
  static const MethodChannel _channel = MethodChannel('com.f1app.apex/desktop_widgets');

  static Future<bool> createRaceScheduleWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('createRaceScheduleWidget');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> createClockWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('createClockWidget');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> closeWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('closeWidget');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> closeClockWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('closeClockWidget');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> startDragging() async {
    try {
      await _channel.invokeMethod('startDragging');
    } catch (_) {}
  }

  static Future<void> setAlwaysOnTop(bool top) async {
    try {
      await _channel.invokeMethod('setAlwaysOnTop', top);
    } catch (_) {}
  }
}
