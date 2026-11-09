import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mis_app/core/theme/app_colors.dart';
import 'package:mis_app/core/utils/formatters.dart';
import 'package:mis_app/core/widgets/status_badge.dart';
import 'package:mis_app/features/projects/domain/entities/project.dart';
import 'package:mis_app/features/projects/presentation/providers/project_providers.dart';
import 'package:mis_app/features/projects/presentation/widget/project_form_sheet.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Detail Project',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
            onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        actions: [
          if (detailAsync.hasValue)
            IconButton(
                onPressed: () async {
                  await ProjectFormSheet.show(context,
                      project: detailAsync.value);
                  ref.invalidate(projectDetailProvider(projectId));
                },
                icon: const Icon(
                  Iconsax.edit_2,
                  size: 20,
                ))
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.danger, color: AppColors.danger, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat detail proyek: $err',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 16,
                ),
                FilledButton(
                    onPressed: () =>
                        ref.refresh(projectDetailProvider(projectId)),
                    child: const Text('Coba Lagi'))
              ],
            ),
          ),
        ),
        data: (project) => _ProjectDetailContent(project: project),
      ),
    );
  }
}

class _ProjectDetailContent extends StatelessWidget {
  const _ProjectDetailContent({required this.project});

  final Project project;

  BadgeTone _getStatusTone(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return BadgeTone.info;
      case ProjectStatus.active:
        return BadgeTone.progress;
      case ProjectStatus.onHold:
        return BadgeTone.neutral;
      case ProjectStatus.completed:
        return BadgeTone.success;
      case ProjectStatus.cancelled:
        return BadgeTone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          project.category.label,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      StatusBadge(
                        label: project.status.label,
                        tone: _getStatusTone(project.status),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    project.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary200)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Iconsax.money_2,
                                size: 20, color: AppColors.primary),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Contract Value',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          Formatters.rupiah(project.contractValue),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        )
                      ],
                    ),
                  ),
                ],
              )),
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: AppColors.stroke, width: 1))),
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray500,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle:
                  TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: [
                Tab(
                  text: 'Overview',
                ),
                Tab(
                  text: 'Dokumen & Links',
                ),
                Tab(
                  text: 'Timeline',
                )
              ],
            ),
          ),
          Expanded(
              child: TabBarView(children: [
            _OverviewTab(project: project),
            _DocumentsTab(project: project),
            _TimelineTabs(project: project),
          ]))
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.project});

  final Project project;

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.gray500)),
              const SizedBox(
                height: 2,
              ),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading),
              )
            ],
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.stroke),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Information',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading),
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.stroke,
                ),
                _buildInfoRow(
                    icon: Iconsax.buildings,
                    label: 'Client / Company',
                    value: project.clientName),
                _buildInfoRow(
                    icon: Iconsax.user,
                    label: 'Project Manager',
                    value: project.manager),
                _buildInfoRow(
                    icon: Iconsax.calendar_1,
                    label: 'Event Date',
                    value: DateFormat('dd MMMM yyyy', 'id_ID')
                        .format(project.eventDate)),
                _buildInfoRow(
                    icon: Iconsax.location,
                    label: 'Venue / Lokasi',
                    value: project.venue != null && project.venue!.isNotEmpty
                        ? project.venue!
                        : 'Lokasi belum ditentukan'),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.stroke)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General Brief / Deskripsi',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading),
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.stroke,
                ),
                Text(
                  project.description != null && project.description!.isNotEmpty
                      ? project.description!
                      : 'Belum ada brief atau catatan tambahan untuk proyek ini.',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.gray700, height: 1.5),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.stroke)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Links & Deliverables',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.stroke,
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.gray50,
                    child: Icon(
                      Iconsax.link,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('Google Drive Deliverables',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text(
                    'Folder aset dan hasil produksi',
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                  trailing: const Icon(
                    Iconsax.export_1,
                    size: 18,
                    color: AppColors.gray400,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Membuka tautan berkas proyek...')));
                  },
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _TimelineTabs extends StatelessWidget {
  const _TimelineTabs({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.stroke)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Milestone & Timeline',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading),
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.stroke,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Iconsax.timer_1,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Status Pelaksanaan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(project.status.label),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Iconsax.calendar_tick,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Tanggal Pelaksanaan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                      .format(project.eventDate)),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
