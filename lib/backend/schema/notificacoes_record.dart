import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificacoesRecord extends FirestoreRecord {
  NotificacoesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "titulo" field.
  String? _titulo;
  String get titulo => _titulo ?? '';
  bool hasTitulo() => _titulo != null;

  // "corpo" field.
  String? _corpo;
  String get corpo => _corpo ?? '';
  bool hasCorpo() => _corpo != null;

  // "respondido" field.
  bool? _respondido;
  bool get respondido => _respondido ?? false;
  bool hasRespondido() => _respondido != null;

  // "gostou" field.
  bool? _gostou;
  bool get gostou => _gostou ?? false;
  bool hasGostou() => _gostou != null;

  // "id_usuario" field.
  DocumentReference? _idUsuario;
  DocumentReference? get idUsuario => _idUsuario;
  bool hasIdUsuario() => _idUsuario != null;

  // "retornonotificacao" field.
  bool? _retornonotificacao;
  bool get retornonotificacao => _retornonotificacao ?? false;
  bool hasRetornonotificacao() => _retornonotificacao != null;

  // "idMensagem" field.
  String? _idMensagem;
  String get idMensagem => _idMensagem ?? '';
  bool hasIdMensagem() => _idMensagem != null;

  // "email" field.
  DocumentReference? _email;
  DocumentReference? get email => _email;
  bool hasEmail() => _email != null;

  // "ngostou" field.
  bool? _ngostou;
  bool get ngostou => _ngostou ?? false;
  bool hasNgostou() => _ngostou != null;

  void _initializeFields() {
    _data = snapshotData['data'] as DateTime?;
    _titulo = snapshotData['titulo'] as String?;
    _corpo = snapshotData['corpo'] as String?;
    _respondido = snapshotData['respondido'] as bool?;
    _gostou = snapshotData['gostou'] as bool?;
    _idUsuario = snapshotData['id_usuario'] as DocumentReference?;
    _retornonotificacao = snapshotData['retornonotificacao'] as bool?;
    _idMensagem = snapshotData['idMensagem'] as String?;
    _email = snapshotData['email'] as DocumentReference?;
    _ngostou = snapshotData['ngostou'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notificacoes');

  static Stream<NotificacoesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificacoesRecord.fromSnapshot(s));

  static Future<NotificacoesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificacoesRecord.fromSnapshot(s));

  static NotificacoesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificacoesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificacoesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificacoesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificacoesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificacoesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificacoesRecordData({
  DateTime? data,
  String? titulo,
  String? corpo,
  bool? respondido,
  bool? gostou,
  DocumentReference? idUsuario,
  bool? retornonotificacao,
  String? idMensagem,
  DocumentReference? email,
  bool? ngostou,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'data': data,
      'titulo': titulo,
      'corpo': corpo,
      'respondido': respondido,
      'gostou': gostou,
      'id_usuario': idUsuario,
      'retornonotificacao': retornonotificacao,
      'idMensagem': idMensagem,
      'email': email,
      'ngostou': ngostou,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificacoesRecordDocumentEquality
    implements Equality<NotificacoesRecord> {
  const NotificacoesRecordDocumentEquality();

  @override
  bool equals(NotificacoesRecord? e1, NotificacoesRecord? e2) {
    return e1?.data == e2?.data &&
        e1?.titulo == e2?.titulo &&
        e1?.corpo == e2?.corpo &&
        e1?.respondido == e2?.respondido &&
        e1?.gostou == e2?.gostou &&
        e1?.idUsuario == e2?.idUsuario &&
        e1?.retornonotificacao == e2?.retornonotificacao &&
        e1?.idMensagem == e2?.idMensagem &&
        e1?.email == e2?.email &&
        e1?.ngostou == e2?.ngostou;
  }

  @override
  int hash(NotificacoesRecord? e) => const ListEquality().hash([
        e?.data,
        e?.titulo,
        e?.corpo,
        e?.respondido,
        e?.gostou,
        e?.idUsuario,
        e?.retornonotificacao,
        e?.idMensagem,
        e?.email,
        e?.ngostou
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificacoesRecord;
}
