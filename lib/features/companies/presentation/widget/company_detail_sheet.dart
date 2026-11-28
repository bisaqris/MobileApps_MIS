import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/company.dart';

class CompanyDetailSheet extends ConsumerWidget {
  const CompanyDetailSheet({
    super.key,
    required this.company,
    required this.onEdit,
    required this.onDelete,
  });

  final Company company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Future<void> show(
    BuildContext context, {
    required Company company,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompanyDetailSheet(
        company: company,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  static List<Project> matchProjectsForCompany(
    Company company,
    List<Project> allProjects,
  ) {
    final lowerName = company.name.trim().toLowerCase();
    return allProjects.where((p) {
      final matchesClientId = company.clientIds.contains(p.clientId);
      final matchesCompanyName =
          p.clientName.trim().toLowerCase() == lowerName;
      return matchesClientId || matchesCompanyName;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.buildings_2,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (company.city != null && company.city!.isNotEmpty)
                        Text(
                          company.city!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _infoRow(Iconsax.call, 'Nomor Kontak', company.phone),
            _infoRow(
              Iconsax.sms,
              'Email',
              (company.email == null || company.email!.isEmpty)
                  ? '-'
                  : company.email!,
            ),
            if (company.website != null && company.website!.isNotEmpty)
              _infoRow(Iconsax.global, 'Website', company.website!),
            _infoRow(Iconsax.location, 'Alamat', company.fullAddress),
            if (company.clientNames.isNotEmpty)
              _infoRow(
                Iconsax.profile_2user,
                'PIC Terdaftar',
                company.clientNames.join(', '),
              ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            const Text(
              'Daftar Project Terhubung',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            projectsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(
                'Gagal memuat project terhubung: $e',
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
              data: (allProjects) {
                final connected = matchProjectsForCompany(company, allProjects);
                if (connected.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Text(
                      'Belum ada project yang terhubung dengan perusahaan ini.',
                      style: TextStyle(fontSize: 13, color: AppColors.gray500),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: connected
                      .map((project) => _ProjectCardTile(project: project))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    icon: const Icon(
                      Iconsax.trash,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    icon: const Icon(Iconsax.edit_2, size: 18),
                    label: const Text('Edit Perusahaan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.gray600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCardTile extends StatelessWidget {
  const _ProjectCardTile({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (project.status) {
      ProjectStatus.draft => ('New', BadgeTone.info),
      ProjectStatus.active => ('On progress', BadgeTone.progress),
      ProjectStatus.onHold => ('On hold', BadgeTone.neutral),
      ProjectStatus.completed => ('Done', BadgeTone.success),
      ProjectStatus.cancelled => ('Cancelled', BadgeTone.danger),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.pop(context);
          context.push('/projects/${project.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project.category.label} • ${Formatters.rupiah(project.contractValue)} • ${Formatters.date(project.eventDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(label: label, tone: tone),
            ],
          ),
        ),
      ),
    );
  }
}

