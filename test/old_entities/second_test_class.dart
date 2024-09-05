import 'dart:developer';
import 'dart:math' as math;

import 'package:maxi_library/maxi_library.dart';

@reflect
class TestClassMakeIntList extends GeneratorList<int> {
  const TestClassMakeIntList();
}

@reflect
class TestClassMakeRandomText with IValueGenerator {
  const TestClassMakeRandomText();

  @override
  cloneObject(originalItem) {
    return generateEmptryObject();
  }

  @override
  convertObject(originalItem) {
    return generateEmptryObject();
  }

  @override
  generateEmptryObject() {
    final random = math.Random();

    final number = random.nextInt(999);

    return number.toString();
  }

  @override
  bool isCompatible(item) {
    return false;
  }

  @override
  bool isTypeCompatible(Type type) {
    return false;
  }
}

@reflect
class SecondTestClassGenerator extends ClassBuilderReflection<SecondTestClass> {
  const SecondTestClassGenerator();
  @override
  SecondTestClass generateByMap({required Map<String, dynamic> namedParametesValues}) {
    return SecondTestClass();
  }

  @override
  SecondTestClass generateByMethod({required List fixedParametersValues, required Map<String, dynamic> namedParametesValues}) {
    return SecondTestClass();
  }
}

@reflect
@SecondTestClassGenerator()
class SecondTestClass {
  @TestClassMakeIntList()
  List<int> superList = [1, 2, 3, 4];

  @TestClassMakeRandomText()
  String randomText = 'kakakaka';

  void getterPerson(@TestClassMakeRandomText() String getterName) {
    log('Hi $getterName');
  }
}
