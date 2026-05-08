import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MetasRecord extends FirestoreRecord {
  MetasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "meta" field.
  String? _meta;
  String get meta => _meta ?? '';
  bool hasMeta() => _meta != null;

  // "completed" field.
  bool? _completed;
  bool get completed => _completed ?? false;
  bool hasCompleted() => _completed != null;

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  bool hasUserID() => _userID != null;

  // "data_criacao" field.
  DateTime? _dataCriacao;
  DateTime? get dataCriacao => _dataCriacao;
  bool hasDataCriacao() => _dataCriacao != null;

  // "data_conclusao" field.
  DateTime? _dataConclusao;
  DateTime? get dataConclusao => _dataConclusao;
  bool hasDataConclusao() => _dataConclusao != null;

  void _initializeFields() {
    _meta = snapshotData['meta'] as String?;
    _completed = snapshotData['completed'] as bool?;
    _userID = snapshotData['userID'] as String?;
    _dataCriacao = snapshotData['data_criacao'] as DateTime?;
    _dataConclusao = snapshotData['data_conclusao'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Metas');

  static Stream<MetasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MetasRecord.fromSnapshot(s));

  static Future<MetasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MetasRecord.fromSnapshot(s));

  static MetasRecord fromSnapshot(DocumentSnapshot snapshot) => MetasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MetasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MetasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MetasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MetasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMetasRecordData({
  String? meta,
  bool? completed,
  String? userID,
  DateTime? dataCriacao,
  DateTime? dataConclusao,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'meta': meta,
      'completed': completed,
      'userID': userID,
      'data_criacao': dataCriacao,
      'data_conclusao': dataConclusao,
    }.withoutNulls,
  );

  return firestoreData;
}

class MetasRecordDocumentEquality implements Equality<MetasRecord> {
  const MetasRecordDocumentEquality();

  @override
  bool equals(MetasRecord? e1, MetasRecord? e2) {
    return e1?.meta == e2?.meta &&
        e1?.completed == e2?.completed &&
        e1?.userID == e2?.userID &&
        e1?.dataCriacao == e2?.dataCriacao &&
        e1?.dataConclusao == e2?.dataConclusao;
  }

  @override
  int hash(MetasRecord? e) => const ListEquality().hash(
      [e?.meta, e?.completed, e?.userID, e?.dataCriacao, e?.dataConclusao]);

  @override
  bool isValidKey(Object? o) => o is MetasRecord;
}
