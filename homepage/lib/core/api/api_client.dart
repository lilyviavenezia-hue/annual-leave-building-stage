import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  }) : baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://localhost:8000',
           ),
       _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient
        .post(
          Uri.parse(baseUrl).resolve(path),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The API response must be a JSON object.');
    }
    return decoded;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'API request failed (HTTP $statusCode).';
}