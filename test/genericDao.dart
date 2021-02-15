import 'package:floor/floor.dart';

abstract class GenericDao<T> {

  String gdName = T.toString();

  @insert
  Future<int> insertObj(T obj);

  @insert
  Future<void> insertObjs(List<T> objs);

  @update
  Future<void> updateObj(T obj);

  @update
  Future<void> updateObjs(List<T> objs);

  @delete
  Future<void> deleteObj(T obj);

  @delete
  Future<void> deleteObjs(List<T> objs);

  @Query('SELECT * FROM \$gdName WHERE id = :id')
  Future<T> findObjById(int id);

  @Query('SELECT * FROM \$gdName')
  Future<List<T>> findAllObjs();

  @Query('SELECT * FROM \$gdName')
  Stream<List<T>> findAllObjsAsStream();

  static GenericDao getDaoFromString(String dao){
    switch (dao){
      case 'person':
        return null;  //globals.mydb.houseDao;

    }
    throw ArgumentError(
        "Dao '$dao' does not exist");
  }

  @Query('\$q --:q')
  Future<T> getByQuery(String q);

  Future<T> getById(String id) {
    return getByQuery("SELECT * FROM ${T.toString()} WHERE id = \'$id\'");
  }
}

