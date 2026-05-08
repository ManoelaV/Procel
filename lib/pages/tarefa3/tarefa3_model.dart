import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'tarefa3_widget.dart' show Tarefa3Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class Tarefa3Model extends FlutterFlowModel<Tarefa3Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for CheckboxFilmeSerie widget.
  bool? checkboxFilmeSerieValue;
  // State field(s) for CheckboxAmigos widget.
  bool? checkboxAmigosValue;
  // State field(s) for CheckboxLeu widget.
  bool? checkboxLeuValue;
  // State field(s) for CheckboxMusica widget.
  bool? checkboxMusicaValue;
  // State field(s) for CheckboxPrazer widget.
  bool? checkboxPrazerValue;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  QuestionarioRecord? ultimoQuestionario;
  // State field(s) for Timer widget.
  final timerInitialTimeMs = 1000;
  int timerMilliseconds = 1000;
  String timerValue = StopWatchTimer.getDisplayTime(
    1000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerController.dispose();
  }
}
