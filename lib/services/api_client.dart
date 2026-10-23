import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  /// مشاكل DummyJSON: 403 لما التوكن مفقود، و500 مع "invalid token" لما
  /// يكون التوكن تالف. الباك إند الحقيقي لازم يرجّع 401 بكل هالحالات.
  bool get isAuthError =>
      statusCode == 401 ||
      statusCode == 403 ||
      message.toLowerCase().contains('invalid token');

  @override
  String toString() => message;
}

class ApiClient {
  static const _timeout = Duration(seconds: 10);
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String url, {Map<String, String>? headers}) =>
      _send(() => _client.get(Uri.parse(url), headers: headers));

  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) => _send(
    () => _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(body),
    ),
  );

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on http.ClientException {
      throw const ApiException('No internet connection.');
    }

    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(text) ?? 'Server error (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    try {
      return jsonDecode(text);
    } on FormatException {
      throw const ApiException('Invalid response from server.');
    }
  }

  /// DummyJSON بيرجّع الأخطاء هيك: {"message": "Invalid credentials"}
  String? _errorMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    } catch (_) {}
    return null;
  }
}
