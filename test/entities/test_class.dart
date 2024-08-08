import 'dart:developer';

import 'package:maxi_library/src/reflection/decorators/primary_key.dart';

import 'reflectors_generated.dart';

@reflector
enum TestClassType { stupid, idiot, motherFucker }


@reflector
class TestClass {
  @PrimaryKey()
  int identifier = 0;

  String get whatIDo => 'Be a stupid class';

  DateTime anyDatetime;

 

  TestClassType get type => TestClassType.idiot;

  String _name = 'maxi';

  String get name => _name;

  TestClass() : anyDatetime = DateTime.now();

  factory TestClass.superHuman({required String name, required DateTime date}) {
    log('Creating a superhuman');
    return TestClass()
      ..name = name
      ..anyDatetime = date;
  }

  void getter() {
    print('Hi $_name!');
  }

  static void getterStatic() {
    print('Hi maxi!');
  }

  set name(dynamic newValue) {
    log('Now, the name has been changed to a type ${newValue.runtimeType} and it is $newValue');
    _name = newValue.toString();
  }

  @override
  String toString() {
    return 'This is $name and the date is $anyDatetime';
  }
}
