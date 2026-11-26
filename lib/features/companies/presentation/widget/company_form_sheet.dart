import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/company.dart';
import '../providers/company_providers.dart';

class CompanyFormSheet extends ConsumerStatefulWidget {
  const CompanyFormSheet({super.key, this.company});

  final Company? company;

  static Future<void> show(BuildContext context, {Company? company}) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompanyFormSheet(company: company),
    );
  }

  @override
  ConsumerState<CompanyFormSheet> createState() => _CompanyFormSheetState();
}

class _CompanyFormSheetState extends ConsumerState<CompanyFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _websiteCtrl = TextEditingController(text: c?.website ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _cityCtrl = TextEditingController(text: c?.city ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final company = Company(
      id: widget.company?.id ?? '',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      website:
          _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      province: widget.company?.province,
      clientIds: widget.company?.clientIds ?? const [],
      clientNames: widget.company?.clientNames ?? const [],
      createdAt: widget.company?.createdAt,
    );

    final controller = ref.read(companyControllerProvider.notifier);
    final isEdit = widget.company != null;
    final success = isEdit
        ? await controller.updateCompany(company)
        : await controller.createCompany(company);

    if (mounted) {
      if (success) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Data perusahaan berhasil diperbarui!'
                  : 'Data perusahaan berhasil ditambahkan!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data perusahaan! Cek koneksi Anda.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(companyControllerProvider).isLoading;
    final isEdit = widget.company != null;

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
                isEdit ? 'Edit Perusahaan' : 'Tambah Perusahaan Baru',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Perusahaan / Instansi',
                  prefixIcon: Icon(Iconsax.buildings_2),
                  hintText: 'Contoh: PT Telkom Indonesia',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama instansi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kontak / Telepon',
                  prefixIcon: Icon(Iconsax.call),
                  hintText: 'Contoh: (021) 5215-100',
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
                  labelText: 'Email Perusahaan (Opsional)',
                  prefixIcon: Icon(Iconsax.sms),
                  hintText: 'Contoh: corporate@telkom.co.id',
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
              TextFormField(
                controller: _websiteCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Website (Opsional)',
                  prefixIcon: Icon(Iconsax.global),
                  hintText: 'Contoh: https://www.telkom.co.id',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat Instansi',
                  prefixIcon: Icon(Iconsax.location),
                  hintText: 'Contoh: Jl. Japati No. 1, Sadang Serang',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Alamat instansi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kota / Kabupaten (Opsional)',
                  prefixIcon: Icon(Iconsax.map_1),
                  hintText: 'Contoh: Bandung',
                ),
              ),
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
                        isEdit ? 'Simpan Perubahan' : 'Tambah Perusahaan',
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

