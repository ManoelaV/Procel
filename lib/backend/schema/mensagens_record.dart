import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MensagensRecord extends FirestoreRecord {
  MensagensRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  bool hasId() => _id != null;

  // "id_motivacao" field.
  String? _idMotivacao;
  String get idMotivacao => _idMotivacao ?? '';
  bool hasIdMotivacao() => _idMotivacao != null;

  // "textomotivacao" field.
  String? _textomotivacao;
  String get textomotivacao => _textomotivacao ?? '';
  bool hasTextomotivacao() => _textomotivacao != null;

  // "tipomotivacao" field.
  String? _tipomotivacao;
  String get tipomotivacao => _tipomotivacao ?? '';
  bool hasTipomotivacao() => _tipomotivacao != null;

  void _initializeFields() {
    _id = snapshotData['id'] as String?;
    _idMotivacao = snapshotData['id_motivacao'] as String?;
    _textomotivacao = snapshotData['textomotivacao'] as String?;
    _tipomotivacao = snapshotData['tipomotivacao'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('mensagens');

  static Stream<MensagensRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MensagensRecord.fromSnapshot(s));

  static Future<MensagensRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MensagensRecord.fromSnapshot(s));

  static MensagensRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MensagensRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MensagensRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MensagensRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MensagensRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MensagensRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMensagensRecordData({
  String? id,
  String? idMotivacao,
  String? textomotivacao,
  String? tipomotivacao,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id': id,
      'id_motivacao': idMotivacao,
      'textomotivacao': textomotivacao,
      'tipomotivacao': tipomotivacao,
    }.withoutNulls,
  );

  return firestoreData;
}

class MensagensRecordDocumentEquality implements Equality<MensagensRecord> {
  const MensagensRecordDocumentEquality();

  @override
  bool equals(MensagensRecord? e1, MensagensRecord? e2) {
    return e1?.id == e2?.id &&
        e1?.idMotivacao == e2?.idMotivacao &&
        e1?.textomotivacao == e2?.textomotivacao &&
        e1?.tipomotivacao == e2?.tipomotivacao;
  }

  @override
  int hash(MensagensRecord? e) => const ListEquality()
      .hash([e?.id, e?.idMotivacao, e?.textomotivacao, e?.tipomotivacao]);

  @override
  bool isValidKey(Object? o) => o is MensagensRecord;
}
