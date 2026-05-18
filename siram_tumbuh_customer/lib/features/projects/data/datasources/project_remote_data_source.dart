import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getMyProjects(String email);
  Future<bool> createProject(Map<String, dynamic> data);
}

final String _apiBaseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  ProjectRemoteDataSourceImpl();

  @override
  Future<List<ProjectModel>> getMyProjects(String email) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/api/projects')
          .replace(queryParameters: {'email': email.toLowerCase()});

      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode != 200) return [];

      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((data) {
        final rabItems = data['rabItems'];
        List<dynamic> parsedItems = [];
        if (rabItems is String && rabItems.isNotEmpty) {
          try { parsedItems = json.decode(rabItems); } catch (_) {}
        } else if (rabItems is List) {
          parsedItems = rabItems;
        }

        double totalBiaya = 0;
        for (final item in parsedItems) {
          if (item is Map) {
            totalBiaya += ((item['qty'] ?? 0) * (item['harga'] ?? 0)).toDouble();
          }
        }

        final timeline = data['timeline'];
        Map<String, dynamic> parsedTimeline = {};
        if (timeline is String && timeline.isNotEmpty) {
          try { parsedTimeline = json.decode(timeline); } catch (_) {}
        } else if (timeline is Map) {
          parsedTimeline = Map<String, dynamic>.from(timeline);
        }

        return ProjectModel(
          id: data['id'].toString(),
          title: data['nama_klien'] != null ? 'Proyek ${data['nama_klien']}' : 'Proyek Taman',
          status: data['status'] ?? 'pending',
          progress: data['progress'] != null
              ? double.parse(data['progress'].toString()) / 100
              : 0.0,
          startDate: data['created_at'] != null
              ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          estimatedEndDate: null,
          location: data['alamat'] ?? '',
          totalBiaya: totalBiaya,
          rabItems: parsedItems,
          timeline: parsedTimeline,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> createProject(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/projects'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(data),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSourceImpl();
});
