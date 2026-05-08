import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MetasDiaRecord extends FirestoreRecord {
  MetasDiaRecord._(
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

  // "numero_de_metas" field.
  int? _numeroDeMetas;
  int get numeroDeMetas => _numeroDeMetas ?? 0;
  bool hasNumeroDeMetas() => _numeroDeMetas != null;

  void _initializeFields() {
    _idUsuario = snapshotData['id_usuario'] as String?;
    _data = snapshotData['data'] as DateTime?;
    _numeroDeMetas = castToType<int>(snapshotData['numero_de_metas']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('metas_dia');

  static Stream<MetasDiaRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MetasDiaRecord.fromSnapshot(s));

  static Future<MetasDiaRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MetasDiaRecord.fromSnapshot(s));

  static MetasDiaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MetasDiaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MetasDiaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MetasDiaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MetasDiaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MetasDiaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMetasDiaRecordData({
  String? idUsuario,
  DateTime? data,
  int? numeroDeMetas,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id_usuario': idUsuario,
      'data': data,
      'numero_de_metas': numeroDeMetas,
    }.withoutNulls,
  );

  return firestoreData;
}

class MetasDiaRecordDocumentEquality implements Equality<MetasDiaRecord> {
  const MetasDiaRecordDocumentEquality();

  @override
  bool equals(MetasDiaRecord? e1, MetasDiaRecord? e2) {
    return e1?.idUsuario == e2?.idUsuario &&
        e1?.data == e2?.data &&
        e1?.numeroDeMetas == e2?.numeroDeMetas;
  }

  @override
  int hash(MetasDiaRecord? e) =>
      const ListEquality().hash([e?.idUsuario, e?.data, e?.numeroDeMetas]);

  @override
  bool isValidKey(Object? o) => o is MetasDiaRecord;
}
