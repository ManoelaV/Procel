import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class BackendHealthResult {
  const BackendHealthResult({
    required this.status,
    required this.ok,
    required this.rawBody,
  });

  final String status;
  final bool ok;
  final String rawBody;

  factory BackendHealthResult.fromResponse(http.Response response) {
    final body = response.body.trim();
    String status = response.statusCode >= 200 && response.statusCode < 300
        ? 'UP'
        : 'DOWN';

    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final rawStatus = decoded['status'];
          if (rawStatus != null) {
            status = rawStatus.toString();
          }
        }
      } catch (_) {
        // Mantém o status inferido pelo HTTP quando o corpo não é JSON.
      }
    }

    return BackendHealthResult(
      status: status,
      ok: response.statusCode >= 200 && response.statusCode < 300,
      rawBody: body,
    );
  }

  factory BackendHealthResult.error(Object error) {
    return BackendHealthResult(
      status: 'OFFLINE',
      ok: false,
      rawBody: error.toString(),
    );
  }
}

class BackendHealthService {
  BackendHealthService._();

  static Future<BackendHealthResult> check() async {
    try {
      final response = await http
          .get(ApiConfig.healthUri, headers: ApiConfig.DEFAULT_HEADERS)
          .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      return BackendHealthResult.fromResponse(response);
    } catch (error) {
      return BackendHealthResult.error(error);
    }
  }
}
