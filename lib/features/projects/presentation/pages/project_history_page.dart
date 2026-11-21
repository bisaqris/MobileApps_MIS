import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mis_app/core/responsive/breakpoints.dart';
import 'package:mis_app/core/theme/app_colors.dart';
import 'package:mis_app/core/utils/formatters.dart';
import 'package:mis_app/core/widgets/responsive_data_view.dart';
import 'package:mis_app/core/widgets/status_badge.dart';
import 'package:mis_app/features/projects/domain/entities/project.dart';
import 'package:mis_app/features/projects/presentation/providers/project_providers.dart';

class ProjectHistoryPage extends ConsumerWidget {
  const ProjectHistoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProjectsProvider);
    final pad = context.pagePadding;

    return RefreshIndicator(
        onRefresh: () async => ref.refresh(allHistoryProjectsProvider),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project History',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                'Arip proyek yang telah selesai dikerjakan beserta ringkasan pencapaian',
                style: TextStyle(color: AppColors.gray500, fontSize: 13),
              ),
              const SizedBox(height: 16),
              historyAsync.maybeWhen(
                  data: (items) => _buildSummaryCards(context, items),
                  orElse: () => const SizedBox.shrink()),
              const SizedBox(height: 16),
              const _HistoryToolbar(),
              const SizedBox(height: 16),
              historyAsync.when(
                  loading: () => const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Gagal memuat histori proyek: $e'))),
                  data: (items) => ResponsiveDataView<Project>(
                      items: items,
                      columns: _buildColumns(context),
                      onRowTap: (p) => context.push('/projects/${p.id}'),
                      emptyMessage:
                          'Tidak ada riwayat proyek yang sesuai dengan filter.',
                      footer: Text(
                        'Showing ${items.length} completed projects',
                        style: Theme.of(context).textTheme.bodySmall,
                      )))
            ],
          ),
        ));
  }

  Widget _buildSummaryCards(BuildContext context, List<Project> items) {
    final totalAmount = items.fold<int>(0, (sum, p) => sum + p.contractValue);

    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 600;

      final card1 = _buildSummaryItem(
          icon: Iconsax.tick_circle,
          iconColor: AppColors.success,
          iconBgColor: AppColors.success.withValues(alpha: .1),
          title: 'Completed Projects',
          value: '${items.length} Projects',
          valueColor: AppColors.heading);

      final card2 = _buildSummaryItem(
          icon: Iconsax.money_2,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primary.withValues(alpha: .1),
          title: 'Total Realisasi',
          value: Formatters.rupiah(totalAmount),
          valueColor: AppColors.primary);

      if (isCompact) {
        return Column(
          children: [
            card1,
            const SizedBox(
              height: 12,
            ),
            card2
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(
            width: 16,
          ),
          Expanded(child: card2),
        ],
      );
    });
  }

  Widget _buildSummaryItem(
      {required IconData icon,
      required Color iconColor,
      required Color iconBgColor,
      required String title,
      required String value,
      required Color valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconBgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ))
        ],
      ),
    );
  }

  List<DataColumnDef<Project>> _buildColumns(BuildContext context) => [
        DataColumnDef(
            label: 'Project Name',
            flex: 3,
            isTitle: true,
            cell: (_, p) => Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
        DataColumnDef(
            label: 'Category', flex: 2, cell: (_, p) => Text(p.category.label)),
        DataColumnDef(
            label: 'Client / Company',
            flex: 2,
            cell: (_, p) => Text(p.clientName)),
        DataColumnDef(
            label: 'Project Manager', flex: 2, cell: (_, p) => Text(p.manager)),
        DataColumnDef(
            label: 'Contract Value',
            flex: 2,
            cell: (_, p) => Text(
                  Formatters.rupiah(p.contractValue),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary),
                )),
        DataColumnDef(
            label: 'Event Date',
            flex: 2,
            cell: (_, p) =>
                Text(DateFormat('dd MMM yyyy').format(p.eventDate))),
        DataColumnDef(
            label: 'Status',
            flex: 2,
            cell: (_, p) => const StatusBadge(
                  label: 'Done',
                  tone: BadgeTone.success,
                )),
      ];
}

class _HistoryToolbar extends ConsumerStatefulWidget {
  const _HistoryToolbar();

  @override
  ConsumerState<_HistoryToolbar> createState() => _HistoryToolbarState();
}

class _HistoryToolbarState extends ConsumerState<_HistoryToolbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: ref.read(historySearchProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(historyCategoryFilterProvider);
    final selectedYear = ref.watch(historyYearFilterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) {
              ref.read(historySearchProvider.notifier).state = v;
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Cari riwayat nama proyek, client, atau PM...',
              prefixIcon: const Icon(
                Iconsax.search_normal,
                size: 18,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(historySearchProvider.notifier).state = '';
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Tahun:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600),
                ),
                const SizedBox(
                  width: 8,
                ),
                _buildChip(
                  label: 'Semua',
                  isSelected: selectedYear == null,
                  onSelected: () =>
                      ref.read(historyYearFilterProvider.notifier).state = null,
                ),
                const SizedBox(
                  width: 6,
                ),
                for (final y in [2026, 2025, 2024]) ...[
                  _buildChip(
                      label: '$y',
                      isSelected: selectedYear == y,
                      onSelected: () => ref
                          .read(historyYearFilterProvider.notifier)
                          .state = y),
                  const SizedBox(
                    width: 6,
                  )
                ],
                const SizedBox(
                  width: 12,
                ),
                const SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                const Text(
                  'Kategori:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600),
                ),
                const SizedBox(
                  width: 8,
                ),
                _buildChip(
                    label: 'Semua',
                    isSelected: selectedCategory == null,
                    onSelected: () => ref
                        .read(historyCategoryFilterProvider.notifier)
                        .state = null),
                const SizedBox(
                  width: 6,
                ),
                for (final cat in ProjectCategory.values) ...[
                  _buildChip(
                      label: cat.label,
                      isSelected: selectedCategory == cat,
                      onSelected: () => ref
                          .read(historyCategoryFilterProvider.notifier)
                          .state = cat),
                  const SizedBox(
                    width: 6,
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChip({
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
          fontSize: 11),
      side:
          BorderSide(color: isSelected ? AppColors.primary : AppColors.stroke),
    );
  }
}
