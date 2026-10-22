import 'package:flutter/material.dart';

/// Palet diambil langsung dari file Figma "MIS" (halaman "Internal Only Canvas").
abstract final class AppColors {
  // Primary blue
  static const primary = Color(0xFF006AFF);      // primary blue/700
  static const primaryDark = Color(0xFF004BCA);
  static const primary200 = Color(0xFFB5E5FF);
  static const primary50 = Color(0xFFEDF9FF);
  static const navy = Color(0xFF000C7A);         // Primary color/1

  // Neutral
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF212121);
  static const heading = Color(0xFF191B24);
  static const textPrimary = Color(0xFF373737);
  static const textBody = Color(0xFF424656);
  static const textSecondary = Color(0xFF9CA3AF);
  static const stroke = Color(0xFFDFDEDE);
  static const strokeInput = Color(0xFFC2C6D9);
  static const cardFill = Color(0xFFFBFBFC);

  // Gray scale
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);

  // Semantic
  static const success = Color(0xFF12B76A);
  static const successLight = Color(0xFF36D183);
  static const successDark = Color(0xFF006C47);
  static const warning = Color(0xFFEAB308);      // yellow/500
  static const warningBg = Color(0xFFFEFCE8);    // yellow/50
  static const orange = Color(0xFFF97316);
  static const orangeBg = Color(0xFFFFF7ED);
  static const danger = Color(0xFFEF4444);       // warning red/500
  static const dangerLight = Color(0xFFFCA5A5);  // warning red/300
}
