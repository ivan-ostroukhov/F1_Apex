import 'package:flutter/material.dart';
import 'common/network/local_storage_service.dart';
import 'features/widgets/presentation/view/desktop_widget_app.dart';
import 'app.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  if (args.any((arg) => arg.contains('widget-type=schedule') || arg.contains('widget-type=clock') || arg.contains('--widget'))) {
    runApp(const DesktopWidgetApp());
  } else {
    runApp(const F1App());
  }
}
