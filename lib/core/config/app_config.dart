enum AppEnv { dev, prod }

/// Build-time configuration. Set with: --dart-define=ENV=prod
class AppConfig {
  static const String _raw = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// Anything that is not exactly "prod" is treated as dev (the safe default).
  static AppEnv parse(String value) =>
      value.trim().toLowerCase() == 'prod' ? AppEnv.prod : AppEnv.dev;

  static AppEnv get env => parse(_raw);

  static bool get isProd => env == AppEnv.prod;

  static String get appName =>
      isProd ? 'Expense Tracker' : 'Expense Tracker DEV';
}
