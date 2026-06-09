import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../backend/api_requests/api_manager.dart';
import '../config/api_config.dart';
import '../models/room_model.dart';

class RoomsService {
  /// Tenta buscar a lista de salas no back-end.
  /// Retorna lista vazia se o endpoint não existir ou falhar.
  static Future<List<Room>> fetchRoomsFromBackend() async {
    try {
      final resp = await ApiManager.instance.makeApiCall(
        callName: 'rooms_list',
        apiUrl: ApiConfig.roomsUri.toString(),
        callType: ApiCallType.GET,
        headers: ApiConfig.DEFAULT_HEADERS,
        params: {},
        returnBody: true,
        decodeUtf8: true,
      );

      if (!resp.succeeded || resp.jsonBody == null) {
        return [];
      }

      final body = resp.jsonBody;
      // Pode ser lista direta ou objeto com chave
      List items = [];
      if (body is List) {
        items = body;
      } else if (body is Map) {
        if (body['rooms'] is List)
          items = body['rooms'];
        else if (body['compartimentos'] is List)
          items = body['compartimentos'];
        else if (body['data'] is List)
          items = body['data'];
      }

      return items
          .map((e) => Room.fromJson(e is String ? json.decode(e) : e))
          .toList();
    } catch (e) {
      if (kDebugMode) print('RoomsService.fetchRoomsFromBackend error: $e');
      return [];
    }
  }

  /// Fallback: busca a lista de salas diretamente da fonte Cobalto.
  /// Retorna o corpo bruto (HTML/JSON) para processamento posterior.
  static Future<String?> fetchRoomsFromCobaltoRaw() async {
    try {
      final cobaltoUrl =
          'https://cobalto.ufpel.edu.br/servicosgerais/consultas/salasDeAula/listaSalas/?rows=-1';
      final resp = await ApiManager.instance.makeApiCall(
        callName: 'cobalto_rooms',
        apiUrl: cobaltoUrl,
        callType: ApiCallType.GET,
        headers: {},
        params: {},
        returnBody: true,
        decodeUtf8: true,
      );

      if (!resp.succeeded) return null;
      if (resp.jsonBody is String) return resp.jsonBody as String;
      try {
        return json.encode(resp.jsonBody);
      } catch (_) {
        return resp.jsonBody.toString();
      }
    } catch (e) {
      if (kDebugMode) print('RoomsService.fetchRoomsFromCobaltoRaw error: $e');
      return null;
    }
  }
}
