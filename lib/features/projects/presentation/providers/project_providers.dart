import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mis_app/core/network/dio_client.dart';
import 'package:mis_app/features/projects/data/repositories/http_project_repository.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return HttpProjectRepository(dio: dio);
});

final projectSearchProvider = StateProvider<String>((ref) => '');

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) {
  final query = ref.watch(projectSearchProvider);
  return ref.watch(projectRepositoryProvider).fetchProjects(query: query);
});
