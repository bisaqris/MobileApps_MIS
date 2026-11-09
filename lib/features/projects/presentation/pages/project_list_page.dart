import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mis_app/features/projects/presentation/widget/project_form_sheet.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_data_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

/// Contoh implementasi pola "Tabel di layar lebar, List of Cards di layar kecil".
/// Pola yang sama dipakai ulang untuk Data Manpower, Data Client, Approval, dst.
class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final pad = context.pagePadding;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(projectsProvider),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('List of All Projects',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _Toolbar(
                onSearch: (v) =>
                    ref.read(projectSearchProvider.notifier).state = v),
            const SizedBox(height: 16),
            projects.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Gagal memuat data: $e'),
              data: (items) => ResponsiveDataView<Project>(
                items: items,
                columns: _buildColumns(context, ref),
                onRowTap: (p) {
                  context.push('/projects/${p.id}');
                },
                footer: Text(
                    'Showing ${items.length} data out of ${items.length}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumnDef<Project>> _buildColumns(
          BuildContext context, WidgetRef ref) =>
      [
        DataColumnDef(
          label: 'Project name',
          flex: 3,
          isTitle: true,
          cell: (_, p) =>
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        DataColumnDef(
            label: 'Category', flex: 2, cell: (_, p) => Text(p.category.label)),
        DataColumnDef(
            label: 'Project manager', flex: 2, cell: (_, p) => Text(p.manager)),
        DataColumnDef(
            label: 'Contract Value',
            flex: 2,
            cell: (_, p) => Text(Formatters.rupiah(p.contractValue))),
        DataColumnDef(
            label: 'Event date',
            flex: 2,
            cell: (_, p) => Text(Formatters.date(p.eventDate))),
        DataColumnDef(
          label: 'Status',
          flex: 2,
          cell: (_, p) => switch (p.status) {
            ProjectStatus.draft =>
              const StatusBadge(label: 'New', tone: BadgeTone.info),
            ProjectStatus.active =>
              const StatusBadge(label: 'On progress', tone: BadgeTone.progress),
            ProjectStatus.onHold =>
              const StatusBadge(label: 'On hold', tone: BadgeTone.neutral),
            ProjectStatus.completed =>
              const StatusBadge(label: 'Done', tone: BadgeTone.success),
            ProjectStatus.cancelled =>
              const StatusBadge(label: 'Cancelled', tone: BadgeTone.danger),
          },
        ),
        DataColumnDef(
          label: 'Action',
          flex: 2,
          isAction: true,
          cell: (context, p) => Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                onPressed: () => ProjectFormSheet.show(context, project: p),
                icon: const Icon(Iconsax.edit_2, size: 20),
                color: AppColors.gray500),
            IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Proyek'),
                            content: Text(
                                'Yakin ingin menghapus proyek "${p.name}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hapus'))
                            ],
                          ));
                  if (confirm == true) {
                    await ref
                        .read(projectControllerProvider.notifier)
                        .deleteProject(p.id);
                  }
                },
                icon: const Icon(Iconsax.trash, size: 20),
                color: AppColors.danger),
          ]),
        ),
      ];
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onSearch});
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      onChanged: onSearch,
      decoration: const InputDecoration(
        hintText: 'Search by project...',
        prefixIcon: Icon(Iconsax.search_normal, size: 18),
      ),
    );
    final add = FilledButton.icon(
      onPressed: () => ProjectFormSheet.show(context),
      icon: const Icon(Iconsax.add, size: 18),
      label: const Text('Add Project'),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      // Toolbar juga adaptif: mobile = bertumpuk, lebar = satu baris.
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [search, const SizedBox(height: 12), add])
          : Row(children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              add,
            ]),
    );
  }
}
