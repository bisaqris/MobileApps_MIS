import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mis_app/core/network/dio_client.dart';
import 'package:mis_app/features/projects/data/repositories/http_project_repository.dart';
import 'package:mis_app/features/projects/data/repositories/mock_project_repository.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

// Set ke 'false' jika URL backend sudah aktif kembali
const bool _useMockData = true;

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  if (_useMockData) {
    return MockProjectRepository();
  }
  final dio = ref.watch(dioProvider);
  return HttpProjectRepository(dio: dio);
});

final projectSearchProvider = StateProvider<String>((ref) => '');

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) {
  final query = ref.watch(projectSearchProvider);
  return ref.watch(projectRepositoryProvider).fetchProjects(query: query);
});

final projectDetailProvider =
    FutureProvider.autoDispose.family<Project, String>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectById(id);
});

final projectControllerProvider =
    StateNotifierProvider<ProjectController, AsyncValue<void>>((ref) {
  return ProjectController(ref);
});

class ProjectController extends StateNotifier<AsyncValue<void>> {
  ProjectController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createProject(Project project) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(projectRepositoryProvider).createProject(project);
      state = const AsyncValue.data(null);
      _ref.invalidate(projectsProvider); // Refresh otomatis
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateProject(Project project) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(projectRepositoryProvider).updateProject(project);
      state = const AsyncValue.data(null);
      _ref.invalidate(projectsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(projectRepositoryProvider).deleteProject(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(projectsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
