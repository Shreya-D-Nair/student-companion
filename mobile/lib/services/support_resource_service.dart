import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/support_resource.dart';

class SupportResourceService {
  Future<List<SupportResource>> fetchSupportResources() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/support-resources');
    debugPrint('GET $uri');
    final response = await http.get(uri).timeout(ApiConfig.timeout);
    debugPrint('GET $uri -> ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('GET $uri failed: ${response.body}');
      throw Exception('Failed to load support resources');
    }

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decodedResponse['data'] as List<dynamic>? ?? <dynamic>[];

    return data
        .map((item) => SupportResource.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
