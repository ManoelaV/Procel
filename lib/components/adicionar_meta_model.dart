import '/flutter_flow/flutter_flow_util.dart';
import 'adicionar_meta_widget.dart' show AdicionarMetaWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdicionarMetaModel extends FlutterFlowModel<AdicionarMetaWidget> {
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
