import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'adicionar_meta_copy_widget.dart' show AdicionarMetaCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdicionarMetaCopyModel extends FlutterFlowModel<AdicionarMetaCopyWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Meta widget.
  FocusNode? metaFocusNode;
  TextEditingController? metaTextController;
  String? Function(BuildContext, String?)? metaTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    metaFocusNode?.dispose();
    metaTextController?.dispose();
  }
}
