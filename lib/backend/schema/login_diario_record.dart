import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LoginDiarioRecord extends FirestoreRecord {
  LoginDiarioRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id_usuario" field.
  String? _idUsuario;
  String get idUsuario => _idUsuario ?? '';
  bool hasIdUsuario() => _idUsuario != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "tempo" field.
  int? _tempo;
  int get tempo => _tempo ?? 0;
  bool hasTempo() => _tempo != null;

  void _initializeFields() {
    _idUsuario = snapshotData['id_usuario'] as String?;
    _data = snapshotData['data'] as DateTime?;
    _tempo = castToType<int>(snapshotData['tempo']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('login_diario');

  static Stream<LoginDiarioRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LoginDiarioRecord.fromSnapshot(s));

  static Future<LoginDiarioRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LoginDiarioRecord.fromSnapshot(s));

  static LoginDiarioRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LoginDiarioRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LoginDiarioRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LoginDiarioRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LoginDiarioRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LoginDiarioRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLoginDiarioRecordData({
  String? idUsuario,
  DateTime? data,
  int? tempo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id_usuario': idUsuario,
      'data': data,
      'tempo': tempo,
    }.withoutNulls,
  );

  return firestoreData;
}

class LoginDiarioRecordDocumentEquality implements Equality<LoginDiarioRecord> {
  const LoginDiarioRecordDocumentEquality();

  @override
  bool equals(LoginDiarioRecord? e1, LoginDiarioRecord? e2) {
    return e1?.idUsuario == e2?.idUsuario &&
        e1?.data == e2?.data &&
        e1?.tempo == e2?.tempo;
  }

  @override
  int hash(LoginDiarioRecord? e) =>
      const ListEquality().hash([e?.idUsuario, e?.data, e?.tempo]);

  @override
  bool isValidKey(Object? o) => o is LoginDiarioRecord;
}
