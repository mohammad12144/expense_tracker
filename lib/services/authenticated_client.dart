import 'package:flutter/foundation.dart';
import 'package:expense_tracker/services/api_client.dart';
import 'package:expense_tracker/services/token_storage.dart';

class AuthenticatedClient {
  final ApiClient _api;
  final TokenStorage _storage;
  final Future<bool> Function() _refresh;
  final VoidCallback _onSessionExpired;

  Future<bool>? _refreshing;

   AuthenticatedClient({
    required this._api,
    required this._storage,
    required this._refresh,
    required this._onSessionExpired,
  });

  Future<dynamic> get(String url) =>
      _withAuth((headers) => _api.get(url, headers: headers));

  Future<dynamic> post(String url, Map<String, dynamic> body) =>
      _withAuth((headers) => _api.post(url, body, headers: headers));

  Future<dynamic> _withAuth(
    Future<dynamic> Function(Map<String, String> headers) call,
  ) async {
    try {
      return await call(await _headers());
    } on ApiException catch (e) {
      if (!e.isAuthError) rethrow;

      debugPrint('[auth] ${e.statusCode} -> refreshing token...');
      final refreshed = await _refreshOnce();
      if (!refreshed) {
        debugPrint('[auth] refresh rejected -> session expired');
        _onSessionExpired();
        throw const ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      debugPrint('[auth] token refreshed -> retrying request');
      return await call(await _headers()); // إعادة واحدة فقط
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await _storage.accessToken;
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<bool> _refreshOnce() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
}