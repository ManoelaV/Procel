// ignore_for_file: constant_identifier_names

/// Configurações de conexão com o back-end.
class ApiConfig {
  /// URL base da API.
  ///
  /// Pode ser sobrescrita usando:
  /// `flutter run --dart-define=API_BASE_URL=http://seu-url`
  static const String API_BASE_URL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Prefixo comum do back-end Java.
  static const String API_PREFIX = '/api';

  /// Timeout padrão para requisições (em segundos).
  static const int TIMEOUT_SECONDS = 30;

  /// Headers padrão.
  static const Map<String, String> DEFAULT_HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String get _normalizedBaseUrl => API_BASE_URL.endsWith('/')
      ? API_BASE_URL.substring(0, API_BASE_URL.length - 1)
      : API_BASE_URL;

  static Uri _uri(String path) =>
      Uri.parse('$_normalizedBaseUrl$API_PREFIX$path');

  /// Endpoints principais do back-end.
  static Uri get loginUri => _uri('/auth/login');
  static Uri get registerUri => _uri('/auth/register');
  static Uri get healthUri => Uri.parse('$_normalizedBaseUrl/actuator/health');
  static Uri get pessoasUri => _uri('/pessoas');
  static Uri get gamificationMeUri => _uri('/gamification/me');
  static Uri gamificationCompleteMissionUri(String missionKey) =>
      _uri('/gamification/me/missions/$missionKey/complete');
  static Uri get sensoresUri => _uri('/sensors');
  static Uri get roomsUri => _uri('/rooms');
  static Uri medicoesBySensorUri(String sensorExternalId) =>
      _uri('/sensors/$sensorExternalId/medicoes');
  static Uri medicoesLatestBySensorUri(String sensorExternalId) =>
      _uri('/sensors/$sensorExternalId/medicoes/latest');
  static Uri medicoesByRoomUri(String roomId) =>
      _uri('/rooms/$roomId/medicoes');
  static Uri medicoesLatestByRoomUri(String roomId) =>
      _uri('/rooms/$roomId/medicoes/latest');
  static Uri get presencasUri => _uri('/presencas');
  static Uri get regrasUri => _uri('/rules');

  /// Ambiente de execução.
  static bool get isProduction =>
      _normalizedBaseUrl.contains('procel.servehttp.com');
  static bool get isDevelopment => _normalizedBaseUrl.contains('localhost');

  /// Mensagem informativa do ambiente.
  static String get environmentInfo {
    if (isProduction) {
      return 'Conectado ao servidor de PRODUÇÃO: $_normalizedBaseUrl';
    } else if (isDevelopment) {
      return 'Conectado ao servidor LOCAL: $_normalizedBaseUrl';
    }
    return 'Conectado a: $_normalizedBaseUrl';
  }
}
