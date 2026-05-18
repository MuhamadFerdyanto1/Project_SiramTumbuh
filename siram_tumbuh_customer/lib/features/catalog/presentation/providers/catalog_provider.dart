import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_item.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/entities/testimonial.dart';

final String apiBaseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

final catalogProvider = FutureProvider<List<ServiceItem>>((ref) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getServices();
});

final testimonialProvider = FutureProvider<List<Testimonial>>((ref) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/testimonials'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      String parseImageUrl(String? url) {
        if (url == null || url.isEmpty) return '';
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

      return data.map((json) => Testimonial(
        id: json['id'].toString(),
        title: json['title'] ?? 'Portofolio IG',
        igUrl: json['ig_url'] ?? '',
        thumbnailUrl: parseImageUrl(json['thumbnail_url']),
      )).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
});
