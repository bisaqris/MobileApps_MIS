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
      final response = await dio.get<dynamic>('/projects',
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

  @override
  Future<Project> getProjectById(String id) async {
    try {
      final response = await dio.get<dynamic>('/projects/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final projectData = data.containsKey('data') ? data['data'] : data;
        return ProjectModel.fromJson(projectData as Map<String, dynamic>);
      }
      throw Exception('Format data proyek tidak valid');
    } on DioException catch (e) {
      throw Exception(
          'Gagal memuat detail proyek: ${e.response?.statusMessage ?? e.message}');
    }
  }

  @override
  Future<void> createProject(Project project) async {
    try {
      final model = ProjectModel(
          id: project.id,
          name: project.name,
          category: project.category,
          clientId: project.clientId,
          clientName: project.clientName,
          manager: project.manager,
          contractValue: project.contractValue,
          eventDate: project.eventDate,
          status: project.status);
      await dio.post('/projects', data: model.toCreateJson());
    } on DioException catch (e) {
      throw Exception(
          'Gagal menambah proyek: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      final model = ProjectModel(
          id: project.id,
          name: project.name,
          category: project.category,
          clientId: project.clientId,
          clientName: project.clientName,
          manager: project.manager,
          contractValue: project.contractValue,
          eventDate: project.eventDate,
          status: project.status);

      await dio.patch('/projects/${project.id}', data: model.toUpdateJson());
    } on DioException catch (e) {
      throw Exception(
          'Gagal memperbarui proyek: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await dio.delete('/projects/$id');
    } on DioException catch (e) {
      throw Exception(
          'Gagal menghapus proyek: ${e.response?.data ?? e.message}');
    }
  }
}
