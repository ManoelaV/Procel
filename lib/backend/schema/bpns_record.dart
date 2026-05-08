import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BpnsRecord extends FirestoreRecord {
  BpnsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "numero" field.
  int? _numero;
  int get numero => _numero ?? 0;
  bool hasNumero() => _numero != null;

  // "pergunta" field.
  String? _pergunta;
  String get pergunta => _pergunta ?? '';
  bool hasPergunta() => _pergunta != null;

  // "valor" field.
  int? _valor;
  int get valor => _valor ?? 0;
  bool hasValor() => _valor != null;

  void _initializeFields() {
    _numero = castToType<int>(snapshotData['numero']);
    _pergunta = snapshotData['pergunta'] as String?;
    _valor = castToType<int>(snapshotData['valor']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('BPNS');

  static Stream<BpnsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BpnsRecord.fromSnapshot(s));

  static Future<BpnsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BpnsRecord.fromSnapshot(s));

  static BpnsRecord fromSnapshot(DocumentSnapshot snapshot) => BpnsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BpnsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BpnsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BpnsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BpnsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBpnsRecordData({
  int? numero,
  String? pergunta,
  int? valor,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'numero': numero,
      'pergunta': pergunta,
      'valor': valor,
    }.withoutNulls,
  );

  return firestoreData;
}

class BpnsRecordDocumentEquality implements Equality<BpnsRecord> {
  const BpnsRecordDocumentEquality();

  @override
  bool equals(BpnsRecord? e1, BpnsRecord? e2) {
    return e1?.numero == e2?.numero &&
        e1?.pergunta == e2?.pergunta &&
        e1?.valor == e2?.valor;
  }

  @override
  int hash(BpnsRecord? e) =>
      const ListEquality().hash([e?.numero, e?.pergunta, e?.valor]);

  @override
  bool isValidKey(Object? o) => o is BpnsRecord;
}
