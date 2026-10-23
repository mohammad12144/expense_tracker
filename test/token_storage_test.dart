import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('saves and reads tokens', () async {
    final storage = TokenStorage();
    await storage.saveTokens(accessToken: 'a1', refreshToken: 'r1');

    expect(await storage.accessToken, 'a1');
    expect(await storage.refreshToken, 'r1');
  });

  test('saveAccessToken only updates the access token', () async {
    final storage = TokenStorage();
    await storage.saveTokens(accessToken: 'a1', refreshToken: 'r1');
    await storage.saveAccessToken('a2');

    expect(await storage.accessToken, 'a2');
    expect(await storage.refreshToken, 'r1');
  });

  test('clear removes both tokens', () async {
    final storage = TokenStorage();
    await storage.saveTokens(accessToken: 'a1', refreshToken: 'r1');
    await storage.clear();

    expect(await storage.accessToken, isNull);
    expect(await storage.refreshToken, isNull);
  });
}
