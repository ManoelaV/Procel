import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BPNSUsuarioRecord extends FirestoreRecord {
  BPNSUsuarioRecord._(
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

  // "bnps1" field.
  double? _bnps1;
  double get bnps1 => _bnps1 ?? 0.0;
  bool hasBnps1() => _bnps1 != null;

  // "bnps2" field.
  double? _bnps2;
  double get bnps2 => _bnps2 ?? 0.0;
  bool hasBnps2() => _bnps2 != null;

  // "bnps3" field.
  double? _bnps3;
  double get bnps3 => _bnps3 ?? 0.0;
  bool hasBnps3() => _bnps3 != null;

  // "bnps4" field.
  double? _bnps4;
  double get bnps4 => _bnps4 ?? 0.0;
  bool hasBnps4() => _bnps4 != null;

  // "bnps5" field.
  double? _bnps5;
  double get bnps5 => _bnps5 ?? 0.0;
  bool hasBnps5() => _bnps5 != null;

  // "bnps6" field.
  double? _bnps6;
  double get bnps6 => _bnps6 ?? 0.0;
  bool hasBnps6() => _bnps6 != null;

  // "bnps7" field.
  double? _bnps7;
  double get bnps7 => _bnps7 ?? 0.0;
  bool hasBnps7() => _bnps7 != null;

  // "bnps8" field.
  double? _bnps8;
  double get bnps8 => _bnps8 ?? 0.0;
  bool hasBnps8() => _bnps8 != null;

  // "bnps9" field.
  double? _bnps9;
  double get bnps9 => _bnps9 ?? 0.0;
  bool hasBnps9() => _bnps9 != null;

  // "bnps10" field.
  double? _bnps10;
  double get bnps10 => _bnps10 ?? 0.0;
  bool hasBnps10() => _bnps10 != null;

  // "bnps11" field.
  double? _bnps11;
  double get bnps11 => _bnps11 ?? 0.0;
  bool hasBnps11() => _bnps11 != null;

  // "bnps12" field.
  double? _bnps12;
  double get bnps12 => _bnps12 ?? 0.0;
  bool hasBnps12() => _bnps12 != null;

  // "bnps13" field.
  double? _bnps13;
  double get bnps13 => _bnps13 ?? 0.0;
  bool hasBnps13() => _bnps13 != null;

  // "bnps14" field.
  double? _bnps14;
  double get bnps14 => _bnps14 ?? 0.0;
  bool hasBnps14() => _bnps14 != null;

  // "bnps15" field.
  double? _bnps15;
  double get bnps15 => _bnps15 ?? 0.0;
  bool hasBnps15() => _bnps15 != null;

  // "bnps16" field.
  double? _bnps16;
  double get bnps16 => _bnps16 ?? 0.0;
  bool hasBnps16() => _bnps16 != null;

  // "bnps17" field.
  double? _bnps17;
  double get bnps17 => _bnps17 ?? 0.0;
  bool hasBnps17() => _bnps17 != null;

  // "bnps18" field.
  double? _bnps18;
  double get bnps18 => _bnps18 ?? 0.0;
  bool hasBnps18() => _bnps18 != null;

  // "bnps19" field.
  double? _bnps19;
  double get bnps19 => _bnps19 ?? 0.0;
  bool hasBnps19() => _bnps19 != null;

  // "bnps20" field.
  double? _bnps20;
  double get bnps20 => _bnps20 ?? 0.0;
  bool hasBnps20() => _bnps20 != null;

  // "bnps21" field.
  double? _bnps21;
  double get bnps21 => _bnps21 ?? 0.0;
  bool hasBnps21() => _bnps21 != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _data = snapshotData['data'] as DateTime?;
    _bnps1 = castToType<double>(snapshotData['bnps1']);
    _bnps2 = castToType<double>(snapshotData['bnps2']);
    _bnps3 = castToType<double>(snapshotData['bnps3']);
    _bnps4 = castToType<double>(snapshotData['bnps4']);
    _bnps5 = castToType<double>(snapshotData['bnps5']);
    _bnps6 = castToType<double>(snapshotData['bnps6']);
    _bnps7 = castToType<double>(snapshotData['bnps7']);
    _bnps8 = castToType<double>(snapshotData['bnps8']);
    _bnps9 = castToType<double>(snapshotData['bnps9']);
    _bnps10 = castToType<double>(snapshotData['bnps10']);
    _bnps11 = castToType<double>(snapshotData['bnps11']);
    _bnps12 = castToType<double>(snapshotData['bnps12']);
    _bnps13 = castToType<double>(snapshotData['bnps13']);
    _bnps14 = castToType<double>(snapshotData['bnps14']);
    _bnps15 = castToType<double>(snapshotData['bnps15']);
    _bnps16 = castToType<double>(snapshotData['bnps16']);
    _bnps17 = castToType<double>(snapshotData['bnps17']);
    _bnps18 = castToType<double>(snapshotData['bnps18']);
    _bnps19 = castToType<double>(snapshotData['bnps19']);
    _bnps20 = castToType<double>(snapshotData['bnps20']);
    _bnps21 = castToType<double>(snapshotData['bnps21']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('BPNS_usuario');

  static Stream<BPNSUsuarioRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BPNSUsuarioRecord.fromSnapshot(s));

  static Future<BPNSUsuarioRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BPNSUsuarioRecord.fromSnapshot(s));

  static BPNSUsuarioRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BPNSUsuarioRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BPNSUsuarioRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BPNSUsuarioRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BPNSUsuarioRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BPNSUsuarioRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBPNSUsuarioRecordData({
  String? userId,
  DateTime? data,
  double? bnps1,
  double? bnps2,
  double? bnps3,
  double? bnps4,
  double? bnps5,
  double? bnps6,
  double? bnps7,
  double? bnps8,
  double? bnps9,
  double? bnps10,
  double? bnps11,
  double? bnps12,
  double? bnps13,
  double? bnps14,
  double? bnps15,
  double? bnps16,
  double? bnps17,
  double? bnps18,
  double? bnps19,
  double? bnps20,
  double? bnps21,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'data': data,
      'bnps1': bnps1,
      'bnps2': bnps2,
      'bnps3': bnps3,
      'bnps4': bnps4,
      'bnps5': bnps5,
      'bnps6': bnps6,
      'bnps7': bnps7,
      'bnps8': bnps8,
      'bnps9': bnps9,
      'bnps10': bnps10,
      'bnps11': bnps11,
      'bnps12': bnps12,
      'bnps13': bnps13,
      'bnps14': bnps14,
      'bnps15': bnps15,
      'bnps16': bnps16,
      'bnps17': bnps17,
      'bnps18': bnps18,
      'bnps19': bnps19,
      'bnps20': bnps20,
      'bnps21': bnps21,
    }.withoutNulls,
  );

  return firestoreData;
}

class BPNSUsuarioRecordDocumentEquality implements Equality<BPNSUsuarioRecord> {
  const BPNSUsuarioRecordDocumentEquality();

  @override
  bool equals(BPNSUsuarioRecord? e1, BPNSUsuarioRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.data == e2?.data &&
        e1?.bnps1 == e2?.bnps1 &&
        e1?.bnps2 == e2?.bnps2 &&
        e1?.bnps3 == e2?.bnps3 &&
        e1?.bnps4 == e2?.bnps4 &&
        e1?.bnps5 == e2?.bnps5 &&
        e1?.bnps6 == e2?.bnps6 &&
        e1?.bnps7 == e2?.bnps7 &&
        e1?.bnps8 == e2?.bnps8 &&
        e1?.bnps9 == e2?.bnps9 &&
        e1?.bnps10 == e2?.bnps10 &&
        e1?.bnps11 == e2?.bnps11 &&
        e1?.bnps12 == e2?.bnps12 &&
        e1?.bnps13 == e2?.bnps13 &&
        e1?.bnps14 == e2?.bnps14 &&
        e1?.bnps15 == e2?.bnps15 &&
        e1?.bnps16 == e2?.bnps16 &&
        e1?.bnps17 == e2?.bnps17 &&
        e1?.bnps18 == e2?.bnps18 &&
        e1?.bnps19 == e2?.bnps19 &&
        e1?.bnps20 == e2?.bnps20 &&
        e1?.bnps21 == e2?.bnps21;
  }

  @override
  int hash(BPNSUsuarioRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.data,
        e?.bnps1,
        e?.bnps2,
        e?.bnps3,
        e?.bnps4,
        e?.bnps5,
        e?.bnps6,
        e?.bnps7,
        e?.bnps8,
        e?.bnps9,
        e?.bnps10,
        e?.bnps11,
        e?.bnps12,
        e?.bnps13,
        e?.bnps14,
        e?.bnps15,
        e?.bnps16,
        e?.bnps17,
        e?.bnps18,
        e?.bnps19,
        e?.bnps20,
        e?.bnps21
      ]);

  @override
  bool isValidKey(Object? o) => o is BPNSUsuarioRecord;
}
