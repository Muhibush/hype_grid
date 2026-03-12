enum AppEnvironment {
  dev,
  prod,
}

class Environment {
  static AppEnvironment _current = AppEnvironment.dev;

  static AppEnvironment get current => _current;

  static void setEnvironment(AppEnvironment env) {
    _current = env;
  }

  static String get envFileName {
    switch (_current) {
      case AppEnvironment.prod:
        return '.env.prod';
      case AppEnvironment.dev:
        return '.env.dev';
    }
  }

  static bool get isDev => _current == AppEnvironment.dev;
  static bool get isProd => _current == AppEnvironment.prod;
}
