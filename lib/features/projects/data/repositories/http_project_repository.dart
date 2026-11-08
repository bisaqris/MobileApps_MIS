import 'package:dio/dio.dart';
import 'package:mis_app/features/projects/data/repositories/project_model.dart';
import 'package:mis_app/features/projects/domain/entities/project.dart';
import 'package:mis_app/features/projects/domain/repositories/project_repository.dart';

class HttpProjectRepository implements ProjectRepository {
  HttpProjectRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<Project>> fetchProjects({String query = ''}) async {
    try {
      final response = await dio.get<dynamic>('/api/projects',
          queryParameters:
              query.trim().isNotEmpty ? {'search': query.trim()} : null);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
          'Gagal mengambil data proyek: ${e.response?.statusMessage ?? e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
