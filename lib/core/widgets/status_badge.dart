import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum BadgeTone { info, progress, warning, success, danger, neutral }

/// Pill status kecil (New, On progress, Pending, Approved, Revise, ...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BadgeTone.info => (AppColors.primary50, AppColors.primary),
      BadgeTone.progress => (AppColors.orangeBg, AppColors.orange),
      BadgeTone.warning => (AppColors.warningBg, AppColors.warning),
      BadgeTone.success => (const Color(0xFFE7F8F0), AppColors.successDark),
      BadgeTone.danger => (const Color(0xFFFEECEC), AppColors.danger),
      BadgeTone.neutral => (AppColors.gray100, AppColors.gray600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
