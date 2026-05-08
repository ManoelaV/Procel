import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SIMSUsuarioRecord extends FirestoreRecord {
  SIMSUsuarioRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "sims1" field.
  double? _sims1;
  double get sims1 => _sims1 ?? 0.0;
  bool hasSims1() => _sims1 != null;

  // "sims2" field.
  double? _sims2;
  double get sims2 => _sims2 ?? 0.0;
  bool hasSims2() => _sims2 != null;

  // "sims3" field.
  double? _sims3;
  double get sims3 => _sims3 ?? 0.0;
  bool hasSims3() => _sims3 != null;

  // "sims4" field.
  double? _sims4;
  double get sims4 => _sims4 ?? 0.0;
  bool hasSims4() => _sims4 != null;

  // "sims5" field.
  double? _sims5;
  double get sims5 => _sims5 ?? 0.0;
  bool hasSims5() => _sims5 != null;

  // "sims6" field.
  double? _sims6;
  double get sims6 => _sims6 ?? 0.0;
  bool hasSims6() => _sims6 != null;

  // "sims7" field.
  double? _sims7;
  double get sims7 => _sims7 ?? 0.0;
  bool hasSims7() => _sims7 != null;

  // "sims8" field.
  double? _sims8;
  double get sims8 => _sims8 ?? 0.0;
  bool hasSims8() => _sims8 != null;

  // "sims9" field.
  double? _sims9;
  double get sims9 => _sims9 ?? 0.0;
  bool hasSims9() => _sims9 != null;

  // "sims10" field.
  double? _sims10;
  double get sims10 => _sims10 ?? 0.0;
  bool hasSims10() => _sims10 != null;

  // "sims11" field.
  double? _sims11;
  double get sims11 => _sims11 ?? 0.0;
  bool hasSims11() => _sims11 != null;

  // "sims12" field.
  double? _sims12;
  double get sims12 => _sims12 ?? 0.0;
  bool hasSims12() => _sims12 != null;

  // "sims13" field.
  double? _sims13;
  double get sims13 => _sims13 ?? 0.0;
  bool hasSims13() => _sims13 != null;

  // "sims14" field.
  double? _sims14;
  double get sims14 => _sims14 ?? 0.0;
  bool hasSims14() => _sims14 != null;

  // "sims15" field.
  double? _sims15;
  double get sims15 => _sims15 ?? 0.0;
  bool hasSims15() => _sims15 != null;

  // "sims16" field.
  double? _sims16;
  double get sims16 => _sims16 ?? 0.0;
  bool hasSims16() => _sims16 != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _data = snapshotData['data'] as DateTime?;
    _sims1 = castToType<double>(snapshotData['sims1']);
    _sims2 = castToType<double>(snapshotData['sims2']);
    _sims3 = castToType<double>(snapshotData['sims3']);
    _sims4 = castToType<double>(snapshotData['sims4']);
    _sims5 = castToType<double>(snapshotData['sims5']);
    _sims6 = castToType<double>(snapshotData['sims6']);
    _sims7 = castToType<double>(snapshotData['sims7']);
    _sims8 = castToType<double>(snapshotData['sims8']);
    _sims9 = castToType<double>(snapshotData['sims9']);
    _sims10 = castToType<double>(snapshotData['sims10']);
    _sims11 = castToType<double>(snapshotData['sims11']);
    _sims12 = castToType<double>(snapshotData['sims12']);
    _sims13 = castToType<double>(snapshotData['sims13']);
    _sims14 = castToType<double>(snapshotData['sims14']);
    _sims15 = castToType<double>(snapshotData['sims15']);
    _sims16 = castToType<double>(snapshotData['sims16']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('SIMS_usuario');

  static Stream<SIMSUsuarioRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SIMSUsuarioRecord.fromSnapshot(s));

  static Future<SIMSUsuarioRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SIMSUsuarioRecord.fromSnapshot(s));

  static SIMSUsuarioRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SIMSUsuarioRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SIMSUsuarioRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SIMSUsuarioRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SIMSUsuarioRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SIMSUsuarioRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSIMSUsuarioRecordData({
  String? userId,
  DateTime? data,
  double? sims1,
  double? sims2,
  double? sims3,
  double? sims4,
  double? sims5,
  double? sims6,
  double? sims7,
  double? sims8,
  double? sims9,
  double? sims10,
  double? sims11,
  double? sims12,
  double? sims13,
  double? sims14,
  double? sims15,
  double? sims16,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'data': data,
      'sims1': sims1,
      'sims2': sims2,
      'sims3': sims3,
      'sims4': sims4,
      'sims5': sims5,
      'sims6': sims6,
      'sims7': sims7,
      'sims8': sims8,
      'sims9': sims9,
      'sims10': sims10,
      'sims11': sims11,
      'sims12': sims12,
      'sims13': sims13,
      'sims14': sims14,
      'sims15': sims15,
      'sims16': sims16,
    }.withoutNulls,
  );

  return firestoreData;
}

class SIMSUsuarioRecordDocumentEquality implements Equality<SIMSUsuarioRecord> {
  const SIMSUsuarioRecordDocumentEquality();

  @override
  bool equals(SIMSUsuarioRecord? e1, SIMSUsuarioRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.data == e2?.data &&
        e1?.sims1 == e2?.sims1 &&
        e1?.sims2 == e2?.sims2 &&
        e1?.sims3 == e2?.sims3 &&
        e1?.sims4 == e2?.sims4 &&
        e1?.sims5 == e2?.sims5 &&
        e1?.sims6 == e2?.sims6 &&
        e1?.sims7 == e2?.sims7 &&
        e1?.sims8 == e2?.sims8 &&
        e1?.sims9 == e2?.sims9 &&
        e1?.sims10 == e2?.sims10 &&
        e1?.sims11 == e2?.sims11 &&
        e1?.sims12 == e2?.sims12 &&
        e1?.sims13 == e2?.sims13 &&
        e1?.sims14 == e2?.sims14 &&
        e1?.sims15 == e2?.sims15 &&
        e1?.sims16 == e2?.sims16;
  }

  @override
  int hash(SIMSUsuarioRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.data,
        e?.sims1,
        e?.sims2,
        e?.sims3,
        e?.sims4,
        e?.sims5,
        e?.sims6,
        e?.sims7,
        e?.sims8,
        e?.sims9,
        e?.sims10,
        e?.sims11,
        e?.sims12,
        e?.sims13,
        e?.sims14,
        e?.sims15,
        e?.sims16
      ]);

  @override
  bool isValidKey(Object? o) => o is SIMSUsuarioRecord;
}
