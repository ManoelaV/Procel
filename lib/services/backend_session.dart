import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/api_requests/api_manager.dart';
import '../config/api_config.dart';

class BackendLoginResult {
  const BackendLoginResult({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.roles,
  });

  final String accessToken;
  final String tokenType;
  final String userId;
  final String email;
  final List<String> roles;

  factory BackendLoginResult.fromJson(Map<String, dynamic> json) {
    return BackendLoginResult(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
    );
  }
}

class BackendSession {
  BackendSession._();

  static const _tokenKey = 'procel_backend_access_token';

  static Future<String?> restoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    ApiManager.setAccessToken(token);
    return token;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    ApiManager.setAccessToken(token);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    ApiManager.clearAccessToken();
  }

  static Future<BackendLoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.loginUri,
      headers: ApiConfig.DEFAULT_HEADERS,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final bodyText = response.body.isNotEmpty ? response.body : '{}';
    final decoded = jsonDecode(bodyText) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message']?.toString() ?? 'Falha ao autenticar no back-end.',
      );
    }

    final result = BackendLoginResult.fromJson(decoded);
    if (result.accessToken.isNotEmpty) {
      await saveToken(result.accessToken);
    }
    return result;
  }
}
