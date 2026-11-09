import 'package:mis_app/features/approvals/domain/entities/approval_item.dart';

abstract interface class ApprovalRepository {
  Future<List<ApprovalItem>> fetchApprovals({
    String query = '',
    ApprovalStatus? status,
  });

  Future<ApprovalItem> getApprovalById(String id);
}
