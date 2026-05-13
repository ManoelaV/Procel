import '/flutter_flow/flutter_flow_util.dart';
import 'adicionar_meta_copy_widget.dart' show AdicionarMetaCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
