import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/config/app_config.dart';

void main() {
  test('prod is recognised in any casing', () {
    expect(AppConfig.parse('prod'), AppEnv.prod);
    expect(AppConfig.parse('PROD'), AppEnv.prod);
    expect(AppConfig.parse(' Prod '), AppEnv.prod);
  });

  test('everything else falls back to dev', () {
    expect(AppConfig.parse('dev'), AppEnv.dev);
    expect(AppConfig.parse(''), AppEnv.dev);
    expect(AppConfig.parse('staging'), AppEnv.dev);
  });
}