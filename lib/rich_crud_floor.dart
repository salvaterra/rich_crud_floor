library rich_crud_floor;
import 'package:build/build.dart';
import 'dart:io';

import 'model_generator.dart';
import 'model_parser.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';


class RichCrud {
  void run(String txtClasses){
    final e = parse(txtClasses);
    final myClasses = genModels(e);

    //final emitter = DartEmitter();
    //print(DartFormatter().format('${myClasses.first.accept(emitter)}'));
    //print(e.first);

    StringBuffer s = StringBuffer('part of \'models.dart\';\n');

    for (final myClass in myClasses) {
      final emitter = DartEmitter();
      s.write(DartFormatter().format('${myClass.accept(emitter)}'));
    }

    final daos = genDAOs(e);
    for (final dao in daos) {
      final emitter = DartEmitter();
      s.write(DartFormatter().format('${dao.accept(emitter)}'));
    }

    final filename = 'test/models.g.dart';
    new File(filename).writeAsString(s.toString());
  }
}
// Generate
