import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=200'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.name ?? '-',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            if ((user?.wa ?? '').isNotEmpty) ...[  
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 14, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 4),
                  Text(
                    user!.wa,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
            if ((user?.alamat ?? '').isNotEmpty) ...[  
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user!.alamat,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
            _buildMenuOption(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () => _showEditProfile(context, user),
            ),
            _buildMenuOption(
              icon: Icons.location_on_outlined,
              title: 'Alamat Tersimpan',
              onTap: () => _showAddresses(context),
            ),
            _buildMenuOption(
              icon: Icons.history,
              title: 'Riwayat Transaksi',
              onTap: () => _showHistory(context),
            ),
            _buildMenuOption(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              onTap: () => context.push('/home/notifications'),
            ),
            const SizedBox(height: 20),
            _buildMenuOption(
              icon: Icons.logout,
              title: 'Keluar',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar Akun'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF4CAF50)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF4CAF50)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor ?? const Color(0xFF2E7D32),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfile(BuildContext context, dynamic user) {
    final namaController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final waController = TextEditingController(text: user?.wa ?? '');
    final alamatController = TextEditingController(text: user?.alamat ?? '');
    final firestoreId = user?.firestoreId ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24, left: 24, right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profil & Database', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const SizedBox(height: 20),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: waController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'No. WhatsApp',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: alamatController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alamat Utama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (namaController.text.isEmpty) return;
                    
                    try {
                      final ref = FirebaseFirestore.instance
                          .collection('artifacts')
                          .doc('mitra-rizki-admin')
                          .collection('public')
                          .doc('data')
                          .collection('klien');

                      final dataToSave = {
                        'nama': namaController.text,
                        'email': emailController.text.toLowerCase(),
                        'wa': waController.text,
                        'alamat': alamatController.text,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      if (firestoreId.isNotEmpty) {
                        // Update existing record
                        await ref.doc(firestoreId).update(dataToSave);
                      } else {
                        // Create new record
                        dataToSave['createdAt'] = FieldValue.serverTimestamp();
                        await ref.add(dataToSave);
                      }
                      
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Profil berhasil diperbarui dan tersimpan di Database Admin!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ));
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Gagal menyimpan: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: const Text('Simpan ke Database', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddresses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alamat Tersimpan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home, color: Color(0xFF4CAF50)),
              ),
              title: const Text('Rumah Utama', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Jl. Merdeka No. 123, Jakarta Selatan\nDKI Jakarta 12345'),
              isThreeLine: true,
              trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: (){}),
            ),
            const Divider(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Alamat Baru'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.green),
              ),
              title: const Text('Pembayaran Proyek Taman', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Selesai • 12 Mei 2026'),
              trailing: const Text('Rp 5.000.000', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.pending, color: Colors.orange),
              ),
              title: const Text('Uang Muka RAB', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Menunggu Pembayaran • Hari Ini'),
              trailing: const Text('Rp 1.500.000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


}
