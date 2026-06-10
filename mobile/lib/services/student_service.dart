import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/student.dart';

class StudentService {
  Future<List<Student>> fetchRecommendedStudents({
    required String anonymousDeviceId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/students/recommended',
    ).replace(queryParameters: {'anonymousDeviceId': anonymousDeviceId});
    debugPrint('GET $uri');
    final response = await http.get(uri).timeout(ApiConfig.timeout);
    debugPrint('GET $uri -> ${response.statusCode}');
    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      debugPrint('GET $uri failed: ${response.body}');
      throw Exception(
        decodedResponse['message'] ?? 'Failed to load recommended students',
      );
    }

    final data = decodedResponse['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .map((item) => Student.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Student> fetchStudent({
    required String studentId,
    required String anonymousDeviceId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/students/$studentId',
    ).replace(queryParameters: {'anonymousDeviceId': anonymousDeviceId});
    debugPrint('GET $uri');
    final response = await http.get(uri).timeout(ApiConfig.timeout);
    debugPrint('GET $uri -> ${response.statusCode}');
    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      debugPrint('GET $uri failed: ${response.body}');
      throw Exception(decodedResponse['message'] ?? 'Failed to load student');
    }

    return Student.fromJson(decodedResponse['data'] as Map<String, dynamic>);
  }

  Future<String> sendConnectRequest({
    required String anonymousDeviceId,
    required String studentId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/connect-requests');
    debugPrint('POST $uri');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'anonymousDeviceId': anonymousDeviceId,
            'studentId': studentId,
          }),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('POST $uri -> ${response.statusCode}');
    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('POST $uri failed: ${response.body}');
      throw Exception(
        decodedResponse['message'] ?? 'Failed to send connect request',
      );
    }

    return decodedResponse['message']?.toString() ??
        'Connect request sent successfully.';
  }
}
