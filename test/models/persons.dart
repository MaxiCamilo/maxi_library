import 'package:maxi_library/src/reflection/decorators/essential_key.dart';
import 'package:maxi_library/src/reflection/decorators/reflect.dart';

import 'mammal.dart';
import 'thing.dart';

@reflect
@EssentialKey()
class Persons extends Thing with Mammal {
  String firstName = 'super name';
  String lastName = '';
  bool isAdmin = false;
  int age = 0;

  static const int idealAge = 90;

  @override
  @EssentialKey()
  String sayHi(String namePerson, {bool bePolite = true}) {
    return 'Hi $namePerson! My name is $firstName $lastName';
  }

  @override
  bool get isHorrible => true;
}
