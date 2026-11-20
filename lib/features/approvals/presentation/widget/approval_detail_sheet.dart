import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mis_app/core/theme/app_colors.dart';
import 'package:mis_app/core/utils/formatters.dart';
import 'package:mis_app/core/widgets/status_badge.dart';
import 'package:mis_app/features/approvals/domain/entities/approval_item.dart';
import 'package:mis_app/features/approvals/presentation/providers/approval_providers.dart';

class ApprovalDetailSheet extends ConsumerWidget {
  const ApprovalDetailSheet({super.key, required this.item});

  final ApprovalItem item;

  static Future<void> show(BuildContext context, {required ApprovalItem item}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ApprovalDetailSheet(item: item));
  }

  BadgeTone _getStatusTone(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return BadgeTone.progress;
      case ApprovalStatus.approved:
        return BadgeTone.success;
      case ApprovalStatus.rejected:
        return BadgeTone.danger;
    }
  }

  Widget _buildRow(
      {required IconData icon,
      required String label,
      required String value,
      Color? valueColor,
      bool isBold = false}) {
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
          const SizedBox(width: 14),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: valueColor ?? AppColors.heading),
              )
            ],
          ))
        ],
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Pengajuan Biaya'),
        content: Text(
            'Yakin ingin menyetujui pengajuan biaya sebesar ${Formatters.rupiah(item.amount)} untuk proyek "${item.projectName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Setujui'),
          )
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await ref
          .read(approvalControllerProvider.notifier)
          .approveCost(item.id);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success
                ? 'Pengajuan biaya berhasil disetujui!'
                : 'Gagal menyetujui pengajuan biaya.')));
      }
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Tolak Pengajuan Biaya'),
              content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berikan alasan atau catatan revisi pengajuan ini.',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        controller: noteCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Contoh: Harga sewa terlalu tinggi, silahkan nego...',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Alasan penolakan wajib diisi'
                            : null,
                      )
                    ],
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal')),
                FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: const Text('Tolak Pengajuan'))
              ],
            ));
    if (confirm == true && context.mounted) {
      final success = await ref
          .read(approvalControllerProvider.notifier)
          .rejectCost(item.id, noteCtrl.text.trim());

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success
                ? 'Pengajuan biaya berhasil ditolak.'
                : 'Gagal memproses penolakan biaya.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(approvalControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Pengajuan Biaya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                StatusBadge(
                  label: item.status.label,
                  tone: _getStatusTone(item.status),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(
              height: 1,
            ),
            const SizedBox(
              height: 12,
            ),
            _buildRow(
                icon: Iconsax.document_text,
                label: 'Nama Proyek',
                value: item.projectName,
                isBold: true),
            _buildRow(
                icon: Iconsax.category,
                label: 'Kategori Biaya',
                value: item.category),
            _buildRow(
                icon: Iconsax.note_text,
                label: 'Deskripsi / Keperluan',
                value: item.description),
            _buildRow(
                icon: Iconsax.user,
                label: 'Vendor / PIC Pelaksana',
                value: item.executorName),
            _buildRow(
                icon: Iconsax.calculator,
                label: 'Rincian Satuan & Jumlah',
                value:
                    '${Formatters.rupiah(item.unitPrice)} x ${item.quantity}'),
            _buildRow(
                icon: Iconsax.money_2,
                label: 'Total Biaya Pengajuan',
                value: Formatters.rupiah(item.amount),
                valueColor: AppColors.primary,
                isBold: true),
            _buildRow(
                icon: Iconsax.calendar_1,
                label: 'Tanggal Diajukan',
                value: DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                    .format(item.createdAt)),
            if (item.status == ApprovalStatus.rejected &&
                item.rejectionNote != null &&
                item.rejectionNote!.isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dangerLight)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Penolakan / Revisi:',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          item.rejectionNote!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textBody),
                        )
                      ],
                    ))
                  ],
                ),
              )
            ],
            const SizedBox(
              height: 24,
            ),
            if (item.status == ApprovalStatus.pending)
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                    onPressed:
                        isLoading ? null : () => _handleReject(context, ref),
                    icon: const Icon(
                      Iconsax.close_circle,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Tolak',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: FilledButton.icon(
                    onPressed:
                        isLoading ? null : () => _handleApprove(context, ref),
                    label: const Text('Setujui'),
                    icon: const Icon(
                      Iconsax.tick_circle,
                      size: 18,
                    ),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ))
                ],
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Tutup'),
              )
          ],
        ),
      ),
    );
  }
}
