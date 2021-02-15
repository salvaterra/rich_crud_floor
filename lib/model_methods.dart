import 'package:code_builder/code_builder.dart';
import 'model_generator.dart';
import 'model_parser.dart';

// Future<Map<String, CrudEntity>> getRelatedFieldsInstances() async{
//   return {'mortgageId': (await getMortgage())};
// }

// @override
// bool operator ==(Object other) => other is Tag && other.name == name;
Method overrideEqual(ParsedEntity entity){
  return Method((b) => b..name='operator =='
  ..returns = refer('bool')
      ..requiredParameters.add(Parameter((p) => p..name='other'
      ..type = refer('Object')
      ))
      ..lambda= true
      ..body = Code('other is ${entity.name} && other.id == id')
  );
}


Method getRelatedFieldsInstances(ParsedEntity entity) {
  final fks = getFKs(entity);

  String ret = fks
      .map((e) => '\'${e.name}\': (await get${e.fk.entity.name}()),')
      .toList()
      .fold('', (previousValue, element) => previousValue + element);

  return Method((b) => b
    ..name = 'getRelatedFieldsInstances'
    ..returns = refer('Future<Map<String, CrudEntity>>')
    ..modifier = MethodModifier.async
    ..body = Code('return {$ret};'));
}

Method withRelated(ParsedEntity entity) {
  final ret = entity.fields
      .map((field) => '${field.name}: map[\'${field.name}\'] as '
          '${field.type}')
      .join(', ');

  String assign = '';
  if (entity.relatedEntities != null)
    assign = entity.relatedEntities.map((e) {
      final fields = entity.fields
          .where((element) => (element.fk != null && element.fk.entity == e));
      if (fields.length>0) {
        var localAssign = '';
        for (final field in fields) {
          localAssign += 'map[\'${field.name}\'] = (entity as ${e.name}).id;\n';
        }
        return 'if (entity.runtimeType == ${e.name}) \n$localAssign';
      } else
        return '';
    }).fold('', (previousValue, element) => previousValue + element);

  return Method((b) => b
    ..name = 'withRelated'
    ..returns = refer(entity.name)
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = 'entities'
        ..type = refer('List<CrudEntity>')
        ..named = true),
      Parameter((b) => b
        ..name = 'map'
        ..type = refer('Map<String, dynamic>')
        ..named = true)
    ])
    ..body = Code('''
       for (final entity in entities) {
         $assign
       }
       return ${entity.name}(${ret});
    '''));
}

Constructor createWithRelated(ParsedEntity entity) {
  final fks = getFKs(entity);
  return Constructor((b) => b
    ..name = 'withRelated'
    ..initializers.add(Code(fks
        .map((field) => 'this.${field.name} = '
            '${field.fk.entity.name.firstLower}.id')
        .fold('', (previousValue, element) => previousValue + element)))
    ..optionalParameters.addAll([
      ...fks
          .map((field) => Parameter((b) => b
            ..name = field.fk.entity.name.firstLower
            ..type = refer(field.fk.entity.name)
            ..named = true))
          .toList(),
      ...getConstructorParamsNoFK(entity)
    ]));
}

List<Method> getRelated(ParsedEntity entity) {
  final fks = getFKs(entity);
  return fks
      .map((field) => Method((b) => b
        ..name = 'get${field.fk.entity.name}'
        ..returns = refer('Future<${field.fk.entity.name}>')
        ..modifier = MethodModifier.async
        ..body = Code(
            'return await ${field.fk.entity.name}().getDao().getById(this.${field.name}.toString());')))
      .toList();
}

Method getDao(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getDao'
    //..static = true
    ..returns = refer('${entity.name}Dao')
    ..body = Code('return globals.mydb.${entity.name.firstLower}Dao;'));
}

Method getType(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getType'
    ..returns = refer('WealthEntityBind')
    ..body = Code('return WealthEntityBind.${entity.name.toLowerCase()};'));
}

Method getMainValueFieldName(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getMainValueFieldName'
    ..returns = refer('String')
    ..body = Code('return \'${entity.mainField.name}\';'));
}

Method getName(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getName'
    ..returns = refer('String')
    ..requiredParameters.add(Parameter((e) => e
      ..name = 'context'
      ..type = refer('BuildContext')))
    ..body = Code(
        'final _l = AppLocalizations.of(context);\nreturn _l.${entity.name.firstLower};'));
}

Method getFieldLabel(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getFieldLabel'
    ..returns = refer('String')
    ..requiredParameters.addAll([
      Parameter((e) => e
        ..name = 'context'
        ..type = refer('BuildContext')),
      Parameter((e) => e
        ..name = 'fieldName'
        ..type = refer('String'))
    ])
    ..body =
        Code('final _l = AppLocalizations.of(context);\nswitch (fieldName){' +
            fieldLabelsSwitch(entity.fields) +
            '\}\nthrow ArgumentError("FieldName \'\$fieldName\' '
                'does not exist as part of class \'${entity.name}\'");'));
}

String fieldLabelsSwitch(List<ParsedField> fields) {
  final visible = List<ParsedField>.from(fields);
  visible.removeWhere((element) => !element.visible);

  return '${visible.map((e) => e.mandatory ? 'case \'${e.name}\': \n return _l.${e.name};' : 'case \'${e.name}\': \n return \'\${_l.${e.name}} (\${_l.optional})\';').toList().join()}';
}

Method isFieldRequired(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'isFieldRequired'
    ..returns = refer('bool')
    ..requiredParameters.add(Parameter((e) => e
      ..name = 'fieldName'
      ..type = refer('String')))
    ..body = Code(
        'switch (fieldName){${entity.fields.map((e) => 'case \'${e.name}\': \n return ${e.mandatory};').toList().join()}\}\n'
        'throw ArgumentError("FieldName \'\$fieldName\' '
        'does not exist as part of class \'${entity.name}\'");'));
}

Method getField(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getField'
    ..returns = refer('dynamic')
    ..requiredParameters.add(Parameter((e) => e
      ..name = 'fieldName'
      ..type = refer('String')))
    ..body = Code(
        'switch (fieldName){case \'id\': return this.id; ${entity.fields.map((field) => 'case \'${field.name}\': \n return this.${field.name};').toList().join()}\}\n'
        'throw ArgumentError("FieldName \'\$fieldName\' '
        'does not exist as part of class \'${entity.name}\'");'));
}

Method getFieldType(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'getFieldType'
    ..returns = refer('String')
    ..requiredParameters.add(Parameter((e) => e
      ..name = 'fieldName'
      ..type = refer('String')))
    ..body = Code(
        'switch (fieldName){${entity.fields.map((field) => 'case \'${field.name}\': \n return \'${field.type}\';').toList().join()}\}\n'
        'throw ArgumentError("FieldName \'\$fieldName\' '
        'does not exist as part of class \'${entity.name}\'");'));
}

Method getVisibleFields(ParsedEntity entity) {
  final visible = List<ParsedField>.from(entity.fields);
  //final visible = entity.fields;
  visible.removeWhere((element) => !element.visible);
  return Method((b) => b
    ..name = 'getVisibleFields'
    ..returns = refer('Map<String, dynamic>')
    ..body = Code(
        'return {${visible.map((e) => '\'${e.name}\':${e.name},').toList().join()}\};'));
}

Method toMap(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'toMap'
    ..returns = refer('Map<String, dynamic>')
    ..body = Code(
        'return {${entity.fields.map((e) => '\'${e.name}\':${e.name},').toList().join()}\};'));
}

// List<CrudEntity> getRelated(){
//   return [Mortgage()];
// }
Method getRelateds(ParsedEntity entity) {
  final relateds = entity.relatedEntities;

  if (relateds == null)
    return Method((b) => b
      ..name = 'getRelated'
      ..returns = refer('List<CrudEntity>')
      ..body = Code('return [];'));

  StringBuffer body = StringBuffer('return [');
  for (final related in relateds) {
    final relatedEntity = related.name;
    body.write("$relatedEntity(),");
  }
  body.write("];");

  return Method((b) => b
    ..name = 'getRelated'
    ..returns = refer('List<CrudEntity>')
    ..body = Code(body.toString()));
}

Method unlinkRelated(ParsedEntity entity) {
  final relateds = entity.relatedEntities;

  if (relateds == null)
    return Method((b) => b
      ..name = 'unlinkRelated'
      ..returns = refer('Future<void>')
      ..modifier = MethodModifier.async
      ..body = Code(''));

  StringBuffer body = StringBuffer();
  for (final related in relateds) {
    final fks = getFKs(related);
    for (final fk in fks) {
      final relatedEntity = related.name;
      final relatedField = fk.name;
      body.write("$relatedEntity().getDao().updateObj((await "
          "this.get$relatedEntity()).copyWith({'$relatedField': null}));");
    }
  }

  return Method((b) => b
    ..name = 'unlinkRelated'
    ..returns = refer('Future<void>')
    ..modifier = MethodModifier.async
    ..body = Code(body.toString()));
}

Method copyWith(ParsedEntity entity) {
  return Method((b) => b
    ..name = 'copyWith'
    ..returns = refer(entity.name)
    ..requiredParameters.add(Parameter((b) => b
      ..name = 'fields'
      ..type = refer('Map<String, dynamic>')))
    ..body = Code('''
      var newObj = this.toMap();
    for (final field in fields.entries)
      newObj[field.key] = field.value;
    return ${entity.name}.fromMap(newObj);
      '''));
}

List<Parameter> getEntityFieldsAsParam(ParsedEntity entity) {
  return [
    ...entity.fields
        .map((field) => Parameter((b) => b
          ..name = field.name
          ..named = true))
        .toList()
  ];
}

String getAssignParams(ParsedEntity entity) {
  return entity.fields
      .map((field) => '${field.name}: ${field.name} ?? this.${field.name},')
      .fold('', (previousValue, element) => previousValue + element);
}
