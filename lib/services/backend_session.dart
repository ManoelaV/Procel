import 'dart:async';
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
    final pessoa = json['pessoa'] is Map<String, dynamic>
        ? json['pessoa'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return BackendLoginResult(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          json['token'] as String? ??
          json['authToken'] as String? ??
          json['auth_token'] as String? ??
          json['jwtToken'] as String? ??
          json['jwt_token'] as String? ??
          '',
      tokenType:
          json['tokenType'] as String? ??
          json['token_type'] as String? ??
          'Bearer',
      userId:
          json['userId'] as String? ??
          json['user_id'] as String? ??
          json['id'] as String? ??
          pessoa['userId'] as String? ??
          pessoa['id'] as String? ??
          '',
      email: json['email'] as String? ?? pessoa['email'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
    );
  }
}

class BackendSession {
  BackendSession._();

  static const _tokenKey = 'procel_backend_access_token';
  static const _userIdKey = 'backend_user_id';
  static const _emailKey = 'backend_email';
  static const _displayNameKey = 'backend_display_name';

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

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<void> saveDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, displayName);
  }

  static Future<String?> restoreUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<bool> hasCompleteSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getString(_userIdKey);
    final hasSession =
        token != null &&
        token.isNotEmpty &&
        !_isExpiredJwt(token) &&
        userId != null &&
        userId.isNotEmpty;

    ApiManager.setAccessToken(hasSession ? token : null);
    return hasSession;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_displayNameKey);
    ApiManager.clearAccessToken();
  }

  static Future<BackendLoginResult> login({
    required String email,
    required String password,
  }) async {
    await clear();

    final http.Response response;
    try {
      response = await http
          .post(
            ApiConfig.loginUri,
            headers: ApiConfig.DEFAULT_HEADERS,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
    } on TimeoutException {
      throw Exception(
        'Back-end indisponivel. Verifique se a API esta rodando.',
      );
    } on http.ClientException {
      throw Exception(
        'Back-end indisponivel. Verifique se a API esta rodando.',
      );
    }

    final decoded = _decodeResponseBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message']?.toString() ?? 'Falha ao autenticar no back-end.',
      );
    }

    final result = BackendLoginResult.fromJson(decoded);
    if (result.accessToken.isEmpty) {
      throw Exception('Login aceito, mas o back-end não retornou um token.');
    }
    await saveToken(result.accessToken);

    if (result.userId.isEmpty) {
      await clear();
      throw Exception('Login aceito, mas o back-end nÃ£o retornou o usuario.');
    }

    await saveUserId(result.userId);
    if (result.email.isNotEmpty) {
      await saveEmail(result.email);
      await saveDisplayName(result.email.split('@').first);
    }
    return result;
  }

  static Future<BackendLoginResult> registerAndLogin({
    required String nome,
    required String email,
    required String userId,
    required String password,
    String? telefone,
    String? matricula,
  }) async {
    await clear();

    final http.Response response;
    try {
      response = await http
          .post(
            ApiConfig.registerUri,
            headers: ApiConfig.DEFAULT_HEADERS,
            body: jsonEncode({
              'nome': nome,
              'email': email,
              'userId': userId,
              'password': password,
              'telefone': telefone,
              'matricula': matricula,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
    } on TimeoutException {
      throw Exception(
        'Back-end indisponivel. Verifique se a API esta rodando.',
      );
    } on http.ClientException {
      throw Exception(
        'Back-end indisponivel. Verifique se a API esta rodando.',
      );
    }

    final decoded = _decodeResponseBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message']?.toString() ?? 'Falha ao cadastrar usuario.',
      );
    }

    return login(email: email, password: password);
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

  static bool _isExpiredJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return true;
      }

      final exp = decoded['exp'];
      final expSeconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
      if (expSeconds == null) {
        return true;
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        expSeconds * 1000,
        isUtc: true,
      );
      return !expiresAt.isAfter(DateTime.now().toUtc());
    } catch (_) {
      return true;
    }
  }
}
