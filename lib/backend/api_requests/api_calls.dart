import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class ApinewsCall {
  static Future<ApiCallResponse> call({
    int? pageNumber = 1,
    int? pageSize = 10,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'apinews',
      apiUrl:
          'https://api.currentsapi.services/v1/search?keywords=diabetes&language=pt&apiKey=5hsonTmV-3m2FVENRjiXmZ90GHtBlB8Bn0_B7RoKJh4WbpOQ&page_number=${pageNumber}&page_size=${pageSize}',
      callType: ApiCallType.GET,
      headers: {
        'Key': 'apiKey Value: 5hsonTmV-3m2FVENRjiXmZ90GHtBlB8Bn0_B7RoKJh4WbpOQ',
      },
      params: {'page_number': pageNumber, 'page_size': 10},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? noticias(dynamic response) =>
      getJsonField(response, r'''$.news''', true) as List?;
  static List<String>? titulo(dynamic response) =>
      (getJsonField(response, r'''$.news[:].title''', true) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? descricao(dynamic response) =>
      (getJsonField(response, r'''$.news[:].description''', true) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? link(dynamic response) =>
      (getJsonField(response, r'''$.news[:].url''', true) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? image(dynamic response) =>
      (getJsonField(response, r'''$.news[:].image''', true) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class FlaskAPICall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'flaskAPI',
      apiUrl: 'http://127.0.0.1:5000/get_data',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
  static String? status(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.status'''));
}

class RegistrausuarioCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'registrausuario',
      apiUrl: 'http://127.0.0.1:5000/register',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
