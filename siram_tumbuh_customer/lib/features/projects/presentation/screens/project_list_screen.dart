import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/project_provider.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(myProjectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
        title: const Text(
          'Proyek Saya',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text('Belum ada proyek saat ini.'));
          }
          return RefreshIndicator(
            color: const Color(0xFF4CAF50),
            onRefresh: () async {
              ref.invalidate(myProjectsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return GestureDetector(
                  onTap: () => context.push('/home/projects/${project.id}', extra: project),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                          _buildStatusChip(project.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(project.location, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(project.progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: project.progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
        error: (err, stack) => Center(
          child: Text('Terjadi kesalahan: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'in_progress':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        label = 'Berjalan';
        break;
      case 'completed':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        label = 'Selesai';
        break;
      default:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
