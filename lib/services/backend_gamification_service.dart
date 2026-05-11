import 'dart:convert';

import 'package:http/http.dart' as http;

import '../backend/api_requests/api_manager.dart';
import '../config/api_config.dart';

class BackendGamificationSnapshot {
  const BackendGamificationSnapshot({
    required this.userId,
    required this.displayName,
    required this.schoolRoom,
    required this.xp,
    required this.coins,
    required this.streakDays,
    required this.dailySavedKwh,
    required this.totalSavedKwh,
    required this.co2AvoidedKg,
    required this.completedMissionKeys,
  });

  final String userId;
  final String displayName;
  final String schoolRoom;
  final int xp;
  final int coins;
  final int streakDays;
  final double dailySavedKwh;
  final double totalSavedKwh;
  final double co2AvoidedKg;
  final List<String> completedMissionKeys;

  factory BackendGamificationSnapshot.fromJson(Map<String, dynamic> json) {
    return BackendGamificationSnapshot(
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      schoolRoom: json['schoolRoom']?.toString() ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      dailySavedKwh: (json['dailySavedKwh'] as num?)?.toDouble() ?? 0,
      totalSavedKwh: (json['totalSavedKwh'] as num?)?.toDouble() ?? 0,
      co2AvoidedKg: (json['co2AvoidedKg'] as num?)?.toDouble() ?? 0,
      completedMissionKeys:
          (json['completedMissionKeys'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(),
    );
  }
}

class BackendGamificationService {
  BackendGamificationService._();

  static Future<BackendGamificationSnapshot> fetchMe() async {
    final response = await _send('GET', ApiConfig.gamificationMeUri);
    return _snapshotFromResponse(response);
  }

  static Future<BackendGamificationSnapshot> completeMission(
    String missionKey,
  ) async {
    final response = await _send(
      'POST',
      ApiConfig.gamificationCompleteMissionUri(missionKey),
    );
    return _snapshotFromResponse(response);
  }

  static Future<http.Response> _send(String method, Uri uri) async {
    final headers = <String, String>{...ApiConfig.DEFAULT_HEADERS};
    final token = ApiManager.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    switch (method) {
      case 'GET':
        return http
            .get(uri, headers: headers)
            .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      case 'POST':
        return http
            .post(uri, headers: headers)
            .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      default:
        throw UnsupportedError('Unsupported method: $method');
    }
  }

  static BackendGamificationSnapshot _snapshotFromResponse(
    http.Response response,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response.body));
    }

    final body = response.body.isNotEmpty ? response.body : '{}';
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return BackendGamificationSnapshot.fromJson(decoded);
  }

  static String _extractMessage(String body) {
    if (body.isEmpty) {
      return 'Falha ao carregar gamificação.';
    }

    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['message']?.toString() ?? 'Falha ao carregar gamificação.';
    } catch (_) {
      return 'Falha ao carregar gamificação.';
    }
  }
}
