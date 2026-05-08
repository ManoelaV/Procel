import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

Future updateTempoDeUso(BuildContext context) async {
  await FFAppState().lastLogged!.update(createLoginDiarioRecordData(
        tempo: FFAppState().Tempo,
      ));
}

Future updateAppStateTimer(BuildContext context) async {
  FFAppState().Tempo = FFAppState().Tempo + 1;
}

Future<LoginDiarioRecord?> lastlogged(BuildContext context) async {
  LoginDiarioRecord? lastLogged;

  lastLogged = await queryLoginDiarioRecordOnce(
    queryBuilder: (loginDiarioRecord) => loginDiarioRecord
        .where(
          'id_usuario',
          isEqualTo: currentUserReference?.id,
        )
        .orderBy('data', descending: true),
    singleRecord: true,
  ).then((s) => s.firstOrNull);

  return null;
}
