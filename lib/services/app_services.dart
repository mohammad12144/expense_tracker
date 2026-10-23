import 'package:flutter/material.dart';
import 'package:expense_tracker/services/api_client.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/authenticated_client.dart';
import 'package:expense_tracker/services/token_storage.dart';

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
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    '/login',
    (route) => false,
  );
}
