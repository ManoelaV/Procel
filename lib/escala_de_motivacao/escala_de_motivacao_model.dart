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
import 'escala_de_motivacao_widget.dart' show EscalaDeMotivacaoWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EscalaDeMotivacaoModel extends FlutterFlowModel<EscalaDeMotivacaoWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Slider_sims1 widget.
  double? sliderSims1Value;
  // State field(s) for Slider_sims2 widget.
  double? sliderSims2Value;
  // State field(s) for Slider_sims3 widget.
  double? sliderSims3Value;
  // State field(s) for Slider_sims4 widget.
  double? sliderSims4Value;
  // State field(s) for Slider_sims5 widget.
  double? sliderSims5Value;
  // State field(s) for Slider_sims6 widget.
  double? sliderSims6Value;
  // State field(s) for Slider_sims7 widget.
  double? sliderSims7Value;
  // State field(s) for Slider_sims8 widget.
  double? sliderSims8Value;
  // State field(s) for Slider_sims9 widget.
  double? sliderSims9Value;
  // State field(s) for Slider_sims10 widget.
  double? sliderSims10Value;
  // State field(s) for Slider_sims11 widget.
  double? sliderSims11Value;
  // State field(s) for Slider_sims12 widget.
  double? sliderSims12Value;
  // State field(s) for Slider_sims13 widget.
  double? sliderSims13Value;
  // State field(s) for Slider_sims14 widget.
  double? sliderSims14Value;
  // State field(s) for Slider_sims15 widget.
  double? sliderSims15Value;
  // State field(s) for Slider_sims16 widget.
  double? sliderSims16Value;
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
