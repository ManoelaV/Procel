// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NoticiaStruct extends FFFirebaseStruct {
  NoticiaStruct({
    String? titulo,
    String? descricao,
    int? link,
    String? imagem,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _titulo = titulo,
        _descricao = descricao,
        _link = link,
        _imagem = imagem,
        super(firestoreUtilData);

  // "titulo" field.
  String? _titulo;
  String get titulo => _titulo ?? '';
  set titulo(String? val) => _titulo = val;

  bool hasTitulo() => _titulo != null;

  // "descricao" field.
  String? _descricao;
  String get descricao => _descricao ?? '';
  set descricao(String? val) => _descricao = val;

  bool hasDescricao() => _descricao != null;

  // "link" field.
  int? _link;
  int get link => _link ?? 0;
  set link(int? val) => _link = val;

  void incrementLink(int amount) => link = link + amount;

  bool hasLink() => _link != null;

  // "imagem" field.
  String? _imagem;
  String get imagem => _imagem ?? '';
  set imagem(String? val) => _imagem = val;

  bool hasImagem() => _imagem != null;

  static NoticiaStruct fromMap(Map<String, dynamic> data) => NoticiaStruct(
        titulo: data['titulo'] as String?,
        descricao: data['descricao'] as String?,
        link: castToType<int>(data['link']),
        imagem: data['imagem'] as String?,
      );

  static NoticiaStruct? maybeFromMap(dynamic data) =>
      data is Map ? NoticiaStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'titulo': _titulo,
        'descricao': _descricao,
        'link': _link,
        'imagem': _imagem,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'titulo': serializeParam(
          _titulo,
          ParamType.String,
        ),
        'descricao': serializeParam(
          _descricao,
          ParamType.String,
        ),
        'link': serializeParam(
          _link,
          ParamType.int,
        ),
        'imagem': serializeParam(
          _imagem,
          ParamType.String,
        ),
      }.withoutNulls;

  static NoticiaStruct fromSerializableMap(Map<String, dynamic> data) =>
      NoticiaStruct(
        titulo: deserializeParam(
          data['titulo'],
          ParamType.String,
          false,
        ),
        descricao: deserializeParam(
          data['descricao'],
          ParamType.String,
          false,
        ),
        link: deserializeParam(
          data['link'],
          ParamType.int,
          false,
        ),
        imagem: deserializeParam(
          data['imagem'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'NoticiaStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is NoticiaStruct &&
        titulo == other.titulo &&
        descricao == other.descricao &&
        link == other.link &&
        imagem == other.imagem;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([titulo, descricao, link, imagem]);
}

NoticiaStruct createNoticiaStruct({
  String? titulo,
  String? descricao,
  int? link,
  String? imagem,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    NoticiaStruct(
      titulo: titulo,
      descricao: descricao,
      link: link,
      imagem: imagem,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

NoticiaStruct? updateNoticiaStruct(
  NoticiaStruct? noticia, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    noticia
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addNoticiaStructData(
  Map<String, dynamic> firestoreData,
  NoticiaStruct? noticia,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (noticia == null) {
    return;
  }
  if (noticia.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && noticia.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final noticiaData = getNoticiaFirestoreData(noticia, forFieldValue);
  final nestedData = noticiaData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = noticia.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getNoticiaFirestoreData(
  NoticiaStruct? noticia, [
  bool forFieldValue = false,
]) {
  if (noticia == null) {
    return {};
  }
  final firestoreData = mapToFirestore(noticia.toMap());

  // Add any Firestore field values
  mapToFirestore(noticia.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getNoticiaListFirestoreData(
  List<NoticiaStruct>? noticias,
) =>
    noticias?.map((e) => getNoticiaFirestoreData(e, true)).toList() ?? [];
