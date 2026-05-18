import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl();

  @override
  Future<UserModel> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password tidak boleh kosong');
    }

    // 1. Autentikasi via Firebase Auth (verifikasi password yang sesungguhnya)
    fb_auth.UserCredential credential;
    try {
      credential = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar. Silakan daftar terlebih dahulu.');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Password salah. Silakan coba lagi.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        case 'user-disabled':
          throw Exception('Akun ini telah dinonaktifkan oleh Admin.');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    }

    // 2. Ambil profil lengkap dari Firestore (nama, WA, alamat, dll)
    final uid = credential.user!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc('mitra-rizki-admin')
        .collection('public')
        .doc('data')
        .collection('klien')
        .doc(uid);

    DocumentSnapshot doc = await docRef.get();

    // Fallback: cari berdasarkan email jika dokumen UID tidak ada
    // (untuk klien yang ditambahkan manual oleh Admin dengan email saja)
    if (!doc.exists) {
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('mitra-rizki-admin')
          .collection('public')
          .doc('data')
          .collection('klien')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        doc = snapshot.docs.first;
      } else {
        // Buat profil default jika belum ada (login pertama kali via Firebase Auth)
        final emailName = email.split('@').first;
        final defaultName = emailName.isNotEmpty
            ? '${emailName[0].toUpperCase()}${emailName.substring(1)}'
            : 'Customer';
        await docRef.set({
          'nama': defaultName,
          'email': email.trim().toLowerCase(),
          'wa': '',
          'alamat': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        doc = await docRef.get();
      }
    }

    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromFirestore(doc.id, data);
  }

  @override
  Future<void> logout() async {
    await fb_auth.FirebaseAuth.instance.signOut();
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});
