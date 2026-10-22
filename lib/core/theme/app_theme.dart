import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static const double radiusSm = 8;
  static const double radiusMd = 12;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.primaryDark,
      error: AppColors.danger,
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      outline: AppColors.stroke,
    );

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: c),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.gray50,
      textTheme: AppTypography.textTheme(),
      dividerColor: AppColors.stroke,
      dividerTheme: const DividerThemeData(color: AppColors.stroke, space: 1, thickness: 1),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: AppColors.stroke),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border(AppColors.strokeInput),
        enabledBorder: border(AppColors.strokeInput),
        focusedBorder: border(AppColors.primary),
        errorBorder: border(AppColors.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: AppColors.strokeInput),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.heading,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.white),
    );
  }
}
