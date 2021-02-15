# rich_crud_floor

Build rich CRUD models and views using Floor. Fully customizable, non-invasive, coupled view-model, relational entities with foreign key accessor. Inspired by Django.

## Goal

Go from this (text):

``#Person: String name;``

to a fully functional Floor entity and (in the future) CRUD view: create, read, update and delete, including dropbox for related foreign key entities (Person.getKids() yields List<Kids>).

## Features

You can create your models in text file, and the generator will do the rest.

Generated classes can have (all customizable, each feature can be switched on or off):

- Primary key added by default (int id)
- Generic localized ui-friendly methods for labels (e.g. CreditScore.getName() returns "Credit Score" which can be used as the title of the CRUD view such as "Your Credit Score"). Supports multi language. Also available for field names.
- Is field visible in the UI? Allow hiding fields from the UI.
- Is field required in the UI? Allow validation in the form UI.
- Main field - allow folding similar models. Example: If you have Car and Boat instances and want to aggregate their usd value, you can set Car.value and Boat.value and get as CrudEntity.getMainValueFieldName()
- Relationship models - automatically creates relationship between models. A person who owns a dog can do Person.getDogs() which will return a Dog() entity.
- Unliking models - used for deletion of foreign key. If a Person no longer owns a dog it can do Person.unlinkRelated().


## Why text?

The parser can easily be converted to @annotations in models in the future. Text is just more compact and non-invasive as there is no code hanging around and it is totally reproducible.

Syntax:

- Single Asterisk (*): field required in the database and UI
- Double Asterisk (**): field required in the database and UI and it is the main field (for aggregation)
- Question mark (!): do not show in the UI
- entity>child_field: estabilish a link between two entities and create relation methods such as Entity.getChild()

## Example generated class

From this:

```
#Person: String name; double **salary; int !dogId>dog__id;
#Dog: String **name; int size;
```

to this:


```
part of 'models.dart';
@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['dogId'],
      parentColumns: ['id'],
      entity: Dog,
    ),
  ],
)
class Person implements CrudEntity {
  Person({this.id, this.name, this.salary, this.dogId});

  Person.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        name = map['name'] as String,
        salary = map['salary'] as double,
        dogId = map['dogId'] as int;

  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;

  final double salary;

  final int dogId;

  Future<Dog> getDog() async {
    return await Dog().getDao().getById(this.dogId.toString());
  }

  bool operator ==(Object other) => other is Person && other.id == id;
  Future<Map<String, CrudEntity>> getRelatedFieldsInstances() async {
    return {
      'dogId': (await getDog()),
    };
  }

  Person withRelated({List<CrudEntity> entities, Map<String, dynamic> map}) {
    for (final entity in entities) {}
    return Person(
        id: map['id'] as int,
        name: map['name'] as String,
        salary: map['salary'] as double,
        dogId: map['dogId'] as int);
  }

  List<CrudEntity> getRelated() {
    return [];
  }

  String getName(BuildContext context) {
    final _l = AppLocalizations.of(context);
    return _l.person;
  }

  PersonDao getDao() {
    return globals.mydb.personDao;
  }

  String getMainValueFieldName() {
    return 'salary';
  }

  String getFieldLabel(BuildContext context, String fieldName) {
    final _l = AppLocalizations.of(context);
    switch (fieldName) {
      case 'name':
        return '${_l.name} (${_l.optional})';
      case 'salary':
        return _l.salary;
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Person'");
  }

  String getFieldType(String fieldName) {
    switch (fieldName) {
      case 'id':
        return 'int';
      case 'name':
        return 'String';
      case 'salary':
        return 'double';
      case 'dogId':
        return 'int';
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Person'");
  }

  bool isFieldRequired(String fieldName) {
    switch (fieldName) {
      case 'id':
        return true;
      case 'name':
        return false;
      case 'salary':
        return true;
      case 'dogId':
        return false;
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Person'");
  }

  dynamic getField(String fieldName) {
    switch (fieldName) {
      case 'id':
        return this.id;
      case 'id':
        return this.id;
      case 'name':
        return this.name;
      case 'salary':
        return this.salary;
      case 'dogId':
        return this.dogId;
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Person'");
  }

  Map<String, dynamic> getVisibleFields() {
    return {
      'name': name,
      'salary': salary,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'salary': salary,
      'dogId': dogId,
    };
  }

  Person copyWith(Map<String, dynamic> fields) {
    var newObj = this.toMap();
    for (final field in fields.entries) newObj[field.key] = field.value;
    return Person.fromMap(newObj);
  }

  Future<void> unlinkRelated() async {}
}
@entity
class Dog implements CrudEntity {
  Dog({this.id, this.name, this.size});

  Dog.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        name = map['name'] as String,
        size = map['size'] as int;

  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;

  final int size;

  bool operator ==(Object other) => other is Dog && other.id == id;
  Future<Map<String, CrudEntity>> getRelatedFieldsInstances() async {
    return {};
  }

  Dog withRelated({List<CrudEntity> entities, Map<String, dynamic> map}) {
    for (final entity in entities) {}
    return Dog(
        id: map['id'] as int,
        name: map['name'] as String,
        size: map['size'] as int);
  }

  List<CrudEntity> getRelated() {
    return [
      Person(),
    ];
  }

  String getName(BuildContext context) {
    final _l = AppLocalizations.of(context);
    return _l.dog;
  }

  DogDao getDao() {
    return globals.mydb.dogDao;
  }

  String getMainValueFieldName() {
    return 'name';
  }

  String getFieldLabel(BuildContext context, String fieldName) {
    final _l = AppLocalizations.of(context);
    switch (fieldName) {
      case 'name':
        return _l.name;
      case 'size':
        return '${_l.size} (${_l.optional})';
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Dog'");
  }

  String getFieldType(String fieldName) {
    switch (fieldName) {
      case 'id':
        return 'int';
      case 'name':
        return 'String';
      case 'size':
        return 'int';
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Dog'");
  }

  bool isFieldRequired(String fieldName) {
    switch (fieldName) {
      case 'id':
        return true;
      case 'name':
        return true;
      case 'size':
        return false;
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Dog'");
  }

  dynamic getField(String fieldName) {
    switch (fieldName) {
      case 'id':
        return this.id;
      case 'id':
        return this.id;
      case 'name':
        return this.name;
      case 'size':
        return this.size;
    }
    throw ArgumentError(
        "FieldName '$fieldName' does not exist as part of class 'Dog'");
  }

  Map<String, dynamic> getVisibleFields() {
    return {
      'name': name,
      'size': size,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
    };
  }

  Dog copyWith(Map<String, dynamic> fields) {
    var newObj = this.toMap();
    for (final field in fields.entries) newObj[field.key] = field.value;
    return Dog.fromMap(newObj);
  }

  Future<void> unlinkRelated() async {
    Person()
        .getDao()
        .updateObj((await this.getPerson()).copyWith({'dogId': null}));
  }
}
@dao
abstract class PersonDao extends GenericDao<Person> {}
@dao
abstract class DogDao extends GenericDao<Dog> {}
```