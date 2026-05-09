// ignore_for_file: constant_identifier_names

/// Configurações de conexão com o Back-end
class ApiConfig {
  /// URL base da API
  /// 
  /// Pode ser sobrescrita usando:
  /// `flutter run --dart-define=API_BASE_URL=http://seu-url`
  static const String API_BASE_URL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Endpoints principais
  static const String LOGIN = '$API_BASE_URL/auth/login';
  static const String CADASTRO = '$API_BASE_URL/auth/cadastro';
  static const String SENSORES = '$API_BASE_URL/sensores';
  static const String MEDICOES = '$API_BASE_URL/medicoes';
  static const String USUARIOS = '$API_BASE_URL/usuarios';

  /// Timeout padrão para requisições (em segundos)
  static const int TIMEOUT_SECONDS = 30;

  /// Headers padrão
  static const Map<String, String> DEFAULT_HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Ambiente de execução
  static bool get isProduction => API_BASE_URL.contains('procel.servehttp.com');
  static bool get isDevelopment => API_BASE_URL.contains('localhost');

  /// Mensagem informativa do ambiente
  static String get environmentInfo {
    if (isProduction) {
      return 'Conectado ao servidor de PRODUÇÃO: $API_BASE_URL';
    } else if (isDevelopment) {
      return 'Conectado ao servidor LOCAL: $API_BASE_URL';
    } else {
      return 'Conectado a: $API_BASE_URL';
    }
  }
}
