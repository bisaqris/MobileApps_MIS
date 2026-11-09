import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> fetchProjects({String query = ''});
  Future<Project> getProjectById(String id);
  Future<void> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String id);
}
