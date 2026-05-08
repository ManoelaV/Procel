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
import 'bpnss_widget.dart' show BpnssWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BpnssModel extends FlutterFlowModel<BpnssWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Slider_bnps1 widget.
  double? sliderBnps1Value;
  // State field(s) for Slider_bnps2 widget.
  double? sliderBnps2Value;
  // State field(s) for Slider_bnps3 widget.
  double? sliderBnps3Value;
  // State field(s) for Slider_bnps4 widget.
  double? sliderBnps4Value;
  // State field(s) for Slider_bnps5 widget.
  double? sliderBnps5Value;
  // State field(s) for Slider_bnps6 widget.
  double? sliderBnps6Value;
  // State field(s) for Slider_bnps7 widget.
  double? sliderBnps7Value;
  // State field(s) for Slider_bnps8 widget.
  double? sliderBnps8Value;
  // State field(s) for Slider_bnps9 widget.
  double? sliderBnps9Value;
  // State field(s) for Slider_bnps10 widget.
  double? sliderBnps10Value;
  // State field(s) for Slider_bnps11 widget.
  double? sliderBnps11Value;
  // State field(s) for Slider_bnps12 widget.
  double? sliderBnps12Value;
  // State field(s) for Slider_bnps13 widget.
  double? sliderBnps13Value;
  // State field(s) for Slider_bnps14 widget.
  double? sliderBnps14Value;
  // State field(s) for Slider_bnps15 widget.
  double? sliderBnps15Value;
  // State field(s) for Slider_bnps16 widget.
  double? sliderBnps16Value;
  // State field(s) for Slider_bnps17 widget.
  double? sliderBnps17Value;
  // State field(s) for Slider_bnps18 widget.
  double? sliderBnps18Value;
  // State field(s) for Slider_bnps19 widget.
  double? sliderBnps19Value;
  // State field(s) for Slider_bnps20 widget.
  double? sliderBnps20Value;
  // State field(s) for Slider_bnps21 widget.
  double? sliderBnps21Value;
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
