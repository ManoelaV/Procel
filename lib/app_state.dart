import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  double _SliderBemEstarHojeVar = 1.5;
  double get SliderBemEstarHojeVar => _SliderBemEstarHojeVar;
  set SliderBemEstarHojeVar(double value) {
    _SliderBemEstarHojeVar = value;
  }

  bool _CheckBanhoVar = false;
  bool get CheckBanhoVar => _CheckBanhoVar;
  set CheckBanhoVar(bool value) {
    _CheckBanhoVar = value;
  }

  bool _CheckAguaVar = false;
  bool get CheckAguaVar => _CheckAguaVar;
  set CheckAguaVar(bool value) {
    _CheckAguaVar = value;
  }

  bool _CheckSolVar = false;
  bool get CheckSolVar => _CheckSolVar;
  set CheckSolVar(bool value) {
    _CheckSolVar = value;
  }

  bool _CheckAtividadeFisicaVar = false;
  bool get CheckAtividadeFisicaVar => _CheckAtividadeFisicaVar;
  set CheckAtividadeFisicaVar(bool value) {
    _CheckAtividadeFisicaVar = value;
  }

  bool _CheckFrutasVar = false;
  bool get CheckFrutasVar => _CheckFrutasVar;
  set CheckFrutasVar(bool value) {
    _CheckFrutasVar = value;
  }

  bool _CheckSonoVar = false;
  bool get CheckSonoVar => _CheckSonoVar;
  set CheckSonoVar(bool value) {
    _CheckSonoVar = value;
  }

  int _Tempo = 0;
  int get Tempo => _Tempo;
  set Tempo(int value) {
    _Tempo = value;
  }

  bool _logRegistrado = false;
  bool get logRegistrado => _logRegistrado;
  set logRegistrado(bool value) {
    _logRegistrado = value;
  }

  DocumentReference? _lastLogged;
  DocumentReference? get lastLogged => _lastLogged;
  set lastLogged(DocumentReference? value) {
    _lastLogged = value;
  }

  String _noticiasPaginaAtual = '';
  String get noticiasPaginaAtual => _noticiasPaginaAtual;
  set noticiasPaginaAtual(String value) {
    _noticiasPaginaAtual = value;
  }
}
