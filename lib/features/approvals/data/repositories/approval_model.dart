import 'package:mis_app/features/approvals/domain/entities/approval_item.dart';

class ApprovalModel extends ApprovalItem {
  const ApprovalModel({
    required super.id,
    required super.projectId,
    required super.projectName,
    required super.category,
    required super.description,
    required super.executorName,
    required super.unitPrice,
    required super.quantity,
    required super.amount,
    required super.status,
    super.rejectionNote,
    required super.createdAt,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString().toUpperCase();
    ApprovalStatus status;
    switch (rawStatus) {
      case 'APPROVED':
        status = ApprovalStatus.approved;
        break;
      case 'REJECTED':
      case 'REVISE':
        status = ApprovalStatus.rejected;
        break;
      case 'PENDING':
      default:
        status = ApprovalStatus.pending;
        break;
    }

    String projectName = 'Unknown Project';
    if (json['project'] is Map && json['project']['name'] != null) {
      projectName = json['project']['name'].toString();
    } else if (json['projectName'] != null || json['project_name'] != null) {
      projectName = (json['projectName'] ?? json['project_name']).toString();
    }

    final unitPrice =
        num.tryParse((json['unitPrice'] ?? json['unit_price'] ?? 0).toString())
                ?.toInt() ??
            0;
    final quantity = int.tryParse((json['quantity'] ?? 1).toString()) ?? 1;
    final amount = num.tryParse((json['amount'] ?? 0).toString())?.toInt() ??
        (unitPrice * quantity);

    final createdAt = json['createdAt'] != null || json['created_at'] != null
        ? DateTime.tryParse(
                (json['createdAt'] ?? json['created_at']).toString()) ??
            DateTime.now()
        : DateTime.now();

    return ApprovalModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId'] ?? json['project_id'] ?? '',
        projectName: projectName,
        category: json['category']?.toString() ?? 'Production Cost',
        description: json['description']?.toString() ?? '',
        executorName: json['executorName'] ?? json['executor_name'] ?? '-',
        unitPrice: unitPrice,
        quantity: quantity,
        amount: amount,
        status: status,
        rejectionNote: json['rejectionNote'] ?? json['rejection_note'],
        createdAt: createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'category': category,
      'description': description,
      'executorName': executorName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'amount': amount,
      'status': status.apiValue,
      'rejectionNote': rejectionNote,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
