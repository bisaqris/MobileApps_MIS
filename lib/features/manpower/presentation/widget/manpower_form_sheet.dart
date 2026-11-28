import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../skills/domain/entities/skill.dart';
import '../../../skills/presentation/providers/skill_providers.dart';
import '../../domain/entities/manpower.dart';
import '../providers/manpower_providers.dart';

class ManpowerFormSheet extends ConsumerStatefulWidget {
  const ManpowerFormSheet({super.key, this.manpower});

  final Manpower? manpower;

  static Future<void> show(BuildContext context, {Manpower? manpower}) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManpowerFormSheet(manpower: manpower),
    );
  }

  @override
  ConsumerState<ManpowerFormSheet> createState() => _ManpowerFormSheetState();
}

class _ManpowerFormSheetState extends ConsumerState<ManpowerFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _customSkillCtrl;
  late final TextEditingController _rateCtrl;

  late EmploymentStatus _employmentStatus;
  late ManpowerAvailability _availability;
  late List<String> _selectedSkillNames;
  late List<String> _selectedSkillIds;

  @override
  void initState() {
    super.initState();
    final m = widget.manpower;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _roleCtrl = TextEditingController(text: m?.role ?? '');
    _phoneCtrl = TextEditingController(text: m?.phone ?? '');
    _emailCtrl = TextEditingController(text: m?.email ?? '');
    _customSkillCtrl = TextEditingController();
    _rateCtrl = TextEditingController(
      text: m?.standardRate != null ? m!.standardRate.toString() : '',
    );
    _employmentStatus = m?.employmentStatus ?? EmploymentStatus.freelance;
    _availability = m?.availability ?? ManpowerAvailability.available;
    _selectedSkillNames = List<String>.from(m?.skills ?? const []);
    _selectedSkillIds = List<String>.from(m?.skillIds ?? const []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _customSkillCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _toggleSkill(Skill skill) {
    setState(() {
      final existsByName = _selectedSkillNames.any(
        (s) => s.toLowerCase() == skill.name.toLowerCase(),
      );
      if (existsByName) {
        _selectedSkillNames.removeWhere(
          (s) => s.toLowerCase() == skill.name.toLowerCase(),
        );
        _selectedSkillIds.remove(skill.id);
      } else {
        _selectedSkillNames.add(skill.name);
        if (skill.id.isNotEmpty && !_selectedSkillIds.contains(skill.id)) {
          _selectedSkillIds.add(skill.id);
        }
      }
    });
  }

  void _addCustomSkill() {
    final text = _customSkillCtrl.text.trim();
    if (text.isEmpty) return;
    final exists = _selectedSkillNames.any(
      (s) => s.toLowerCase() == text.toLowerCase(),
    );
    if (!exists) {
      setState(() => _selectedSkillNames.add(text));
    }
    _customSkillCtrl.clear();
  }

  void _removeSkillChip(String skillName, List<Skill> masterSkills) {
    setState(() {
      final matchedMasterIds = masterSkills
          .where((s) => s.name.toLowerCase() == skillName.toLowerCase())
          .map((s) => s.id)
          .where((id) => id.isNotEmpty)
          .toSet();
      if (matchedMasterIds.isNotEmpty) {
        _selectedSkillIds.removeWhere(matchedMasterIds.contains);
      }
      final orig = widget.manpower;
      if (orig != null && orig.skills.length == orig.skillIds.length) {
        final origIndex = orig.skills.indexWhere(
          (s) => s.toLowerCase() == skillName.toLowerCase(),
        );
        if (origIndex >= 0 && origIndex < orig.skillIds.length) {
          _selectedSkillIds.remove(orig.skillIds[origIndex]);
        }
      } else if (matchedMasterIds.isEmpty &&
          _selectedSkillNames.length == _selectedSkillIds.length) {
        final currentIndex = _selectedSkillNames.indexOf(skillName);
        if (currentIndex >= 0 && currentIndex < _selectedSkillIds.length) {
          _selectedSkillIds.removeAt(currentIndex);
        }
      }
      _selectedSkillNames.remove(skillName);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final customText = _customSkillCtrl.text.trim();
    if (customText.isNotEmpty &&
        !_selectedSkillNames
            .any((s) => s.toLowerCase() == customText.toLowerCase())) {
      _selectedSkillNames.add(customText);
    }

    final parsedRate = _rateCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_rateCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));

    final manpower = Manpower(
      id: widget.manpower?.id ?? '',
      name: _nameCtrl.text.trim(),
      role: _roleCtrl.text.trim(),
      positionId: widget.manpower?.positionId,
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      skills: List<String>.from(_selectedSkillNames),
      skillIds: List<String>.from(_selectedSkillIds),
      employmentStatus: _employmentStatus,
      availability: _availability,
      standardRate: parsedRate,
      createdAt: widget.manpower?.createdAt,
    );

    final controller = ref.read(manpowerControllerProvider.notifier);
    final isEdit = widget.manpower != null;
    final success = isEdit
        ? await controller.updateManpower(manpower)
        : await controller.createManpower(manpower);

    if (mounted) {
      if (success) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Data manpower berhasil diperbarui!'
                  : 'Data manpower berhasil ditambahkan!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data manpower! Cek koneksi Anda.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(manpowerControllerProvider).isLoading;
    final skillsAsync = ref.watch(allSkillsProvider);
    final masterSkills = skillsAsync.valueOrNull ?? const <Skill>[];
    final isEdit = widget.manpower != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Edit Manpower' : 'Tambah Manpower Baru',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Iconsax.user),
                  hintText: 'Contoh: Raka Pratama',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama manpower wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Role / Jabatan',
                  prefixIcon: Icon(Iconsax.briefcase),
                  hintText: 'Contoh: Camera Operator, Video Editor',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Role / jabatan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon / WhatsApp',
                  prefixIcon: Icon(Iconsax.call),
                  hintText: 'Contoh: 0812-3456-7890',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nomor kontak wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (Opsional)',
                  prefixIcon: Icon(Iconsax.sms),
                  hintText: 'Contoh: nama@makromedia.id',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  return emailRegex.hasMatch(v.trim())
                      ? null
                      : 'Format email tidak valid';
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EmploymentStatus>(
                initialValue: _employmentStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Pekerjaan',
                  prefixIcon: Icon(Iconsax.personalcard),
                ),
                items: EmploymentStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(
                  () => _employmentStatus = v ?? _employmentStatus,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Standard Rate / Day (Rp - Opsional)',
                  prefixIcon: Icon(Iconsax.money),
                  hintText: 'Contoh: 1500000',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Status Ketersediaan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ManpowerAvailability.values.map((avail) {
                  final selected = _availability == avail;
                  return ChoiceChip(
                    label: Text(avail.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _availability = avail),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keahlian / Skill',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              skillsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text(
                  'Daftar master skill tidak dapat dimuat.',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
                data: (skills) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    final selected = _selectedSkillNames.any(
                      (s) => s.toLowerCase() == skill.name.toLowerCase(),
                    );
                    return FilterChip(
                      label: Text(skill.name),
                      selected: selected,
                      onSelected: (_) => _toggleSkill(skill),
                      selectedColor: AppColors.primary50,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color:
                            selected ? AppColors.primary : AppColors.gray600,
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.stroke,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customSkillCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tambah skill lainnya (opsional)',
                        hintText: 'Contoh: Color Grading',
                        prefixIcon: Icon(Iconsax.star),
                      ),
                      onFieldSubmitted: (_) => _addCustomSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _addCustomSkill,
                    child: const Text('Tambah'),
                  ),
                ],
              ),
              if (_selectedSkillNames.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedSkillNames
                      .map(
                        (skillName) => InputChip(
                          label: Text(
                            skillName,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () =>
                              _removeSkillChip(skillName, masterSkills),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Manpower',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

