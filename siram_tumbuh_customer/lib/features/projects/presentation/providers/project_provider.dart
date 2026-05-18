import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider that takes the logged-in user's email and fetches only their projects in real-time
final myProjectsProvider = StreamProvider.autoDispose<List<Project>>((ref) async* {
  final authState = ref.watch(authProvider);
  final email = authState.user?.email ?? '';

  if (email.isEmpty) {
    yield [];
    return;
  }

  final repository = ref.watch(projectRepositoryProvider);
  
  // Initial fetch
  yield await repository.getMyProjects(email);

  // Poll every 3 seconds for real-time updates
  await for (final _ in Stream.periodic(const Duration(seconds: 3))) {
    yield await repository.getMyProjects(email);
  }
});
