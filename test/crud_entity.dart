import 'package:flutter/cupertino.dart';

import 'genericDao.dart';

abstract class CrudEntity {
  Future<Map<String, CrudEntity>> getRelatedFieldsInstances();

  CrudEntity withRelated();

  void unlinkRelated();

  List<CrudEntity> getRelated();

  String getName(BuildContext context);

  String getFieldLabel(BuildContext context, String fieldName) {}

  bool isFieldRequired(String fieldName);

  String getFieldType(String fieldName);

  Map<String, dynamic> toMap();

  CrudEntity.fromMap(Map<String, dynamic> map);

  dynamic getField(String fieldName);

  GenericDao getDao();

  Map<String, dynamic> getVisibleFields();

}