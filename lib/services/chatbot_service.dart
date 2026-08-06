import 'dart:convert';

import 'package:http/http.dart' as http;

import '../backend/api_requests/api_manager.dart';
import '../config/api_config.dart';

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  final String role; // 'user' ou 'assistant'
  final String content;
  final DateTime? timestamp;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}

class ChatbotResponse {
  const ChatbotResponse({
    required this.sessionId,
    required this.reply,
    required this.provider,
    required this.model,
    this.contextSummary,
  });

  final String sessionId;
  final String reply;
  final String provider;
  final String model;
  final String? contextSummary;

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      sessionId:
          json['session_id']?.toString() ?? json['sessionId']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'unknown',
      model: json['model']?.toString() ?? 'unknown',
      contextSummary:
          json['context_summary']?.toString() ??
          json['contextSummary']?.toString(),
    );
  }
}

class Persona {
  const Persona({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id']?.toString() ?? json['persona_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['persona_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class TargetProfile {
  const TargetProfile({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory TargetProfile.fromJson(Map<String, dynamic> json) {
    return TargetProfile(
      id: json['id']?.toString() ?? json['profile_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['profile_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class ChatbotService {
  ChatbotService._();

  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(ApiConfig.chatbotHealthUri)
          .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Persona>> fetchPersonas() async {
    final response = await _send('GET', ApiConfig.chatbotPersonasUri);
    final decoded = _decodeResponseBody(response.body);

    if (decoded is List) {
      final personas = <Persona>[];
      for (final item in decoded as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          personas.add(Persona.fromJson(item));
        }
      }
      return personas;
    }

    return [];
  }

  static Future<List<TargetProfile>> fetchTargetProfiles() async {
    final response = await _send('GET', ApiConfig.chatbotTargetProfilesUri);
    final decoded = _decodeResponseBody(response.body);

    if (decoded is List) {
      final profiles = <TargetProfile>[];
      for (final item in decoded as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          profiles.add(TargetProfile.fromJson(item));
        }
      }
      return profiles;
    }

    return [];
  }

  static Future<ChatbotResponse> sendMessage({
    required String message,
    required String sessionId,
    String? personaId,
    String? targetProfileId,
    bool useRag = false,
  }) async {
    final body = <String, dynamic>{
      'message': message,
      'session_id': sessionId,
      if (personaId != null) 'persona_id': personaId,
      if (targetProfileId != null) 'target_profile_id': targetProfileId,
      'use_rag': useRag,
    };

    final response = await _send('POST', ApiConfig.chatbotChatUri, body: body);
    final decoded = _decodeResponseBody(response.body);
    return ChatbotResponse.fromJson(decoded);
  }

  static Future<ChatbotResponse> sendProactiveNotification({
    required String personaId,
    required String targetProfileId,
    required String notificationTypeId,
    required Map<String, dynamic> notificationContext,
    String? roomId,
    String? sensorExternalId,
    String? pessoaId,
    bool useRag = false,
  }) async {
    final body = <String, dynamic>{
      'persona_id': personaId,
      'target_profile_id': targetProfileId,
      'notification_type_id': notificationTypeId,
      'notification_context': notificationContext,
      if (roomId != null) 'room_id': roomId,
      if (sensorExternalId != null) 'sensor_external_id': sensorExternalId,
      if (pessoaId != null) 'pessoa_id': pessoaId,
      'use_rag': useRag,
    };

    final response = await _send(
      'POST',
      ApiConfig.chatbotProactiveUri,
      body: body,
    );
    final decoded = _decodeResponseBody(response.body);
    return ChatbotResponse.fromJson(decoded);
  }

  static Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{...ApiConfig.DEFAULT_HEADERS};

    final token = ApiManager.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final encodedBody = body != null ? jsonEncode(body) : null;

    switch (method) {
      case 'GET':
        return http
            .get(uri, headers: headers)
            .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      case 'POST':
        return http
            .post(uri, headers: headers, body: encodedBody)
            .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      default:
        throw UnsupportedError('Unsupported method: $method');
    }
  }

  static Map<String, dynamic> _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}
