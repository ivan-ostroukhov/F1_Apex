import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../../schedule/domain/models/race_model.dart';
import '../presentation/widgets/race_schedule_glass_widget.dart';

class AndroidWidgetService {
  static const String appWidgetProviderName = 'RaceScheduleWidgetProvider';

  static Future<void> updateWidget({
    RaceModel? race,
    bool is24Hour = true,
  }) async {
    try {
      final imagePath = await HomeWidget.renderFlutterWidget(
        Material(
          color: Colors.transparent,
          child: RaceScheduleGlassWidget(
            race: race,
            is24Hour: is24Hour,
            width: 520,
          ),
        ),
        key: 'race_widget_image',
        logicalSize: const Size(520, 240),
      );

      if (imagePath.isNotEmpty) {
        await HomeWidget.saveWidgetData<String>('race_widget_image', imagePath);
        await HomeWidget.updateWidget(
          name: appWidgetProviderName,
          androidName: appWidgetProviderName,
        );
      }
    } catch (_) {}
  }

  static Future<bool> requestPinWidget() async {
    try {
      final isRequestPinSupported = await HomeWidget.isRequestPinWidgetSupported();
      if (isRequestPinSupported == true) {
        await HomeWidget.requestPinWidget(
          androidName: appWidgetProviderName,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
