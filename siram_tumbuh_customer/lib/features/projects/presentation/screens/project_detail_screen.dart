import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import 'package:intl/intl.dart';
import '../providers/project_provider.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project initialProject;

  const ProjectDetailScreen({super.key, required this.initialProject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    String _formatTimelineDate(dynamic dateVal, String defaultText) {
      if (dateVal == null || dateVal.toString().isEmpty) return defaultText;
      try {
        final date = DateTime.parse(dateVal.toString());
        return dateFormat.format(date);
      } catch (e) {
        return dateVal.toString();
      }
    }
    
    final projectsAsync = ref.watch(myProjectsProvider);
    final project = projectsAsync.maybeWhen(
      data: (projects) => projects.cast<Project>().firstWhere((p) => p.id == initialProject.id, orElse: () => initialProject),
      orElse: () => initialProject,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
        title: const Text(
          'Detail Proyek',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ),
                      _buildStatusChip(project.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(project.location, style: const TextStyle(color: Colors.black54))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text('Mulai: ${dateFormat.format(project.startDate)}', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Progress Bar Overall
            const Text('Status Pengerjaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress Keseluruhan', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${(project.progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Timeline
            const Text('Timeline Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),
            
            _buildTimelineItem(
              title: 'Survei Lokasi Selesai', 
              date: _formatTimelineDate(project.timeline['survei'], 'Belum dijadwalkan'), 
              isCompleted: project.timeline['survei'] != null, 
              isLast: false
            ),
            _buildTimelineItem(
              title: 'Desain Disetujui', 
              date: _formatTimelineDate(project.timeline['desain'], 'Menunggu persetujuan'), 
              isCompleted: project.timeline['desain'] != null, 
              isLast: false
            ),
            _buildTimelineItem(
              title: 'Pengerjaan Lahan', 
              date: _formatTimelineDate(project.timeline['lahan'], 'Estimasi: Segera'), 
              isCompleted: project.timeline['lahan'] != null || project.progress >= 0.5, 
              isLast: false
            ),
            _buildTimelineItem(
              title: 'Penanaman & Irigasi', 
              date: _formatTimelineDate(project.timeline['penanaman'], 'Estimasi: Segera'), 
              isCompleted: project.timeline['penanaman'] != null || project.progress >= 0.8, 
              isLast: false
            ),
            _buildTimelineItem(
              title: 'Serah Terima', 
              date: _formatTimelineDate(project.timeline['serah_terima'], 'Estimasi: Segera'), 
              isCompleted: project.timeline['serah_terima'] != null || project.progress >= 1.0, 
              isLast: true
            ),

            const SizedBox(height: 32),
            
            // Photo Gallery
            const Text('Galeri Update', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPhotoItem('https://images.unsplash.com/photo-1558904541-efa843a96f0f?w=300'),
                  _buildPhotoItem('https://images.unsplash.com/photo-1585320806297-9794b3e4ce88?w=300'),
                  _buildPhotoItem('https://images.unsplash.com/photo-1416879598056-022fcb82d495?w=300'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({required String title, required String date, required bool isCompleted, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  if (isCompleted) BoxShadow(color: const Color(0xFF4CAF50).withValues(alpha: 0.3), blurRadius: 8),
                ],
              ),
              child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCompleted ? Colors.black87 : Colors.grey)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String imageUrl) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
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
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
