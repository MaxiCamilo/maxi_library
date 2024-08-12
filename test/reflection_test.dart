@Timeout(Duration(minutes: 30))
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

import 'entities/instance_reflection_test.dart';
import 'entities/reflectors_generated.dart';

void main() {
  group('Reflection test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Started reflectors', () {
      InstanceReflectionTest().initializeReflectable();
    });

    test('Invoke static method', () {
      InstanceReflectionTest().initializeReflectable();

      final classTest = ReflectionManager.getReflectionEntity(TestClass);
      classTest.callMethod(name: 'getterStatic', instance: null, fixedParametersValues: [], namedParametesValues: {});
    });

    test('Build entity and change field', () {
      InstanceReflectionTest().initializeReflectable();

      final classTest = ReflectionManager.getReflectionEntity(TestClass);
      final newItem = classTest.buildEntity();
      log('Type de entity test: ${classTest.getProperty(name: 'name', instance: newItem)}');
      classTest.changeProperty(name: 'name', instance: newItem, newValue: 'Pepito');
      log('Now, type de entity test: ${classTest.getProperty(name: 'name', instance: newItem)}');

      log('It is "${classTest.callMethod(name: 'whatIDo', instance: newItem, fixedParametersValues: [], namedParametesValues: {})}"');
    });

    test('Using other builders', () {
      InstanceReflectionTest().initializeReflectable();

      final classTest = ReflectionManager.getReflectionEntity(TestClass);
      final newItem = classTest.buildEntity(selectedBuild: 'superHuman', namedParametersValues: const {'name': 'Orito', 'date': 123456});
      log('Type de entity test: ${classTest.getProperty(name: 'anyDatetime', instance: newItem)}');
    });

    test('Clone objetct', () {
      InstanceReflectionTest().initializeReflectable();

      final classTest = ReflectionManager.getReflectionEntity(TestClass);
      final newItem = classTest.buildEntity(selectedBuild: 'superHuman', namedParametersValues: {'name': 'Maxitito', 'date': DateTime.now()});

      log(newItem.toString());

      final clon = classTest.cloneObject(newItem);
      log('1. ${(classTest.getProperty(name: 'anyDatetime', instance: clon) as DateTime).millisecondsSinceEpoch} == ${(classTest.getProperty(name: 'anyDatetime', instance: newItem) as DateTime).millisecondsSinceEpoch}');

      classTest.changeProperty(name: 'anyDatetime', instance: clon, newValue: DateTime.now());

      log('2. ${(classTest.getProperty(name: 'anyDatetime', instance: clon) as DateTime).millisecondsSinceEpoch} != ${(classTest.getProperty(name: 'anyDatetime', instance: newItem) as DateTime).millisecondsSinceEpoch}');
    });

    test('Get and change primary key', () {
      InstanceReflectionTest().initializeReflectable();
      final classTest = ReflectionManager.getReflectionEntity(TestClass);
      final newItem = classTest.buildEntity();

      log('The item identifier is: ${classTest.getPrimaryKey(instance: newItem)}');

      classTest.changePrimaryKey(instance: newItem, newId: 21);

      log('The new item identifier is: ${classTest.getPrimaryKey(instance: newItem)}');
    });

    test('Excute in another thread', () async {
      InstanceReflectionTest().initializeReflectable();
      final classTest = ReflectionManager.getReflectionEntity(TestClass);
      final newItem = classTest.buildEntity();
      classTest.changePrimaryKey(instance: newItem, newId: 21);

      final newId = await ThreadManager.callFunctionAsAnonymous(
          parameters: InvocationParameters.only(newItem),
          function: (x) async {
            final classTest = ReflectionManager.getReflectionEntity(TestClass);
            log('The item identifier is: ${classTest.getPrimaryKey(instance: x.firts())}');

            return 221;
          });

      classTest.changePrimaryKey(instance: newItem, newId: newId);

      log('The new item identifier is: ${classTest.getPrimaryKey(instance: newItem)}');
    });

    test('Use custom builder', () {
      InstanceReflectionTest().initializeReflectable();

      final classTest = ReflectionManager.getReflectionEntity(SecondTestClass);
      final newItem = classTest.buildEntity();

      log(newItem.toString());
    });

    test('Change property list', () {
      InstanceReflectionTest().initializeReflectable();
      final classTest = ReflectionManager.getReflectionEntity(SecondTestClass);
      final newItem = classTest.buildEntity();

      classTest.changeProperty(name: 'superList', instance: newItem, newValue: 5);
      log(classTest.getProperty(name: 'superList', instance: newItem).toString());
    });

    test('Change property list', () {
      InstanceReflectionTest().initializeReflectable();
      final classTest = ReflectionManager.getReflectionEntity(SecondTestClass);
      final newItem = classTest.buildEntity();

      classTest.changeProperty(name: 'superList', instance: newItem, newValue: 5);
      log(classTest.getProperty(name: 'superList', instance: newItem).toString());
    });

    test('Call a method with a parameter that has a value generator', () {
      InstanceReflectionTest().initializeReflectable();
      final classTest = ReflectionManager.getReflectionEntity(SecondTestClass);
      final newItem = classTest.buildEntity();

      classTest.callMethod(name: 'getterPerson', instance: newItem, fixedParametersValues: [987]);
    });

    test('Testing the serialization and deserialization of entities', () {
      InstanceReflectionTest().initializeReflectable();
      final classTest = ReflectionManager.getReflectionEntity(ThirdTestClass);
      final newItem = classTest.buildEntity();

      classTest.changeFieldValue(name: 'identifier', instance: newItem, newValue: 21);
      classTest.changeFieldValue(name: 'name', instance: newItem, newValue: 'Oreo');
      classTest.changeFieldValue(name: 'isAdmin', instance: newItem, newValue: true);
      classTest.changeFieldValue(name: 'age', instance: newItem, newValue: 55);

      final mapa = classTest.serializeToJson(value: newItem);

      log(mapa);

      final jsonItem = classTest.interpretationFromJson(rawJson: '{"isAdmin":true,"age":55,"age":17}');
      classTest.changeFieldValue(name: 'age', instance: jsonItem, newValue: 80);
      log(classTest.serializeToJson(value: jsonItem));
    });
  });
}
