// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

/// Configurações de conexão com o back-end.
class ApiConfig {
  /// URL base da API.
  ///
  /// Pode ser sobrescrita usando:
  /// `flutter run --dart-define=API_BASE_URL=http://seu-url`
  static const String API_BASE_URL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
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

  static String get _resolvedBaseUrl {
    if (API_BASE_URL.isNotEmpty) {
      return API_BASE_URL;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8080';
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return 'http://localhost:8080';
    }
  }

  static String get _normalizedBaseUrl => _resolvedBaseUrl.endsWith('/')
      ? _resolvedBaseUrl.substring(0, _resolvedBaseUrl.length - 1)
      : _resolvedBaseUrl;

  /// URL base pública para uso em services
  static String get baseUrl => _normalizedBaseUrl;

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

  /// ============================================================
  /// Configurações do Chatbot de Notificações
  /// ============================================================

  /// URL base do chatbot (porta 8000)
  static const String CHATBOT_BASE_URL = 'http://localhost:8000';

  /// Endpoints do chatbot
  static Uri get chatbotHealthUri => Uri.parse('$CHATBOT_BASE_URL/health');
  static Uri get chatbotChatUri => Uri.parse('$CHATBOT_BASE_URL/chat');
  static Uri get chatbotProactiveUri =>
      Uri.parse('$CHATBOT_BASE_URL/chat/proactive');
  static Uri get chatbotPersonasUri => Uri.parse('$CHATBOT_BASE_URL/personas');
  static Uri get chatbotTargetProfilesUri =>
      Uri.parse('$CHATBOT_BASE_URL/target-profiles');
  static Uri get chatbotNotificationsUri =>
      Uri.parse('$CHATBOT_BASE_URL/notifications/saved');

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
