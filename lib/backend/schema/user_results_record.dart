import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserResultsRecord extends FirestoreRecord {
  UserResultsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "result" field.
  String? _result;
  String get result => _result ?? '';
  bool hasResult() => _result != null;

  // "messageType" field.
  String? _messageType;
  String get messageType => _messageType ?? '';
  bool hasMessageType() => _messageType != null;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _result = snapshotData['result'] as String?;
    _messageType = snapshotData['messageType'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('userResults');

  static Stream<UserResultsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserResultsRecord.fromSnapshot(s));

  static Future<UserResultsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserResultsRecord.fromSnapshot(s));

  static UserResultsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserResultsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserResultsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserResultsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserResultsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserResultsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserResultsRecordData({
  String? userId,
  String? result,
  String? messageType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'result': result,
      'messageType': messageType,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserResultsRecordDocumentEquality implements Equality<UserResultsRecord> {
  const UserResultsRecordDocumentEquality();

  @override
  bool equals(UserResultsRecord? e1, UserResultsRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.result == e2?.result &&
        e1?.messageType == e2?.messageType;
  }

  @override
  int hash(UserResultsRecord? e) =>
      const ListEquality().hash([e?.userId, e?.result, e?.messageType]);

  @override
  bool isValidKey(Object? o) => o is UserResultsRecord;
}
