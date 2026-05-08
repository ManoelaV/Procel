import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class QuestionarioRecord extends FirestoreRecord {
  QuestionarioRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Id_usuario" field.
  String? _idUsuario;
  String get idUsuario => _idUsuario ?? '';
  bool hasIdUsuario() => _idUsuario != null;

  // "data_submissao" field.
  DateTime? _dataSubmissao;
  DateTime? get dataSubmissao => _dataSubmissao;
  bool hasDataSubmissao() => _dataSubmissao != null;

  // "bem_estar" field.
  String? _bemEstar;
  String get bemEstar => _bemEstar ?? '';
  bool hasBemEstar() => _bemEstar != null;

  // "saude_tomou_banho" field.
  bool? _saudeTomouBanho;
  bool get saudeTomouBanho => _saudeTomouBanho ?? false;
  bool hasSaudeTomouBanho() => _saudeTomouBanho != null;

  // "saude_bebeu_agua" field.
  bool? _saudeBebeuAgua;
  bool get saudeBebeuAgua => _saudeBebeuAgua ?? false;
  bool hasSaudeBebeuAgua() => _saudeBebeuAgua != null;

  // "saude_pegou_sol" field.
  bool? _saudePegouSol;
  bool get saudePegouSol => _saudePegouSol ?? false;
  bool hasSaudePegouSol() => _saudePegouSol != null;

  // "saude_atividade_fisica" field.
  bool? _saudeAtividadeFisica;
  bool get saudeAtividadeFisica => _saudeAtividadeFisica ?? false;
  bool hasSaudeAtividadeFisica() => _saudeAtividadeFisica != null;

  // "saude_ingeriu_frutas" field.
  bool? _saudeIngeriuFrutas;
  bool get saudeIngeriuFrutas => _saudeIngeriuFrutas ?? false;
  bool hasSaudeIngeriuFrutas() => _saudeIngeriuFrutas != null;

  // "saude_dormiu_bem" field.
  bool? _saudeDormiuBem;
  bool get saudeDormiuBem => _saudeDormiuBem ?? false;
  bool hasSaudeDormiuBem() => _saudeDormiuBem != null;

  // "lazer_assistiu_filme" field.
  bool? _lazerAssistiuFilme;
  bool get lazerAssistiuFilme => _lazerAssistiuFilme ?? false;
  bool hasLazerAssistiuFilme() => _lazerAssistiuFilme != null;

  // "lazer_viu_amigos" field.
  bool? _lazerViuAmigos;
  bool get lazerViuAmigos => _lazerViuAmigos ?? false;
  bool hasLazerViuAmigos() => _lazerViuAmigos != null;

  // "lazer_leu_livro" field.
  bool? _lazerLeuLivro;
  bool get lazerLeuLivro => _lazerLeuLivro ?? false;
  bool hasLazerLeuLivro() => _lazerLeuLivro != null;

  // "lazer_ouviu_musica" field.
  bool? _lazerOuviuMusica;
  bool get lazerOuviuMusica => _lazerOuviuMusica ?? false;
  bool hasLazerOuviuMusica() => _lazerOuviuMusica != null;

  // "lazer_atividade_prazerosa" field.
  bool? _lazerAtividadePrazerosa;
  bool get lazerAtividadePrazerosa => _lazerAtividadePrazerosa ?? false;
  bool hasLazerAtividadePrazerosa() => _lazerAtividadePrazerosa != null;

  void _initializeFields() {
    _idUsuario = snapshotData['Id_usuario'] as String?;
    _dataSubmissao = snapshotData['data_submissao'] as DateTime?;
    _bemEstar = snapshotData['bem_estar'] as String?;
    _saudeTomouBanho = snapshotData['saude_tomou_banho'] as bool?;
    _saudeBebeuAgua = snapshotData['saude_bebeu_agua'] as bool?;
    _saudePegouSol = snapshotData['saude_pegou_sol'] as bool?;
    _saudeAtividadeFisica = snapshotData['saude_atividade_fisica'] as bool?;
    _saudeIngeriuFrutas = snapshotData['saude_ingeriu_frutas'] as bool?;
    _saudeDormiuBem = snapshotData['saude_dormiu_bem'] as bool?;
    _lazerAssistiuFilme = snapshotData['lazer_assistiu_filme'] as bool?;
    _lazerViuAmigos = snapshotData['lazer_viu_amigos'] as bool?;
    _lazerLeuLivro = snapshotData['lazer_leu_livro'] as bool?;
    _lazerOuviuMusica = snapshotData['lazer_ouviu_musica'] as bool?;
    _lazerAtividadePrazerosa =
        snapshotData['lazer_atividade_prazerosa'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Questionario');

  static Stream<QuestionarioRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => QuestionarioRecord.fromSnapshot(s));

  static Future<QuestionarioRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => QuestionarioRecord.fromSnapshot(s));

  static QuestionarioRecord fromSnapshot(DocumentSnapshot snapshot) =>
      QuestionarioRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static QuestionarioRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      QuestionarioRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'QuestionarioRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is QuestionarioRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createQuestionarioRecordData({
  String? idUsuario,
  DateTime? dataSubmissao,
  String? bemEstar,
  bool? saudeTomouBanho,
  bool? saudeBebeuAgua,
  bool? saudePegouSol,
  bool? saudeAtividadeFisica,
  bool? saudeIngeriuFrutas,
  bool? saudeDormiuBem,
  bool? lazerAssistiuFilme,
  bool? lazerViuAmigos,
  bool? lazerLeuLivro,
  bool? lazerOuviuMusica,
  bool? lazerAtividadePrazerosa,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Id_usuario': idUsuario,
      'data_submissao': dataSubmissao,
      'bem_estar': bemEstar,
      'saude_tomou_banho': saudeTomouBanho,
      'saude_bebeu_agua': saudeBebeuAgua,
      'saude_pegou_sol': saudePegouSol,
      'saude_atividade_fisica': saudeAtividadeFisica,
      'saude_ingeriu_frutas': saudeIngeriuFrutas,
      'saude_dormiu_bem': saudeDormiuBem,
      'lazer_assistiu_filme': lazerAssistiuFilme,
      'lazer_viu_amigos': lazerViuAmigos,
      'lazer_leu_livro': lazerLeuLivro,
      'lazer_ouviu_musica': lazerOuviuMusica,
      'lazer_atividade_prazerosa': lazerAtividadePrazerosa,
    }.withoutNulls,
  );

  return firestoreData;
}

class QuestionarioRecordDocumentEquality
    implements Equality<QuestionarioRecord> {
  const QuestionarioRecordDocumentEquality();

  @override
  bool equals(QuestionarioRecord? e1, QuestionarioRecord? e2) {
    return e1?.idUsuario == e2?.idUsuario &&
        e1?.dataSubmissao == e2?.dataSubmissao &&
        e1?.bemEstar == e2?.bemEstar &&
        e1?.saudeTomouBanho == e2?.saudeTomouBanho &&
        e1?.saudeBebeuAgua == e2?.saudeBebeuAgua &&
        e1?.saudePegouSol == e2?.saudePegouSol &&
        e1?.saudeAtividadeFisica == e2?.saudeAtividadeFisica &&
        e1?.saudeIngeriuFrutas == e2?.saudeIngeriuFrutas &&
        e1?.saudeDormiuBem == e2?.saudeDormiuBem &&
        e1?.lazerAssistiuFilme == e2?.lazerAssistiuFilme &&
        e1?.lazerViuAmigos == e2?.lazerViuAmigos &&
        e1?.lazerLeuLivro == e2?.lazerLeuLivro &&
        e1?.lazerOuviuMusica == e2?.lazerOuviuMusica &&
        e1?.lazerAtividadePrazerosa == e2?.lazerAtividadePrazerosa;
  }

  @override
  int hash(QuestionarioRecord? e) => const ListEquality().hash([
        e?.idUsuario,
        e?.dataSubmissao,
        e?.bemEstar,
        e?.saudeTomouBanho,
        e?.saudeBebeuAgua,
        e?.saudePegouSol,
        e?.saudeAtividadeFisica,
        e?.saudeIngeriuFrutas,
        e?.saudeDormiuBem,
        e?.lazerAssistiuFilme,
        e?.lazerViuAmigos,
        e?.lazerLeuLivro,
        e?.lazerOuviuMusica,
        e?.lazerAtividadePrazerosa
      ]);

  @override
  bool isValidKey(Object? o) => o is QuestionarioRecord;
}
