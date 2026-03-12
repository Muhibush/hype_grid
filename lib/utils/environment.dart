enum AppEnvironment {
  dev,
  prod,
}

class Environment {
  static const String _env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static AppEnvironment get current => 
      _env == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;

  static String get envFileName => 'env.$_env';

  static bool get isDev => current == AppEnvironment.dev;
  static bool get isProd => current == AppEnvironment.prod;
}
