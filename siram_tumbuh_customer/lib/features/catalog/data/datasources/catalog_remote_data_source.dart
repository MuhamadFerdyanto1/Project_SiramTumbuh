import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service_item_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<ServiceItemModel>> getServices();
}

final String apiBaseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl();

  @override
  Future<List<ServiceItemModel>> getServices() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('mitra-rizki-admin')
          .collection('public')
          .doc('data')
          .collection('paket_layanan')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        String parseImageUrl(String url) {
          if (url.isEmpty) return url;
          if (url.startsWith('/uploads/') || url.startsWith('/api/uploads/')) {
            if (!url.startsWith('/api/')) url = '/api$url';
            return '$apiBaseUrl$url';
          }
          if (url.contains('drive.google.com/file/d/')) {
            final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
            if (match != null && match.group(1) != null) {
              return 'https://drive.google.com/uc?export=view&id=${match.group(1)}';
            }
          } else if (url.contains('drive.google.com/open?id=')) {
            final uri = Uri.parse(url);
            if (uri.queryParameters.containsKey('id')) {
              return 'https://drive.google.com/uc?export=view&id=${uri.queryParameters['id']}';
            }
          }
          return url;
        }

        return ServiceItemModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          imageUrl: parseImageUrl(data['imageUrl'] ?? ''),
          includedItems: (data['includedItems'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
          price: data['price'] != null ? double.parse(data['price'].toString()) : 0.0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return [];
    }
  }
}

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource>((ref) {
  return CatalogRemoteDataSourceImpl();
});
