import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_data_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/skill.dart';
import '../providers/skill_providers.dart';

class SkillListPage extends ConsumerWidget {
  const SkillListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsProvider);
    final pad = context.pagePadding;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(skillsProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skill Management',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Kelola daftar master keahlian / skill untuk manpower tim produksi.',
              style: TextStyle(color: AppColors.gray500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _SkillToolbar(
              onSearch: (v) =>
                  ref.read(skillSearchProvider.notifier).state = v,
              onAdd: () => _showSkillFormDialog(context, ref),
            ),
            const SizedBox(height: 16),
            skillsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat data skill: $e'),
              ),
              data: (items) => ResponsiveDataView<Skill>(
                items: items,
                columns: _buildColumns(context, ref),
                emptyMessage: 'Belum ada data skill',
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

  List<DataColumnDef<Skill>> _buildColumns(
    BuildContext context,
    WidgetRef ref,
  ) =>
      [
        DataColumnDef(
          label: 'Nama Skill',
          flex: 4,
          isTitle: true,
          cell: (_, skill) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Iconsax.star,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  skill.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataColumnDef(
          label: 'Tag',
          flex: 2,
          cell: (_, skill) => StatusBadge(
            label: skill.name,
            tone: BadgeTone.info,
          ),
        ),
        DataColumnDef(
          label: 'Tanggal Dibuat',
          flex: 2,
          cell: (_, skill) => Text(
            skill.createdAt != null ? Formatters.date(skill.createdAt!) : '-',
          ),
        ),
        DataColumnDef(
          label: 'Action',
          flex: 2,
          isAction: true,
          cell: (context, skill) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit Skill',
                onPressed: () =>
                    _showSkillFormDialog(context, ref, skill: skill),
                icon: const Icon(Iconsax.edit_2, size: 20),
                color: AppColors.gray500,
              ),
              IconButton(
                tooltip: 'Hapus Skill',
                onPressed: () => _confirmDelete(context, ref, skill),
                icon: const Icon(Iconsax.trash, size: 20),
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ];

  Future<void> _showSkillFormDialog(
    BuildContext context,
    WidgetRef ref, {
    Skill? skill,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SkillFormDialog(skill: skill),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Skill skill,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Skill'),
        content: Text('Yakin ingin menghapus skill "${skill.name}"?'),
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
      final success =
          await ref.read(skillControllerProvider.notifier).deleteSkill(skill.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Skill "${skill.name}" berhasil dihapus.'
                  : 'Gagal menghapus skill.',
            ),
          ),
        );
      }
    }
  }
}

class _SkillToolbar extends StatelessWidget {
  const _SkillToolbar({required this.onSearch, required this.onAdd});

  final ValueChanged<String> onSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      onChanged: onSearch,
      decoration: const InputDecoration(
        hintText: 'Cari nama skill...',
        prefixIcon: Icon(Iconsax.search_normal, size: 18),
      ),
    );
    final addButton = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Iconsax.add, size: 18),
      label: const Text('Add Skill'),
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

class _SkillFormDialog extends ConsumerStatefulWidget {
  const _SkillFormDialog({this.skill});

  final Skill? skill;

  @override
  ConsumerState<_SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends ConsumerState<_SkillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.skill?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.skill != null;
    final controller = ref.read(skillControllerProvider.notifier);
    final trimmedName = _nameCtrl.text.trim();
    final success = isEdit
        ? await controller.updateSkill(widget.skill!.id, trimmedName)
        : await controller.createSkill(trimmedName);

    if (!mounted) return;
    if (success) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.pop(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Skill berhasil diperbarui!'
                : 'Skill berhasil ditambahkan!',
          ),
        ),
      );
    } else {
      final err = ref.read(skillControllerProvider).error;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan skill: ${err ?? "cek koneksi Anda"}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.skill != null;
    final isLoading = ref.watch(skillControllerProvider).isLoading;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Skill' : 'Tambah Skill Baru'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameCtrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) _submit();
            },
            decoration: const InputDecoration(
              labelText: 'Nama Keahlian / Skill',
              hintText: 'Contoh: Videography, Drone Pilot',
              prefixIcon: Icon(Iconsax.star),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Nama skill wajib diisi';
              }
              if (v.trim().length > 80) {
                return 'Maksimal 80 karakter';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}

