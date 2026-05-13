import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'redefinicao_senha_widget.dart' show RedefinicaoSenhaWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class RedefinicaoSenhaModel extends FlutterFlowModel<RedefinicaoSenhaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for email_cadastrado widget.
  FocusNode? emailCadastradoFocusNode;
  TextEditingController? emailCadastradoTextController;
  String? Function(BuildContext, String?)?
  emailCadastradoTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? emailCadastrado;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailCadastradoFocusNode?.dispose();
    emailCadastradoTextController?.dispose();
  }
}
