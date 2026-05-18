import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.title,
    required super.status,
    required super.progress,
    required super.startDate,
    super.estimatedEndDate,
    required super.location,
    super.totalBiaya,
    super.rabItems,
    super.timeline = const {},
  });
}
