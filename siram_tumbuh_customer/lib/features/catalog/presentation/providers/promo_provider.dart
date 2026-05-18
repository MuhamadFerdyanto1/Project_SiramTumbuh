import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Promo {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String content;
  final String ctaLabel;
  final String ctaUrl;
  final int order;

  Promo({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.description = '',
    this.content = '',
    this.ctaLabel = '',
    this.ctaUrl = '',
    this.order = 0,
  });

  static String parseImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    // Already a full URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Handle Google Drive share links
      if (url.contains('drive.google.com/file/d/')) {
        final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
        if (match != null && match.group(1) != null) {
          return 'https://drive.google.com/uc?export=view&id=${match.group(1)}';
        }
      } else if (url.contains('drive.google.com/open?id=')) {
        final uri = Uri.tryParse(url);
        if (uri != null && uri.queryParameters.containsKey('id')) {
          return 'https://drive.google.com/uc?export=view&id=${uri.queryParameters['id']}';
        }
      }
      // If it's already a full localhost URL, keep it as is
      return url;
    }
    // Relative path from PHP upload server → make absolute
    if (url.startsWith('/api/')) {
      return 'http://localhost:8080$url';
    }
    if (url.startsWith('/uploads/')) {
      return 'http://localhost:8080/api$url';
    }
    return url;
  }
}

final promoProvider = FutureProvider<List<Promo>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc('mitra-rizki-admin')
        .collection('public')
        .doc('data')
        .collection('promos')
        .get();

    final promos = snapshot.docs.map((doc) {
      final data = doc.data();
      final rawUrl = data['imageUrl'] as String? ?? '';
      final resolvedUrl = Promo.parseImageUrl(rawUrl);
      debugPrint('[PromoProvider] doc=${doc.id} rawUrl="$rawUrl" resolved="$resolvedUrl"');
      return Promo(
        id: doc.id,
        title: data['title'] ?? '',
        imageUrl: resolvedUrl,
        description: data['description'] ?? '',
        content: data['content'] ?? '',
        ctaLabel: data['ctaLabel'] ?? '',
        ctaUrl: data['ctaUrl'] ?? '',
        order: data['order'] ?? 0,
      );
    }).toList();

    // Sort client-side by order field
    promos.sort((a, b) => a.order.compareTo(b.order));
    return promos;
  } catch (e, st) {
    debugPrint('[PromoProvider] Error: $e\n$st');
    return [];
  }
});
