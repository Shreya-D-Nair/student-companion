import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/interest.dart';

class InterestService {
  Future<List<Interest>> fetchInterests() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/interests');
    debugPrint('GET $uri');
    final response = await http.get(uri).timeout(ApiConfig.timeout);
    debugPrint('GET $uri -> ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('GET $uri failed: ${response.body}');
      throw Exception('Failed to load interests');
    }

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decodedResponse['data'] as List<dynamic>? ?? <dynamic>[];

    return data
        .map((item) => Interest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUserInterests({
    required String anonymousDeviceId,
    required List<String> interestIds,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/user-interests');
    debugPrint('POST $uri');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'anonymousDeviceId': anonymousDeviceId,
            'interestIds': interestIds,
          }),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('POST $uri -> ${response.statusCode}');

    if (response.statusCode != 200) {
      final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('POST $uri failed: ${response.body}');
      throw Exception(decodedResponse['message'] ?? 'Failed to save interests');
    }
  }
}
