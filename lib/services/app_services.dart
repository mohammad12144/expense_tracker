import 'package:flutter/material.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'authenticated_client.dart';
import 'token_storage.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

final _apiClient = ApiClient();
final tokenStorage = TokenStorage();
final authService = AuthService(api: _apiClient, storage: tokenStorage);

final authedApi = AuthenticatedClient(
  api: _apiClient,
  storage: tokenStorage,
  refresh: authService.refresh,
  onSessionExpired: _sessionExpired,
);

void _sessionExpired() {
  messengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      const SnackBar(content: Text('Session expired. Please log in again.')),
    );
  navigatorKey.currentState
      ?.pushNamedAndRemoveUntil('/login', (route) => false);
}