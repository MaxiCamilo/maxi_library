import 'package:maxi_library/src/reflection/decorators/reflect.dart';

import 'mammal.dart';


@reflect
class Mutant<T> with Mammal {
  Type get mutantType => T;

  @override
  String sayHi(String namePerson) {
    throw ArgumentError('The mutant killed you');
  }

  void namedParameters({required String namedWithoutValue, String namedWithValue = ''}) {}
  void fixedParameters(String fixedWithoutValue, [String fixedWithValue = 'jeje']) {}
}
