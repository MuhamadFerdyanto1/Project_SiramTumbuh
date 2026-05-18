import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../catalog/domain/entities/service_item.dart';
import '../../../../features/projects/data/repositories/project_repository_impl.dart';
import '../../../../features/projects/presentation/providers/project_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final ServiceItem service;

  const BookingScreen({super.key, required this.service});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedPayment = 'transfer';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleBooking() async {
    if (_addressController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat dan Tanggal Survei harus diisi'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      if (user == null) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      }

      final repository = ref.read(projectRepositoryProvider);
      
      final projectData = {
        'nama_klien': user.name,
        'alamat': _addressController.text,
        'telepon': user.wa,
        'klien_email': user.email,
        'status': 'Menunggu Survei',
        'progress': 0,
        'rabItems': widget.service.includedItems.isNotEmpty 
          ? widget.service.includedItems 
          : [
              {
                'nama': widget.service.name,
                'qty': 1,
                'satuan': 'paket',
                'harga': widget.service.price,
              }
            ],
        'survey': {
          'tanggal': _selectedDate?.toIso8601String(),
          'catatan': _notesController.text,
          'pembayaran': _selectedPayment,
        }
      };

      final success = await repository.createProject(projectData);

      if (success) {
        // Invalidate provider so the list refreshes
        ref.invalidate(myProjectsProvider);
        
        if (mounted) {
          // Pindah ke layar konfirmasi
          context.pushReplacement('/home/booking/confirmation');
        }
      } else {
        throw Exception('Gagal membuat pesanan, silakan coba lagi nanti');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
        title: const Text(
          'Formulir Pemesanan',
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
            // Ringkasan Pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.service.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(width: 80, height: 80, color: Colors.grey[300]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatCurrency.format(widget.service.price),
                          style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Lokasi
            const Text('Alamat Lokasi Proyek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap beserta patokan...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // Tanggal Survei
            const Text('Jadwal Survei / Pengerjaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? 'Pilih Tanggal' : dateFormat.format(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null ? Colors.grey : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Catatan
            const Text('Catatan Tambahan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Misal: Tolong hubungi nomor ini saat survei...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // Metode Pembayaran
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  RadioListTile(
                    value: 'transfer',
                    groupValue: _selectedPayment,
                    onChanged: (val) => setState(() => _selectedPayment = val.toString()),
                    title: const Text('Transfer Bank'),
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  RadioListTile(
                    value: 'qris',
                    groupValue: _selectedPayment,
                    onChanged: (val) => setState(() => _selectedPayment = val.toString()),
                    title: const Text('QRIS'),
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  RadioListTile(
                    value: 'cash',
                    groupValue: _selectedPayment,
                    onChanged: (val) => setState(() => _selectedPayment = val.toString()),
                    title: const Text('Tunai (saat survei)'),
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
