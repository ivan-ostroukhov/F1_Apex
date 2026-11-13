import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    cardColor: const Color(0xFFFFFFFF),
    dividerColor: const Color(0x1A000000),
    colorScheme: const ColorScheme.light(
      primary: AppColors.racingRed,
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF121212),
      surfaceContainerHighest: const Color(0xFFEBEBEF),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      indicatorColor: AppColors.racingRed.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.racingRed);
        }
        return const IconThemeData(color: Color(0xFF777777));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: AppColors.racingRed, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.normal, fontSize: 12);
      }),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000),
    cardColor: const Color(0xFF141416),
    dividerColor: const Color(0x14FFFFFF),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.racingRed,
      surface: AppColors.carbonBlack,
      onSurface: AppColors.pureWhite,
      surfaceContainerHighest: AppColors.asphaltGrey,
    ),
  );
}