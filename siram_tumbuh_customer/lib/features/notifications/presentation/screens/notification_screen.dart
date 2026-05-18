import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../services/api_client.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/domain/entities/project.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _latestChat;
  bool _isLoadingChat = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestChat();
  }

  Future<void> _fetchLatestChat() async {
    try {
      final response = await _apiClient.get('/chat', queryParameters: {
        'customer_name': 'User Test',
      });
      
      if (response.data != null && response.data is List) {
        final messages = response.data as List;
        if (messages.isNotEmpty) {
          // Sort to get the latest
          messages.sort((a, b) => (int.tryParse(b['id'].toString()) ?? 0).compareTo(int.tryParse(a['id'].toString()) ?? 0));
          setState(() {
            _latestChat = messages.first;
            _isLoadingChat = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching chat for notif: $e');
    }
    setState(() {
      _isLoadingChat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(myProjectsProvider);
    final primaryColor = const Color(0xFF1B9347);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chat Section (Special Row)
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.support_agent, color: Color(0xFF4CAF50)),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                title: const Text('Chat dengan Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: _isLoadingChat 
                    ? const Text('Memuat pesan terbaru...', style: TextStyle(fontSize: 13, color: Colors.grey))
                    : Text(
                        _latestChat != null ? _latestChat!['message'] : 'Klik di sini untuk berkonsultasi',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  context.push('/home/chat'); // No specific service
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Pemberitahuan Proyek',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),

            // Project Updates Section
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return _buildEmptyNotification();
                }
                
                // Show notification for each project based on its status
                return Column(
                  children: projects.map((project) => _buildProjectNotification(project, primaryColor)).toList(),
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotification() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      width: double.infinity,
      child: const Column(
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pemberitahuan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Notifikasi pesanan dan update proyek akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectNotification(Project project, Color primaryColor) {
    String title = 'Proyek Update';
    String message = 'Ada pembaruan pada proyek ${project.title}.';
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.blue;

    if (project.status == 'Selesai') {
      title = 'Proyek Selesai!';
      message = 'Hore! Pengerjaan ${project.title} telah selesai dilakukan. Terima kasih!';
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else if (project.status == 'Sedang Dikerjakan') {
      title = 'Proyek Sedang Dikerjakan';
      message = 'Tim kami sedang di lokasi untuk mengerjakan ${project.title}. Progress saat ini: ${(project.progress * 100).toInt()}%.';
      icon = Icons.construction;
      iconColor = Colors.orange;
    } else if (project.status == 'Menunggu Survei') {
      title = 'Menunggu Survei';
      message = 'Kami akan segera melakukan survei untuk ${project.title}.';
      icon = Icons.calendar_today_outlined;
      iconColor = Colors.blue;
    } else if (project.status == 'Pembuatan RAB' || project.status == 'Negosiasi') {
      title = 'RAB & Penawaran';
      message = 'Admin sedang menyiapkan RAB/Penawaran untuk ${project.title}.';
      icon = Icons.request_quote_outlined;
      iconColor = Colors.purple;
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () {
          context.push('/home/projects/${project.id}', extra: project);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(project.startDate),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
