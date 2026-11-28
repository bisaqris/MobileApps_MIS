import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_data_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/company.dart';
import '../providers/company_providers.dart';
import '../widget/company_detail_sheet.dart';
import '../widget/company_form_sheet.dart';

class CompanyListPage extends ConsumerWidget {
  const CompanyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);
    final allProjects =
        ref.watch(allProjectsProvider).valueOrNull ?? const <Project>[];
    final pad = context.pagePadding;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allProjectsProvider);
        return ref.refresh(companiesProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Perusahaan (Company)',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Manajemen data instansi / perusahaan rekanan klien beserta daftar project terhubung.',
              style: TextStyle(color: AppColors.gray500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _CompanyToolbar(
              onSearch: (v) =>
                  ref.read(companySearchProvider.notifier).state = v,
              onAdd: () => CompanyFormSheet.show(context),
            ),
            const SizedBox(height: 16),
            companiesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat data perusahaan: $e'),
              ),
              data: (items) => ResponsiveDataView<Company>(
                items: items,
                columns: _buildColumns(context, ref, allProjects),
                emptyMessage: 'Belum ada data perusahaan',
                onRowTap: (company) => CompanyDetailSheet.show(
                  context,
                  company: company,
                  onEdit: () => CompanyFormSheet.show(context, company: company),
                  onDelete: () => _confirmDelete(context, ref, company),
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

  List<DataColumnDef<Company>> _buildColumns(
    BuildContext context,
    WidgetRef ref,
    List<Project> allProjects,
  ) =>
      [
        DataColumnDef(
          label: 'Nama Instansi',
          flex: 3,
          isTitle: true,
          cell: (_, c) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (c.email != null && c.email!.isNotEmpty)
                Text(
                  c.email!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
            ],
          ),
        ),
        DataColumnDef(
          label: 'Alamat',
          flex: 3,
          cell: (_, c) => Text(
            c.fullAddress,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataColumnDef(
          label: 'Nomor Kontak',
          flex: 2,
          cell: (_, c) => Text(c.phone),
        ),
        DataColumnDef(
          label: 'Projects',
          flex: 2,
          cell: (_, c) {
            final count =
                CompanyDetailSheet.matchProjectsForCompany(c, allProjects)
                    .length;
            return StatusBadge(
              label: '$count Project${count == 1 ? '' : 's'}',
              tone: count > 0 ? BadgeTone.info : BadgeTone.neutral,
            );
          },
        ),
        DataColumnDef(
          label: 'Action',
          flex: 2,
          isAction: true,
          cell: (context, c) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit Perusahaan',
                onPressed: () => CompanyFormSheet.show(context, company: c),
                icon: const Icon(Iconsax.edit_2, size: 20),
                color: AppColors.gray500,
              ),
              IconButton(
                tooltip: 'Hapus Perusahaan',
                onPressed: () => _confirmDelete(context, ref, c),
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
    Company company,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perusahaan'),
        content: Text('Yakin ingin menghapus perusahaan "${company.name}"?'),
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
          .read(companyControllerProvider.notifier)
          .deleteCompany(company.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Perusahaan "${company.name}" berhasil dihapus.'
                  : 'Gagal menghapus data perusahaan.',
            ),
          ),
        );
      }
    }
  }
}

class _CompanyToolbar extends StatelessWidget {
  const _CompanyToolbar({required this.onSearch, required this.onAdd});

  final ValueChanged<String> onSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      onChanged: onSearch,
      decoration: const InputDecoration(
        hintText: 'Cari nama instansi, alamat, kota, atau kontak...',
        prefixIcon: Icon(Iconsax.search_normal, size: 18),
      ),
    );
    final addButton = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Iconsax.add, size: 18),
      label: const Text('Add Company'),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [search, const SizedBox(height: 12), addButton],
            )
          : Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 12),
                addButton,
              ],
            ),
    );
  }
}

