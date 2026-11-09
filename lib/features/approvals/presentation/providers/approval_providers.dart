import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mis_app/core/network/dio_client.dart';
import 'package:mis_app/features/approvals/data/repositories/http_approval_repository.dart';
import 'package:mis_app/features/approvals/data/repositories/mock_approval_repository.dart';
import 'package:mis_app/features/approvals/domain/entities/approval_item.dart';
import 'package:mis_app/features/approvals/domain/repositories/approval_repository.dart';

const bool _useMockData = true;

final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  if (_useMockData) {
    return MockApprovalRepository();
  }
  final dio = ref.watch(dioProvider);
  return HttpApprovalRepository(dio: dio);
});

final approvalSearchProvider = StateProvider<String>((ref) => '');

final approvalStatusFilterProvider =
    StateProvider<ApprovalStatus?>((ref) => null);

final approvalsProvider = FutureProvider.autoDispose<List<ApprovalItem>>((ref) {
  final query = ref.watch(approvalSearchProvider);
  final status = ref.watch(approvalStatusFilterProvider);
  return ref
      .watch(approvalRepositoryProvider)
      .fetchApprovals(query: query, status: status);
});
