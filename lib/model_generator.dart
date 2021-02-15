import 'package:code_builder/code_builder.dart';
import 'model_methods.dart';
import 'model_parser.dart';

extension CapExtension on String {
  String get firstLower => '${this[0].toLowerCase()}${this.substring(1)}';
//
// String get firstCap => '${this[0].toUpperCase()}${this.substring(1)}';
//
// String get allInCaps => this.toUpperCase();
//
// String get firstofEachCap =>
//     this.split(" ").map((str) => str.firstCap).join(" ");
}

String generateForeignKeys(List<ParsedField> fields) {
  return fields
      .map((e) => e.fk == null
          ? ""
          : "ForeignKey("
              "childColumns: ['${e.name}'],"
              "parentColumns: ['${e.fk.field.name}'],"
              "entity: ${e.fk.entity.name},"
              "),")
      .fold("", (previousValue, element) => previousValue + element);
}

Reference fkAnnotation(ParsedEntity entity) {
  if (entity.fields.every((field) => field.fk == null))
    return refer('entity');
  else
    return refer("""
        Entity(
          foreignKeys: [
            """ +
        generateForeignKeys(entity.fields) +
        """
          ],
        )
        """);
}

List<Class> genModels(List<ParsedEntity> entities) {
  return entities
      .map((entity) => Class((b) => b
        ..name = entity.name
        ..annotations.add(fkAnnotation(entity))
        ..implements.add(refer('CrudEntity'))
        ..fields.addAll(getFields(entity))
        ..constructors.add(Constructor(
            (b) => b..optionalParameters.addAll(getConstructorParams(entity))))
        // ..constructors.addAll([
        //   if (getFKs(entity).length>0)
        //     createWithRelated(entity)
        // ])
        ..constructors.add(Constructor((b) => b
          ..name = 'fromMap'
          ..requiredParameters.add(Parameter((e) => e
            ..name = 'map'
            ..type = refer('Map<String, dynamic>')))
          ..initializers.add(Code(entity.fields
              .map((field) => '${field.name} = map[\'${field.name}\'] as '
                  '${field.type}')
              .join(',')))))
        ..methods.addAll([
          ...getRelated(entity),
          overrideEqual(entity),
          getRelatedFieldsInstances(entity),
          withRelated(entity),
          getRelateds(entity),
          getName(entity),
          //getType(entity),
          getDao(entity),
          getMainValueFieldName(entity),
          getFieldLabel(entity),
          getFieldType(entity),
          isFieldRequired(entity),
          getField(entity),
          getVisibleFields(entity),
          toMap(entity),
          copyWith(entity),
          unlinkRelated(entity)
        ])))
      .toList();
}

List<Class> genDAOs(List<ParsedEntity> entities) {
  return entities
      .map((entity) => Class((b) => b
            ..name = '${entity.name}Dao'
            ..annotations.add(refer('dao'))
            ..extend = refer('GenericDao<${entity.name}>')
            ..abstract = true
          // ..fields.add(Field((b) => b
          //   ..name = 'dbTable'
          //   ..modifier = FieldModifier.final$
          //   ..assignment = Code("'${entity.name}'")))
          ))
      .toList();
}


// List<Method> unlinkRelated(List<ParsedEntity> entities, ParsedEntity entity){
//   final used = getUsedBy(entities, entity);
//   var code = '';
//   for (final used_entity in used){
//     code += '$used_entity.getDao().';
//   }
// }





// List<ParsedEntity> getUsedBy(List<ParsedEntity> entities, ParsedEntity entity){
//   List<ParsedEntity> ret = <ParsedEntity>[];
//   for (final e in entities){
//     for (final field in e.fields){
//       if (field.fk.entity.name == entity.name)
//         ret.add(e);
//     }
//   }
//   return ret;
// }

List<Parameter> getConstructorParams(ParsedEntity entity) {
  return [
    ...entity.fields
        .map((field) => Parameter((b) => b
          ..name = 'this.${field.name}'
          ..named = true))
        .toList()
  ];
}

List<Parameter> getConstructorParamsNoFK(ParsedEntity entity) {
  final fields = List<ParsedField>.from(entity.fields);
  fields.removeWhere((element) => element.fk != null);
  return [
    ...fields
        .map((field) => Parameter((b) => b
      ..name = 'this.${field.name}'
      ..named = true))
        .toList()
  ];
}

List<ParsedField> getFKs(ParsedEntity entity) {
  final fks = List<ParsedField>.from(entity.fields);
  fks.removeWhere((field) => field.fk == null);
  return fks;
}


List<Field> getFields(ParsedEntity entity) {
  return [
    ...entity.fields
        .map((field) => Field((b) => b
          ..name = field.name
          ..annotations.addAll([if (field.name=='id') refer('PrimaryKey(autoGenerate: true)')])
          ..type = refer(field.type.toString())
          ..modifier = FieldModifier.final$))
        .toList()
  ];
}
