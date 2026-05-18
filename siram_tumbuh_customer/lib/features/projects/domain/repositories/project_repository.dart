import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getMyProjects(String email);
  Future<bool> createProject(Map<String, dynamic> data);
}
