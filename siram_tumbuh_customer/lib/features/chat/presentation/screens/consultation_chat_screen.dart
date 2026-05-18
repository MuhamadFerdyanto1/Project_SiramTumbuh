import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../catalog/domain/entities/service_item.dart';
import '../../domain/services/decision_tree_service.dart';
import '../../../../services/api_client.dart';

class ConsultationChatScreen extends StatefulWidget {
  final ServiceItem? service;

  const ConsultationChatScreen({super.key, this.service});

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final DecisionTreeService _spkService = DecisionTreeService();
  final ApiClient _apiClient = ApiClient();
  
  DecisionTreeNode? _currentNode;
  bool _isBotActive = true;
  Timer? _pollingTimer;
  final ScrollController _scrollController = ScrollController();

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _startPolling();
  }

  Future<void> _initializeChat() async {
    // Muat riwayat awal secara bersih
    await _fetchMessages(isInitial: true);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startBotConsultation() {
    _currentNode = _spkService.getNode('root');
    _addBotMessage('Halo! Saya SiramBot 🤖. Sambil menunggu Admin kami membalas, boleh saya bantu berikan rekomendasi paket yang paling cocok untuk Anda?');
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _currentNode != null) {
        _addBotMessage(_currentNode!.question, isQuestion: true);
      }
    });
  }

  void _startPolling() {
    // Poll pesan baru setiap 5 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages({bool isInitial = false}) async {
    try {
      final response = await _apiClient.get('/chat', queryParameters: {
        'customer_name': 'User Test', 
      });
      
      if (response.data != null && response.data is List) {
        final allMessages = response.data as List;
        
        setState(() {
          if (isInitial) _messages.clear();

          for (var msg in allMessages) {
            final int msgId = int.tryParse(msg['id'].toString()) ?? 0;
            
            // Cek duplikasi berdasarkan ID atau teks jika id lokal masih 0
            int existingIndex = _messages.indexWhere((m) => 
                m['id'] == msgId || 
                (m['id'] == 0 && m['text'] == msg['message'])
            );
            
            if (existingIndex >= 0) {
              // Update ID asli dari database jika sebelumnya 0, supaya posisi urutan benar
              if (_messages[existingIndex]['id'] == 0) {
                _messages[existingIndex]['id'] = msgId;
              }
            } else {
              _messages.add({
                'id': msgId,
                'text': msg['message'],
                'isMe': msg['sender_role'] == 'customer',
                'isBot': msg['sender_role'] == 'bot',
                'isQuestion': false, // Riwayat murni tidak perlu opsi
                'time': DateTime.parse(msg['created_at'] ?? DateTime.now().toString()),
              });
            }
          }
          
          // Urutkan berdasarkan ID
          _messages.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        });

        // Jika ini pertama kali buka dan benar-benar kosong, baru mulai bot
        if (isInitial && _messages.isEmpty) {
          _startBotConsultation();
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  void _addBotMessage(String text, {bool isQuestion = false}) {
    // Untuk pesan Bot baru, kita tambahkan ID sementara 0 agar muncul di UI sambil nunggu DB
    setState(() {
      _messages.add({
        'id': 0, 
        'text': text,
        'isMe': false,
        'isBot': true,
        'isQuestion': isQuestion,
        'time': DateTime.now(),
      });
    });
    _saveMessageToBackend(text, 'bot');
    _scrollToBottom();
  }

  Future<void> _saveMessageToBackend(String text, String role) async {
    try {
      await _apiClient.post('/chat/send', data: {
        'customer_name': 'User Test',
        'sender_role': role,
        'message': text,
      });
      // Setelah kirim, tarik data terbaru agar ID dari DB terupdate ke list lokal
      _fetchMessages(); 
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  void _handleOptionSelected(String optionLabel, String nextIdOrRec) {
    _addMessage(optionLabel, isMe: true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_spkService.isRecommendation(nextIdOrRec)) {
        _addBotMessage('Analisis selesai! 📊');
        _addBotMessage(nextIdOrRec.replaceAll('REC: ', ''));
        _addBotMessage('Admin kami akan segera menghubungi Anda untuk mendiskusikan rekomendasi ini lebih lanjut.');
        setState(() => _isBotActive = false);
      } else {
        _currentNode = _spkService.getNode(nextIdOrRec);
        if (_currentNode != null && mounted) {
          _addBotMessage(_currentNode!.question, isQuestion: true);
        }
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final text = _messageController.text;
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': DateTime.now(),
      });
      _messageController.clear();
    });
    
    _saveMessageToBackend(text, 'customer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.support_agent, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsultasi Siram Tumbuh',
                  style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                final isQuestion = message['isQuestion'] ?? false;
                
                return Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _buildMessageBubble(message['text'], isMe, message['time'], isBot: message['isBot'] ?? false),
                    if (isQuestion && _isBotActive) _buildOptions(index),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildOptions(int messageIndex) {
    if (messageIndex != _messages.length - 1) return const SizedBox.shrink();
    if (_currentNode == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _currentNode!.options.entries.map((entry) {
          return ActionChip(
            label: Text(entry.key),
            onPressed: () => _handleOptionSelected(entry.key, entry.value),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF4CAF50)),
            labelStyle: const TextStyle(color: Color(0xFF4CAF50), fontSize: 13),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, DateTime time, {bool isBot = false}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4CAF50) : (isBot ? const Color(0xFFE8F5E9) : Colors.white),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14, 
                color: isMe ? Colors.white : Colors.black87,
                fontWeight: isBot ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(time),
              style: TextStyle(
                fontSize: 10, 
                color: isMe ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Tombol untuk memicu Bot AI kapan saja
            IconButton(
              icon: const Icon(Icons.smart_toy_outlined, color: Color(0xFF4CAF50)),
              tooltip: 'Mulai Konsultasi SPK',
              onPressed: () {
                setState(() {
                  _isBotActive = true;
                  _addMessage('Mulai Konsultasi Baru 🤖', isMe: true);
                  _startBotConsultation();
                });
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _addMessage(String text, {bool isMe = false, bool isBot = false}) {
    final newMessage = {
      'id': 0, // ID sementara sebelum sinkron dengan database
      'text': text,
      'isMe': isMe,
      'isBot': isBot,
      'time': DateTime.now(),
    };
    setState(() {
      _messages.add(newMessage);
    });
    // Simpan ke database sesuai role
    _saveMessageToBackend(text, isBot ? 'bot' : (isMe ? 'customer' : 'admin'));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

