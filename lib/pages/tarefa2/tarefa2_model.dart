import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'tarefa2_widget.dart' show Tarefa2Widget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class Tarefa2Model extends FlutterFlowModel<Tarefa2Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for CheckboxBanho widget.
  bool? checkboxBanhoValue;
  // State field(s) for CheckboxAgua widget.
  bool? checkboxAguaValue;
  // State field(s) for CheckboxSol widget.
  bool? checkboxSolValue;
  // State field(s) for CheckboxAtividadeFisica widget.
  bool? checkboxAtividadeFisicaValue;
  // State field(s) for CheckboxFrutas widget.
  bool? checkboxFrutasValue;
  // State field(s) for CheckboxSono widget.
  bool? checkboxSonoValue;
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
