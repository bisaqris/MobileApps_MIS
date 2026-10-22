import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Skala tipografi dari Figma (Overused Grotesk: xs 12 · sm 14 · base 16 ·
/// lg 18 · xl 20 · 2xl 24 ...).
abstract final class AppTypography {
  /// Set true setelah font "OverusedGrotesk" di-bundle di pubspec.yaml.
  static const useBundledFont = false;
  static const bundledFamily = 'OverusedGrotesk';

  static TextTheme textTheme() {
    final base = _scale();
    return useBundledFont
        ? base.apply(fontFamily: bundledFamily)
        : GoogleFonts.interTextTheme(base);
  }

  static TextTheme _scale() => const TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.heading),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.heading),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.heading),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.heading),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textBody),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textBody),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.gray500),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      );
}
