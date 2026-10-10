import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const _timeout = Duration(seconds: 10);
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String url) => _send(() => _client.get(Uri.parse(url)));

  Future<dynamic> post(String url, Map<String, dynamic> body) => _send(
        () => _client.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Server error (${response.statusCode})');
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on http.ClientException {
      throw const ApiException('No internet connection.');
    } on FormatException {
      throw const ApiException('Invalid response from server.');
    }
  }
}