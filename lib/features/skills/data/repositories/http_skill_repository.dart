import 'package:dio/dio.dart';

import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';
import 'skill_model.dart';

class HttpSkillRepository implements SkillRepository {
  HttpSkillRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<Skill>> fetchSkills({String query = ''}) async {
    try {
      final response = await dio.get<dynamic>('/manpower/skills');
      final data = response.data;
      List<dynamic> list = const [];

      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      }

      final items = list
          .map((item) => SkillModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final q = query.trim().toLowerCase();
      if (q.isEmpty) return items;
      return items.where((s) => s.name.toLowerCase().contains(q)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Gagal mengambil data skill: ${e.response?.statusMessage ?? e.message}',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Skill> createSkill(String name) async {
    try {
      final response = await dio.post<dynamic>(
        '/manpower/skills',
        data: {'name': name.trim()},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data.containsKey('data') ? data['data'] : data;
        return SkillModel.fromJson(payload as Map<String, dynamic>);
      }
      return Skill(id: '', name: name.trim(), createdAt: DateTime.now());
    } on DioException catch (e) {
      throw Exception(
        'Gagal menambah skill: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<Skill> updateSkill(String id, String name) async {
    try {
      final response = await dio.patch<dynamic>(
        '/manpower/skills/$id',
        data: {'name': name.trim()},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data.containsKey('data') ? data['data'] : data;
        return SkillModel.fromJson(payload as Map<String, dynamic>);
      }
      return Skill(id: id, name: name.trim(), updatedAt: DateTime.now());
    } on DioException catch (e) {
      throw Exception(
        'Gagal memperbarui skill: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      await dio.delete<dynamic>('/manpower/skills/$id');
    } on DioException catch (e) {
      throw Exception(
        'Gagal menghapus skill: ${e.response?.data ?? e.message}',
      );
    }
  }
}

