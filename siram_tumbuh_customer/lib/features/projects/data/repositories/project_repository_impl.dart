import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Project>> getMyProjects(String email) async {
    return await remoteDataSource.getMyProjects(email);
  }

  @override
  Future<bool> createProject(Map<String, dynamic> data) async {
    return await remoteDataSource.createProject(data);
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final remoteDataSource = ref.watch(projectRemoteDataSourceProvider);
  return ProjectRepositoryImpl(remoteDataSource);
});
