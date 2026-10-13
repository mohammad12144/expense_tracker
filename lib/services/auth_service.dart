import '../models/auth_user.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  static const _base = 'https://dummyjson.com/auth';

  /// قصيرة عمدًا لتشوف الـ refresh بعينك. بالمشاريع الحقيقية 15 إلى 30 دقيقة.
  static const accessTokenMinutes = 1;

  final ApiClient _api;
  final TokenStorage storage;

  AuthService({required this._api, required this.storage});

  /// فيه جلسة محفوظة؟ (وجود refresh token)
  Future<bool> get isLoggedIn async => (await storage.refreshToken) != null;

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final data = await _api.post('$_base/login', {
      'username': username,
      'password': password,
      'expiresInMins': accessTokenMinutes,
    }) as Map<String, dynamic>;

    await storage.saveTokens(
      accessToken: (data['accessToken'] ?? data['token']) as String,
      refreshToken: data['refreshToken'] as String,
    );
    return AuthUser.fromJson(data);
  }

  Future<bool> refresh() async {
    final refreshToken = await storage.refreshToken;
    if (refreshToken == null) return false;
    try {
      final data = await _api.post('$_base/refresh', {
        'refreshToken': refreshToken,
        'expiresInMins': accessTokenMinutes,
      }) as Map<String, dynamic>;

      await storage.saveTokens(
        accessToken: (data['accessToken'] ?? data['token']) as String,
        refreshToken: (data['refreshToken'] as String?) ?? refreshToken,
      );
      return true;
    } on ApiException catch (e) {

      if (e.statusCode == null || (e.statusCode! >= 500 && !e.isAuthError)) {
        rethrow;
      }
      await storage.clear();
      return false;
    }
  }
  Future<void> logout() => storage.clear();
}