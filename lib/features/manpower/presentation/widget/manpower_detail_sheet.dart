import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/manpower.dart';

class ManpowerDetailSheet extends StatelessWidget {
  const ManpowerDetailSheet({
    super.key,
    required this.manpower,
    required this.onEdit,
    required this.onDelete,
  });

  final Manpower manpower;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Future<void> show(
    BuildContext context, {
    required Manpower manpower,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManpowerDetailSheet(
        manpower: manpower,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tone = manpower.availability == ManpowerAvailability.available
        ? BadgeTone.success
        : BadgeTone.progress;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manpower.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        manpower.role,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: manpower.availability.label, tone: tone),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _infoRow(Iconsax.call, 'No. Telepon', manpower.phone),
            _infoRow(
              Iconsax.sms,
              'Email',
              (manpower.email == null || manpower.email!.isEmpty)
                  ? '-'
                  : manpower.email!,
            ),
            _infoRow(
              Iconsax.personalcard,
              'Status Pekerjaan',
              manpower.employmentStatus.label,
            ),
            if (manpower.standardRate != null)
              _infoRow(
                Iconsax.money,
                'Standard Rate / Day',
                Formatters.rupiah(manpower.standardRate!),
              ),
            const SizedBox(height: 12),
            const Text(
              'Keahlian / Skills',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
            const SizedBox(height: 8),
            if (manpower.skills.isEmpty)
              const Text('-', style: TextStyle(fontSize: 14))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: manpower.skills
                    .map(
                      (s) => StatusBadge(label: s, tone: BadgeTone.info),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    icon: const Icon(
                      Iconsax.trash,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    icon: const Icon(Iconsax.edit_2, size: 18),
                    label: const Text('Edit Data'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.gray600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

