import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../companies/domain/entities/company.dart';
import '../../../companies/presentation/providers/company_providers.dart';
import '../../domain/entities/client.dart';
import '../providers/client_providers.dart';

class ClientFormSheet extends ConsumerStatefulWidget {
  const ClientFormSheet({super.key, this.client});

  final Client? client;

  static Future<void> show(BuildContext context, {Client? client}) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClientFormSheet(client: client),
    );
  }

  @override
  ConsumerState<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends ConsumerState<ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;

  String? _selectedCompanyId;
  String _selectedCompanyName = '-';

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _cityCtrl = TextEditingController(text: c?.city ?? '');
    _selectedCompanyId =
        (c != null && c.companyClientId.isNotEmpty) ? c.companyClientId : null;
    _selectedCompanyName = c?.companyName ?? '-';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Company> companies) async {
    if (!_formKey.currentState!.validate()) return;

    final matchedCompany = companies
        .where((c) => c.id == _selectedCompanyId)
        .firstOrNull;
    final companyId = matchedCompany?.id ?? _selectedCompanyId ?? '';
    final companyName = matchedCompany?.name ?? _selectedCompanyName;

    final client = Client(
      id: widget.client?.id ?? '',
      companyClientId: companyId,
      companyName: companyName,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      createdAt: widget.client?.createdAt,
    );

    final controller = ref.read(clientControllerProvider.notifier);
    final isEdit = widget.client != null;
    final success = isEdit
        ? await controller.updateClient(client)
        : await controller.createClient(client);

    if (mounted) {
      if (success) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Data client berhasil diperbarui!'
                  : 'Data client berhasil ditambahkan!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data client! Cek koneksi Anda.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(clientControllerProvider).isLoading;
    final companiesAsync = ref.watch(allCompaniesProvider);
    final companies = companiesAsync.valueOrNull ?? const <Company>[];
    final isEdit = widget.client != null;

    final validSelectedCompanyId =
        companies.any((c) => c.id == _selectedCompanyId)
            ? _selectedCompanyId
            : null;

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
                isEdit ? 'Edit Client' : 'Tambah Client Baru',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Client / PIC',
                  prefixIcon: Icon(Iconsax.user),
                  hintText: 'Contoh: Budi Santoso',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama client wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              companiesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text(
                  'Daftar perusahaan gagal dimuat.',
                  style: TextStyle(fontSize: 12, color: AppColors.danger),
                ),
                data: (companyList) => DropdownButtonFormField<String>(
                  initialValue: validSelectedCompanyId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Perusahaan / Instansi',
                    prefixIcon: Icon(Iconsax.buildings_2),
                    hintText: 'Pilih perusahaan rekanan',
                  ),
                  items: companyList
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCompanyId = value;
                      final found = companyList
                          .where((c) => c.id == value)
                          .firstOrNull;
                      _selectedCompanyName = found?.name ?? '-';
                    });
                  },
                  validator: (v) => v == null || v.isEmpty
                      ? 'Perusahaan wajib dipilih'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Iconsax.sms),
                  hintText: 'Contoh: budi.santoso@telkom.co.id',
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
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon / WhatsApp',
                  prefixIcon: Icon(Iconsax.call),
                  hintText: 'Contoh: 0812-8800-1122',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'No. telepon wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat (Opsional)',
                  prefixIcon: Icon(Iconsax.location),
                  hintText: 'Contoh: Jl. Japati No. 1',
                ),
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
                onPressed: isLoading ? null : () => _submit(companies),
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
                        isEdit ? 'Simpan Perubahan' : 'Tambah Client',
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

