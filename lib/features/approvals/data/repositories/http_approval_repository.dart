import 'package:dio/dio.dart';
import 'package:mis_app/features/approvals/data/repositories/approval_model.dart';
import 'package:mis_app/features/approvals/domain/entities/approval_item.dart';
import 'package:mis_app/features/approvals/domain/repositories/approval_repository.dart';

class HttpApprovalRepository implements ApprovalRepository {
  HttpApprovalRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<ApprovalItem>> fetchApprovals(
      {String query = '', ApprovalStatus? status}) async {
    try {
      final response = await dio.get<dynamic>('/production-costs');
      final data = response.data;
      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      }

      final items = list
          .map((item) => ApprovalModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final q = query.trim().toLowerCase();
      return items.where((item) {
        final matchQuery = q.isEmpty ||
            item.projectName.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q);
        final matchStatus = status == null || item.status == status;
        return matchQuery && matchStatus;
      }).toList();
    } on DioException catch (e) {
      throw Exception(
          'Gagal memuat daftar approval: ${e.response?.statusMessage ?? e.message}');
    }
  }

  @override
  Future<ApprovalItem> getApprovalById(String id) async {
    try {
      final response = await dio.get<dynamic>('/production-costs/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final itemData = data.containsKey('data') ? data['data'] : data;
        return ApprovalModel.fromJson(itemData as Map<String, dynamic>);
      }
      throw Exception('Format data approval tidak valid.');
    } on DioException catch (e) {
      throw Exception(
          'Gagal memuat detail approval: ${e.response?.statusMessage ?? e.message}');
    }
  }
}
