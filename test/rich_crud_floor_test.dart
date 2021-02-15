import 'package:flutter_test/flutter_test.dart';

import 'package:rich_crud_floor/rich_crud_floor.dart';

void main() {

  group('my tests', () {
    test('bla', (){
      const classes = """
      #Person: String name; double **salary; int !dogId>dog__id;
      #Dog: String **name; int size;
      """;

      RichCrud rich = RichCrud();
      rich.run(classes);
    });
  });

}
