import 'package:dio/dio.dart';

import '../../domain/entities/manpower.dart';
import '../../domain/repositories/manpower_repository.dart';
import 'manpower_model.dart';

class HttpManpowerRepository implements ManpowerRepository {
  HttpManpowerRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<Manpower>> fetchManpower({
    String query = '',
    ManpowerAvailability? availability,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        '/manpower',
        queryParameters: query.trim().isNotEmpty
            ? {'search': query.trim(), 'limit': 100}
            : {'limit': 100},
      );
      final data = response.data;
      List<dynamic> list = const [];

      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      }

      final items = list
          .map((item) => ManpowerModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (availability == null) return items;
      return items.where((m) => m.availability == availability).toList();
    } on DioException catch (e) {
      throw Exception(
        'Gagal mengambil data manpower: ${e.response?.statusMessage ?? e.message}',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Manpower> getManpowerById(String id) async {
    try {
      final response = await dio.get<dynamic>('/manpower/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data.containsKey('data') ? data['data'] : data;
        return ManpowerModel.fromJson(payload as Map<String, dynamic>);
      }
      throw Exception('Format data manpower tidak valid.');
    } on DioException catch (e) {
      throw Exception(
        'Gagal memuat detail manpower: ${e.response?.statusMessage ?? e.message}',
      );
    }
  }

  @override
  Future<void> createManpower(Manpower manpower) async {
    try {
      final model = ManpowerModel.fromEntity(manpower);
      final response = await dio.post<dynamic>(
        '/manpower',
        data: model.toUpsertJson(),
      );

      String? createdId;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data.containsKey('data') ? data['data'] : data;
        if (payload is Map) {
          createdId = payload['id']?.toString();
        }
      }

      if (createdId != null &&
          createdId.isNotEmpty &&
          manpower.skillIds.isNotEmpty) {
        await dio.put<dynamic>(
          '/manpower/$createdId/skills',
          data: {'skillIds': manpower.skillIds},
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Gagal menambah manpower: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> updateManpower(Manpower manpower) async {
    try {
      final model = ManpowerModel.fromEntity(manpower);
      await dio.patch<dynamic>(
        '/manpower/${manpower.id}',
        data: model.toUpsertJson(),
      );

      if (manpower.skillIds.isNotEmpty) {
        await dio.put<dynamic>(
          '/manpower/${manpower.id}/skills',
          data: {'skillIds': manpower.skillIds},
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Gagal memperbarui manpower: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> deleteManpower(String id) async {
    try {
      await dio.delete<dynamic>('/manpower/$id');
    } on DioException catch (e) {
      throw Exception(
        'Gagal menghapus manpower: ${e.response?.data ?? e.message}',
      );
    }
  }
}

