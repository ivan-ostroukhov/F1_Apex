import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../network/local_storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';

  LocaleCubit() : super(_initialLocale());

  static Locale _initialLocale() {
    final saved = LocalStorageService.getString(_localeKey);
    if (saved == 'en') {
      return const Locale('en');
    }
    return const Locale('ru');
  }

  void toggleLocale() {
    final nextCode = state.languageCode == 'ru' ? 'en' : 'ru';
    setLocale(nextCode);
  }

  void setLocale(String languageCode) {
    final newCode = languageCode == 'en' ? 'en' : 'ru';
    LocalStorageService.setString(_localeKey, newCode);
    emit(Locale(newCode));
  }
}