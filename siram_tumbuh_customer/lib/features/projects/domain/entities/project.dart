class Project {
  final String id;
  final String title;
  final String status;
  final double progress;
  final DateTime startDate;
  final DateTime? estimatedEndDate;
  final String location;
  final double totalBiaya;
  final List<dynamic> rabItems;
  final Map<String, dynamic> timeline;

  const Project({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.startDate,
    this.estimatedEndDate,
    required this.location,
    this.totalBiaya = 0,
    this.rabItems = const [],
    this.timeline = const {},
  });
}
