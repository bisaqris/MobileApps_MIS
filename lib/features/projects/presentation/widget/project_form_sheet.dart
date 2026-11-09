import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mis_app/core/theme/app_colors.dart';
import 'package:mis_app/features/projects/domain/entities/project.dart';
import 'package:mis_app/features/projects/presentation/providers/project_providers.dart';

class ProjectFormSheet extends ConsumerStatefulWidget {
  const ProjectFormSheet({super.key, this.project});

  // Jika null = mode tambah, jika ada data = mode edit
  final Project? project;

  static Future<void> show(BuildContext context, {Project? project}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProjectFormSheet(project: project));
  }

  @override
  ConsumerState<ProjectFormSheet> createState() => _ProjectFormSheetState();
}

class _ProjectFormSheetState extends ConsumerState<ProjectFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _managerCtrl;
  late final TextEditingController _contractCtrl;

  late ProjectCategory _category;
  late DateTime _eventDate;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _clientCtrl = TextEditingController(text: p?.clientName ?? '');
    _managerCtrl = TextEditingController(text: p?.manager ?? '');
    _contractCtrl = TextEditingController(
        text: p != null ? p.contractValue.toString() : '');
    _category = p?.category ?? ProjectCategory.event;
    _eventDate = p?.eventDate ?? DateTime.now();
    _status = p?.status ?? ProjectStatus.draft;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _managerCtrl.dispose();
    _contractCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final contractVal =
        int.tryParse(_contractCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final project = Project(
        id: widget.project?.id ?? '',
        name: _nameCtrl.text.trim(),
        category: _category,
        clientId:
            widget.project?.clientId ?? 'd290f1ee-6c54-4b01-90e6-d701748f0851',
        clientName: _clientCtrl.text.trim(),
        manager: _managerCtrl.text.trim(),
        contractValue: contractVal,
        eventDate: _eventDate,
        status: _status);

    final controller = ref.read(projectControllerProvider.notifier);
    final isEdit = widget.project != null;
    final success = isEdit
        ? await controller.updateProject(project)
        : await controller.createProject(project);

    if (mounted) {
      if (success) {
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEdit
                ? 'Proyek berhasil diubah!'
                : 'Proyek berhasil ditambah!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal menyimpan proyek! Cek koneksi Anda.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(projectControllerProvider).isLoading;
    final isEdit = widget.project != null;

    return Container(
      padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
          key: _formKey,
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
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  isEdit ? 'Edit Project' : 'Add New Project',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Project Name',
                      prefixIcon: Icon(Iconsax.document_text)),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama proyek wajib diisi'
                      : null,
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<ProjectCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Iconsax.category)),
                    items: ProjectCategory.values
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category)),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _clientCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Client / Company Name',
                      prefixIcon: Icon(Iconsax.buildings),
                      hintText: 'Contoh: PT Telkom Indonesia'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama client wajib diisi'
                      : null,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _managerCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Project Manager',
                      prefixIcon: Icon(Iconsax.user)),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Manager wajib diisi'
                      : null,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _contractCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Contract Value (RP)',
                      prefixIcon: Icon(Iconsax.money),
                      hintText: 'Contoh: 25000000'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nilai kontrak wajib diisi'
                      : null,
                ),
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Iconsax.calendar_1,
                    color: AppColors.primary,
                  ),
                  title:
                      const Text('Event Date', style: TextStyle(fontSize: 14)),
                  subtitle: Text(DateFormat('dd MMMM yyyy').format(_eventDate),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: _eventDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035));
                    if (picked != null) setState(() => _eventDate = picked);
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text('Project Status',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(
                  height: 8,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('New'),
                      selected: _status == ProjectStatus.draft,
                      onSelected: (s) =>
                          setState(() => _status = ProjectStatus.draft),
                    ),
                    ChoiceChip(
                      label: const Text('On Progress'),
                      selected: _status == ProjectStatus.active,
                      onSelected: (s) =>
                          setState(() => _status = ProjectStatus.active),
                    ),
                    ChoiceChip(
                      label: const Text('Done'),
                      selected: _status == ProjectStatus.completed,
                      onSelected: (s) =>
                          setState(() => _status = ProjectStatus.completed),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 28,
                ),
                FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            isEdit ? 'Update Project' : 'Create Project',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ))
              ],
            ),
          )),
    );
  }
}
