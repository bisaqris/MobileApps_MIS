import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_data_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/manpower.dart';
import '../providers/manpower_providers.dart';
import '../widget/manpower_detail_sheet.dart';
import '../widget/manpower_form_sheet.dart';

class ManpowerListPage extends ConsumerWidget {
  const ManpowerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manpowerAsync = ref.watch(manpowerListProvider);
    final pad = context.pagePadding;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(manpowerListProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Manpower',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Daftar SDM & crew produksi beserta keahlian dan status ketersediaan.',
              style: TextStyle(color: AppColors.gray500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const _ManpowerToolbar(),
            const SizedBox(height: 16),
            manpowerAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat data manpower: $e'),
              ),
              data: (items) => ResponsiveDataView<Manpower>(
                items: items,
                columns: _buildColumns(context, ref),
                emptyMessage: 'Belum ada data manpower',
                onRowTap: (m) => ManpowerDetailSheet.show(
                  context,
                  manpower: m,
                  onEdit: () => ManpowerFormSheet.show(context, manpower: m),
                  onDelete: () => _confirmDelete(context, ref, m),
                ),
                footer: Text(
                  'Showing ${items.length} data out of ${items.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumnDef<Manpower>> _buildColumns(
    BuildContext context,
    WidgetRef ref,
  ) =>
      [
        DataColumnDef(
          label: 'Nama & Role',
          flex: 3,
          isTitle: true,
          cell: (_, m) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                m.role,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ],
          ),
        ),
        DataColumnDef(
          label: 'Keahlian / Skill',
          flex: 3,
          cell: (_, m) => m.skills.isEmpty
              ? const Text('-')
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: m.skills
                      .take(3)
                      .map(
                        (s) => StatusBadge(label: s, tone: BadgeTone.info),
                      )
                      .toList(),
                ),
        ),
        DataColumnDef(
          label: 'Kontak',
          flex: 3,
          cell: (_, m) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.phone, style: const TextStyle(fontSize: 13)),
              if (m.email != null && m.email!.isNotEmpty)
                Text(
                  m.email!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        DataColumnDef(
          label: 'Tipe',
          flex: 2,
          cell: (_, m) => Text(m.employmentStatus.label),
        ),
        DataColumnDef(
          label: 'Ketersediaan',
          flex: 2,
          cell: (_, m) => switch (m.availability) {
            ManpowerAvailability.available => const StatusBadge(
                label: 'Available',
                tone: BadgeTone.success,
              ),
            ManpowerAvailability.onProject => const StatusBadge(
                label: 'On Project',
                tone: BadgeTone.progress,
              ),
          },
        ),
        DataColumnDef(
          label: 'Action',
          flex: 2,
          isAction: true,
          cell: (context, m) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit Manpower',
                onPressed: () => ManpowerFormSheet.show(context, manpower: m),
                icon: const Icon(Iconsax.edit_2, size: 20),
                color: AppColors.gray500,
              ),
              IconButton(
                tooltip: 'Hapus Manpower',
                onPressed: () => _confirmDelete(context, ref, m),
                icon: const Icon(Iconsax.trash, size: 20),
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ];

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Manpower manpower,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Manpower'),
        content: Text('Yakin ingin menghapus data manpower "${manpower.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(manpowerControllerProvider.notifier)
          .deleteManpower(manpower.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Manpower "${manpower.name}" berhasil dihapus.'
                  : 'Gagal menghapus data manpower.',
            ),
          ),
        );
      }
    }
  }
}

class _ManpowerToolbar extends ConsumerWidget {
  const _ManpowerToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAvailability = ref.watch(manpowerAvailabilityFilterProvider);

    final searchField = TextField(
      onChanged: (v) => ref.read(manpowerSearchProvider.notifier).state = v,
      decoration: const InputDecoration(
        hintText: 'Cari nama, role, keahlian, atau kontak...',
        prefixIcon: Icon(Iconsax.search_normal, size: 18),
      ),
    );

    final addButton = FilledButton.icon(
      onPressed: () => ManpowerFormSheet.show(context),
      icon: const Icon(Iconsax.add, size: 18),
      label: const Text('Add Manpower'),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [searchField, const SizedBox(height: 12), addButton],
            )
          else
            Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                addButton,
              ],
            ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: selectedAvailability == null,
                  onSelected: () => ref
                      .read(manpowerAvailabilityFilterProvider.notifier)
                      .state = null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Available',
                  isSelected:
                      selectedAvailability == ManpowerAvailability.available,
                  onSelected: () => ref
                      .read(manpowerAvailabilityFilterProvider.notifier)
                      .state = ManpowerAvailability.available,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'On Project',
                  isSelected:
                      selectedAvailability == ManpowerAvailability.onProject,
                  onSelected: () => ref
                      .read(manpowerAvailabilityFilterProvider.notifier)
                      .state = ManpowerAvailability.onProject,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.primary50,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.gray600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.stroke,
      ),
    );
  }
}

