
// PARSE
List<ParsedEntity> parse(String text) {
  List<ParsedEntity> ret = [];
  for (final entity in parseEntities(text)) {
    entity.fields = parseFields(entity);
    ret.add(entity);
  }

  for (final entity in ret){
    List<ParsedField> fks = List.from(entity.fields);
    fks.removeWhere((field) => field.fk == null);
    for (final fk in fks){
      fk.fk = resolveFk(fk.fk, ret);
      if (fk.fk != null)
        if (fk.fk.entity.relatedEntities == null)
          fk.fk.entity.relatedEntities = <ParsedEntity>[];
        fk.fk.entity.relatedEntities.add(entity);
    }
  }
  return ret;
}

ParsedForeignKey resolveFk(ParsedForeignKey fk, List<ParsedEntity> entities){
  //parentField>entity__field
  final sEntity = fk.rawText.split('__')[0].split('>')[1];
  final sField = fk.rawText.split('__')[1];
  for (final entity in entities){
    if (entity.name.toLowerCase()==sEntity.toLowerCase()){
      for (final field in entity.fields){
        if (field.name.toLowerCase()==sField.toLowerCase()){
          return ParsedForeignKey(fk.rawText, entity, field, null);
        }
      }
    }
  }
  return null;
}

List<ParsedEntity> parseEntities(String text) {
  final entities = trimPlus(text.split('#'));
  entities.removeWhere((element) => element.length == 0);

  final ret = entities.map((e) {
    final entityName = parseEntityName(e);
    final fieldsRaw = parseFieldsRaw(e);
    return ParsedEntity(e, entityName, fieldsRaw, null);
  }).toList();
  return ret;
}

List<String> trimPlus(List<String> list) {
  final ret =
  list.map((e) => e.trim().replaceAll(RegExp(r'\s\s+'), ' ')).toList();
  ret.removeWhere((element) => element.length == 0);
  return ret;
}

String parseEntityName(String text) {
  return text.split(':').first.trim();
}

String parseFieldsRaw(String text) {
  return text.split(':')[1].trim();
}

List<ParsedField> parseFields(ParsedEntity entity) {
  final fields = trimPlus(entity.rawFields.split(';'));
  // Add id
  final ret = List<ParsedField>.generate(1, (index) {
    return ParsedField(null, 'id', 'int', true, false, null);
  });

  ret.addAll( fields.map((e) {
    final name_withFk = parseFieldName(e);
    final name = parseFieldRemoveFk(name_withFk);
    final type = parseFieldType(e);
    final modifier = parseFieldModifier(e);
    final mandatory = modifier.contains('*');
    final main = modifier.contains('**');
    final visible = !modifier.contains('!');
    final fk = name_withFk.contains('__') ?
    ParsedForeignKey(name_withFk, null, null, null) : null;
    final field = ParsedField(e, name, type, mandatory, visible, fk);
    if (main) entity.mainField = field;
    return field;
  }).toList());
  return ret;
}

String parseFieldName(String text) {
  final fieldRaw = text.split(' ')[1];
  final name = parseFieldRemoveModifier(fieldRaw);
  return name;
}

String parseFieldRemoveFk(String text){
  if (text.contains('>')){
    return text.split('>')[0];
  }
  else
    return text;
}

String parseFieldType(String text) {
  return text.split(' ')[0];
}

String parseFieldModifier(String text) {
  final modifier = text.split(' ')[1];
  final Iterable<RegExpMatch> matches =
  RegExp(r"(.+?(?=\w))").allMatches(modifier);
  return matches.first.group(0);
}

String parseFieldRemoveModifier(String text) {
  final Iterable<RegExpMatch> matches = RegExp(r"(\w.*)").allMatches(text);
  if (matches.isEmpty) return '';

  return matches.first.group(0);
}

// MODELS
class ParsedEntity {
  String rawText;
  String rawFields;
  String name;
  List<ParsedField> fields;
  ParsedField mainField;
  List<ParsedEntity> relatedEntities;

  ParsedEntity(this.rawText, this.name, this.rawFields, this.mainField);

  @override
  String toString() {
    return 'Name: $name, Fields: $fields';
  }
}

class ParsedForeignKey {
  String rawText;
  ParsedEntity entity;
  ParsedField field;
  String name;

  ParsedForeignKey(this.rawText, this.entity, this.field, this.name);

  @override
  String toString() {
    return 'FKName: $name, FKEntity: ${entity.name}, FKField: ${field.name},';
  }
}

class ParsedField {
  final String rawText;
  final String name;
  final String type;
  final bool mandatory;
  final bool visible;
  ParsedForeignKey fk;

  ParsedField(this.rawText, this.name, this.type, this.mandatory, this.visible,
      this.fk);

  @override
  String toString() {
    return 'FieldName: $name, FieldType: $type, FieldMandatory: $mandatory,'
        ' FieldVisible: $visible, FieldFK: $fk';
  }
}
