class AppConfig {
  AppConfig._();

  /// Production API by default; override for local development with:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.68:8000/api/v1/
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mis.dnpwc.gov.np/api/v1/',
  );
}
