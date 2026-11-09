import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mis_app/core/responsive/breakpoints.dart';
import 'package:mis_app/core/theme/app_colors.dart';
import 'package:mis_app/core/utils/formatters.dart';
import 'package:mis_app/core/widgets/responsive_data_view.dart';
import 'package:mis_app/core/widgets/status_badge.dart';
import 'package:mis_app/features/approvals/domain/entities/approval_item.dart';
import 'package:mis_app/features/approvals/presentation/providers/approval_providers.dart';

class ApprovalListPage extends ConsumerWidget {
  const ApprovalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(approvalsProvider);
    final pad = context.pagePadding;

    return RefreshIndicator(
        onRefresh: () async => ref.refresh(approvalsProvider),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Production Cost Approvals',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                  'Daftar pengajuan biaya operasional & produksi yang menunggu persetujuan.',
                  style: TextStyle(color: AppColors.gray500, fontSize: 13)),
              const SizedBox(
                height: 16,
              ),
              const _ApprovalToolbar(),
              const SizedBox(
                height: 16,
              ),
              approvalsAsync.when(
                  loading: () => const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Gagal memuat data approval: $e'),
                        ),
                      ),
                  data: (items) => ResponsiveDataView<ApprovalItem>(
                        items: items,
                        columns: _buildColumns(context, ref),
                        onRowTap: (item) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Pengajuan: ${item.description}')));
                        },
                        footer: Text(
                            'Showing ${items.length} data out of ${items.length}',
                            style: Theme.of(context).textTheme.bodySmall),
                      )),
            ],
          ),
        ));
  }

  List<DataColumnDef<ApprovalItem>> _buildColumns(
          BuildContext context, WidgetRef ref) =>
      [
        DataColumnDef(
            label: 'Project Name',
            flex: 3,
            isTitle: true,
            cell: (_, item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.projectName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      item.category,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.gray500),
                    )
                  ],
                )),
        DataColumnDef(
            label: 'Deskripsi Item',
            flex: 3,
            cell: (_, item) => Text(item.description)),
        DataColumnDef(
            label: 'PIC / Vendor',
            flex: 2,
            cell: (_, item) => Text(item.executorName)),
        DataColumnDef(
            label: 'Total Biaya',
            flex: 2,
            cell: (_, item) => Text(
                  Formatters.rupiah(item.amount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary),
                )),
        DataColumnDef(
          label: 'Tanggal',
          flex: 2,
          cell: (_, item) =>
              Text(DateFormat('dd MMM yyyy').format(item.createdAt)),
        ),
        DataColumnDef(
            label: 'Status',
            flex: 2,
            cell: (_, item) => switch (item.status) {
                  ApprovalStatus.pending => const StatusBadge(
                      label: 'Pending',
                      tone: BadgeTone.progress,
                    ),
                  ApprovalStatus.approved => const StatusBadge(
                      label: 'Approved', tone: BadgeTone.success),
                  ApprovalStatus.rejected =>
                    const StatusBadge(label: 'Rejected', tone: BadgeTone.danger)
                }),
      ];
}

class _ApprovalToolbar extends ConsumerWidget {
  const _ApprovalToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(approvalStatusFilterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: (v) =>
                ref.read(approvalSearchProvider.notifier).state = v,
            decoration: const InputDecoration(
                hintText: 'Cari berdasarkan nama proyek, kategori, PIC...',
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 18,
                )),
          ),
          const SizedBox(
            height: 12,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context,
                    label: 'All',
                    isSelected: selectedStatus == null,
                    onSelected: () => ref
                        .read(approvalStatusFilterProvider.notifier)
                        .state = null),
                const SizedBox(
                  width: 8,
                ),
                _buildFilterChip(
                  context,
                  label: 'Pending',
                  isSelected: selectedStatus == ApprovalStatus.pending,
                  onSelected: () => ref
                      .read(approvalStatusFilterProvider.notifier)
                      .state = ApprovalStatus.pending,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'Approved',
                  isSelected: selectedStatus == ApprovalStatus.approved,
                  onSelected: () => ref
                      .read(approvalStatusFilterProvider.notifier)
                      .state = ApprovalStatus.approved,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'Rejected',
                  isSelected: selectedStatus == ApprovalStatus.rejected,
                  onSelected: () => ref
                      .read(approvalStatusFilterProvider.notifier)
                      .state = ApprovalStatus.rejected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context,
      {required String label,
      required bool isSelected,
      required VoidCallback onSelected}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.primary50,
      labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.gray600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12),
      side:
          BorderSide(color: isSelected ? AppColors.primary : AppColors.stroke),
    );
  }
}
