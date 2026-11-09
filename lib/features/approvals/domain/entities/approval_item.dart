import 'package:equatable/equatable.dart';

enum ApprovalStatus { pending, approved, rejected }

extension ApprovalStatusX on ApprovalStatus {
  String get label {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  String get apiValue {
    switch (this) {
      case ApprovalStatus.pending:
        return 'PENDING';
      case ApprovalStatus.approved:
        return 'APPROVED';
      case ApprovalStatus.rejected:
        return 'REJECTED';
    }
  }
}

class ApprovalItem extends Equatable {
  const ApprovalItem({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.category,
    required this.description,
    required this.executorName,
    required this.unitPrice,
    required this.quantity,
    required this.amount,
    required this.status,
    this.rejectionNote,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String projectName;
  final String category;
  final String description;
  final String executorName;
  final int unitPrice;
  final int quantity;
  final int amount;
  final ApprovalStatus status;
  final String? rejectionNote;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectName,
        category,
        description,
        executorName,
        unitPrice,
        quantity,
        amount,
        status,
        rejectionNote,
        createdAt
      ];
}
