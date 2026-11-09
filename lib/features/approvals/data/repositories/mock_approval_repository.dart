import 'package:mis_app/features/approvals/domain/repositories/approval_repository.dart';

import '../../domain/entities/approval_item.dart';

class MockApprovalRepository implements ApprovalRepository {
  static final _data = <ApprovalItem>[
    ApprovalItem(
      id: 'cost-1',
      projectId: 'proj-1',
      projectName: 'Annual Summit Livestream',
      category: 'Equipment Rental',
      description: 'Sewa Kamera Sony FX6 & Lens Kit (3 Hari)',
      executorName: 'Anton C.',
      unitPrice: 2500000,
      quantity: 3,
      amount: 7500000,
      status: ApprovalStatus.pending,
      createdAt: DateTime(2026, 5, 10),
    ),
    ApprovalItem(
      id: 'cost-2',
      projectId: 'proj-2',
      projectName: 'Company Profile Video',
      category: 'Crew & Manpower',
      description: 'Director of Photography (DP) & Lighting Crew',
      executorName: 'Andi K.',
      unitPrice: 6000000,
      quantity: 2,
      amount: 12000000,
      status: ApprovalStatus.pending,
      createdAt: DateTime(2026, 8, 2),
    ),
    ApprovalItem(
      id: 'cost-3',
      projectId: 'proj-3',
      projectName: 'Dokumenter Sejarah Budaya',
      category: 'Studio & Lighting',
      description: 'Sewa Lighting Aputure 600d & Studio Soundstage',
      executorName: 'Agus C.',
      unitPrice: 8500000,
      quantity: 1,
      amount: 8500000,
      status: ApprovalStatus.approved,
      createdAt: DateTime(2026, 8, 12),
    ),
    ApprovalItem(
      id: 'cost-4',
      projectId: 'proj-4',
      projectName: 'The Onsen Resort Wedding',
      category: 'Sound System',
      description: 'Sewa Wireless Mic & Audio Mixer Outdoor',
      executorName: 'Budi S.',
      unitPrice: 4000000,
      quantity: 1,
      amount: 4000000,
      status: ApprovalStatus.rejected,
      rejectionNote:
          'Harga sewa terlalu tinggi, silakan nego ulang dengan vendor audio.',
      createdAt: DateTime(2026, 7, 1),
    ),
  ];

  @override
  Future<List<ApprovalItem>> fetchApprovals({
    String query = '',
    ApprovalStatus? status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();

    return _data.where((item) {
      final matchQuery = q.isEmpty ||
          item.projectName.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.executorName.toLowerCase().contains(q);

      final matchStatus = status == null || item.status == status;

      return matchQuery && matchStatus;
    }).toList();
  }

  @override
  Future<ApprovalItem> getApprovalById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _data.firstWhere(
      (item) => item.id == id,
      orElse: () =>
          throw Exception('Pengajuan biaya dengan ID $id tidak ditemukan.'),
    );
  }
}
