import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../network/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit() : super(_initialTheme());

  static ThemeMode _initialTheme() {
    final saved = LocalStorageService.getString(_themeKey);
    if (saved == 'light') {
      return ThemeMode.light;
    }
    if (saved == 'system') {
      return ThemeMode.system;
    }
    return ThemeMode.dark;
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(nextMode);
  }

  void setTheme(ThemeMode mode) {
    String val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.system) val = 'system';
    LocalStorageService.setString(_themeKey, val);
    emit(mode);
  }
}