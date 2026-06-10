import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/confession.dart';

class ConfessionService {
  Future<List<Confession>> fetchConfessions({String? anonymousDeviceId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/confessions').replace(
      queryParameters:
          anonymousDeviceId == null
              ? null
              : {'anonymousDeviceId': anonymousDeviceId},
    );
    debugPrint('GET $uri');
    final response = await http.get(uri).timeout(ApiConfig.timeout);
    debugPrint('GET $uri -> ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('GET $uri failed: ${response.body}');
      throw Exception('Failed to load confessions');
    }

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decodedResponse['data'] as List<dynamic>? ?? <dynamic>[];

    return data
        .map((item) => Confession.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Confession> createConfession({
    required String anonymousDeviceId,
    required String content,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/confessions');
    debugPrint('POST $uri');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'anonymousDeviceId': anonymousDeviceId,
            'content': content,
          }),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('POST $uri -> ${response.statusCode}');

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      debugPrint('POST $uri failed: ${response.body}');
      throw Exception(
        decodedResponse['message'] ?? 'Failed to create confession',
      );
    }

    return Confession.fromJson(decodedResponse['data'] as Map<String, dynamic>);
  }

  Future<Confession> reactToConfession({
    required String confessionId,
    required String anonymousDeviceId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/confessions/$confessionId/react',
    );
    debugPrint('POST $uri');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'anonymousDeviceId': anonymousDeviceId}),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('POST $uri -> ${response.statusCode}');

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      debugPrint('POST $uri failed: ${response.body}');
      throw Exception(decodedResponse['message'] ?? 'Failed to react');
    }

    return Confession.fromJson(decodedResponse['data'] as Map<String, dynamic>);
  }

  Future<Confession> removeReaction({
    required String confessionId,
    required String anonymousDeviceId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/confessions/$confessionId/react',
    );
    debugPrint('DELETE $uri');
    final response = await http
        .delete(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'anonymousDeviceId': anonymousDeviceId}),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('DELETE $uri -> ${response.statusCode}');

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      debugPrint('DELETE $uri failed: ${response.body}');
      throw Exception(
        decodedResponse['message'] ?? 'Failed to remove reaction',
      );
    }

    return Confession.fromJson(decodedResponse['data'] as Map<String, dynamic>);
  }

  Future<void> reportConfession({
    required String confessionId,
    required String anonymousDeviceId,
    required String reason,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/confessions/$confessionId/report',
    );
    debugPrint('POST $uri');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'anonymousDeviceId': anonymousDeviceId,
            'reason': reason,
          }),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('POST $uri -> ${response.statusCode}');

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      debugPrint('POST $uri failed: ${response.body}');
      throw Exception(decodedResponse['message'] ?? 'Failed to report');
    }
  }

  Future<void> deleteConfession({
    required String confessionId,
    required String anonymousDeviceId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/confessions/$confessionId');
    debugPrint('DELETE $uri');
    final response = await http
        .delete(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'anonymousDeviceId': anonymousDeviceId}),
        )
        .timeout(ApiConfig.timeout);
    debugPrint('DELETE $uri -> ${response.statusCode}');

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      debugPrint('DELETE $uri failed: ${response.body}');
      throw Exception(decodedResponse['message'] ?? 'Failed to delete');
    }
  }
}
