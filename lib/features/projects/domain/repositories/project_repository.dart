import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> fetchProjects({String query = ''});
}
