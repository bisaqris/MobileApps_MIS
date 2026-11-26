import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_data_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/client.dart';
import '../providers/client_providers.dart';
import '../widget/client_form_sheet.dart';

class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final pad = context.pagePadding;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(clientsProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Client',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Manajemen data kontak client perorangan dan PIC perusahaan rekanan.',
              style: TextStyle(color: AppColors.gray500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _ClientToolbar(
              onSearch: (v) =>
                  ref.read(clientSearchProvider.notifier).state = v,
              onAdd: () => ClientFormSheet.show(context),
            ),
            const SizedBox(height: 16),
            clientsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat data client: $e'),
              ),
              data: (items) => ResponsiveDataView<Client>(
                items: items,
                columns: _buildColumns(context, ref),
                emptyMessage: 'Belum ada data client',
                onRowTap: (client) =>
                    ClientFormSheet.show(context, client: client),
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

  List<DataColumnDef<Client>> _buildColumns(
    BuildContext context,
    WidgetRef ref,
  ) =>
      [
        DataColumnDef(
          label: 'Nama Client / PIC',
          flex: 3,
          isTitle: true,
          cell: (_, c) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (c.city != null && c.city!.isNotEmpty)
                Text(
                  c.city!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
            ],
          ),
        ),
        DataColumnDef(
          label: 'Perusahaan',
          flex: 3,
          cell: (_, c) => StatusBadge(
            label: c.companyName,
            tone: BadgeTone.info,
          ),
        ),
        DataColumnDef(
          label: 'Email',
          flex: 3,
          cell: (_, c) => Text(
            (c.email == null || c.email!.isEmpty) ? '-' : c.email!,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataColumnDef(
          label: 'No. Telepon',
          flex: 2,
          cell: (_, c) => Text(c.phone),
        ),
        DataColumnDef(
          label: 'Action',
          flex: 2,
          isAction: true,
          cell: (context, c) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit Client',
                onPressed: () => ClientFormSheet.show(context, client: c),
                icon: const Icon(Iconsax.edit_2, size: 20),
                color: AppColors.gray500,
              ),
              IconButton(
                tooltip: 'Hapus Client',
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
    Client client,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Client'),
        content: Text('Yakin ingin menghapus data client "${client.name}"?'),
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
          .read(clientControllerProvider.notifier)
          .deleteClient(client.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Client "${client.name}" berhasil dihapus.'
                  : 'Gagal menghapus data client.',
            ),
          ),
        );
      }
    }
  }
}

class _ClientToolbar extends StatelessWidget {
  const _ClientToolbar({required this.onSearch, required this.onAdd});

  final ValueChanged<String> onSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      onChanged: onSearch,
      decoration: const InputDecoration(
        hintText: 'Cari client berdasarkan nama, email, atau no. telp...',
        prefixIcon: Icon(Iconsax.search_normal, size: 18),
      ),
    );
    final addButton = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Iconsax.add, size: 18),
      label: const Text('Add Client'),
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

