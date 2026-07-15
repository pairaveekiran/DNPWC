class AppConfig {
  AppConfig._();

  static const String
  baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'http://192.168.1.68:8000/api/v1/',
  );
}
