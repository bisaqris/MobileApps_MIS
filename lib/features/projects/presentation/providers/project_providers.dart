import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider =
    Provider<ProjectRepository>((ref) => MockProjectRepository());

final projectSearchProvider = StateProvider<String>((ref) => '');

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) {
  final query = ref.watch(projectSearchProvider);
  return ref.watch(projectRepositoryProvider).fetchProjects(query: query);
});
