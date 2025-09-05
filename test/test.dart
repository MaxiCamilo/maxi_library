// ignore_for_file: unnecessary_const, unnecessary_import, duplicate_import, unused_import

import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/decorators/reflect.dart';
import 'package:maxi_library/src/reflection/decorators/essential_key.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:math';
import 'dart:async';

import 'functionalities/remote_functionality.dart';
import 'functionalities/remote_functionality_stream.dart';
import 'models/mammal.dart';
import 'models/mutant.dart';
import 'models/persons.dart';
import 'models/pets.dart';
import 'models/thing.dart';
import 'old_entities/second_test_class.dart';
import 'old_entities/test_class.dart';
import 'old_entities/third_test_class.dart';
import 'services/first_service.dart';
import 'services/second_service.dart';

class _TypeAnimalEnum extends TypeEnumeratorReflector {
  const _TypeAnimalEnum()
      : super(
          type: TypeAnimal,
          name: 'TypeAnimal',
          annotations: const [reflect],
          optionsList: const [
            EnumOption(annotations: const [], value: TypeAnimal.cat),
            EnumOption(annotations: const [], value: TypeAnimal.dog),
            EnumOption(annotations: const [], value: TypeAnimal.bird),
            EnumOption(annotations: const [], value: TypeAnimal.monster),
          ],
        );
}

class _TestClassTypeEnum extends TypeEnumeratorReflector {
  const _TestClassTypeEnum()
      : super(
          type: TestClassType,
          name: 'TestClassType',
          annotations: const [reflect],
          optionsList: const [
            EnumOption(annotations: const [], value: TestClassType.stupid),
            EnumOption(annotations: const [], value: TestClassType.idiot),
            EnumOption(annotations: const [], value: TestClassType.motherFucker),
          ],
        );
}

/*----------------------------------   Class Mammal   ----------------------------------*/

/*MAMMAL FIELDS*/

class _MammalnumberOfLegs extends GeneratedReflectedField<Mammal, int> with GeneratedReflectedModifiableField<Mammal, int> {
  const _MammalnumberOfLegs();
  @override
  List get annotations => const [];

  @override
  String get name => 'numberOfLegs';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 0;

  @override
  int getReservedValue({required Mammal? entity}) => entity!.numberOfLegs;
  @override
  void setReservedValue({required Mammal? entity, required int newValue}) => entity!.numberOfLegs = newValue;
}

/*MAMMAL METHODS*/

class _MammalsayHiMethod extends GeneratedReflectedMethod<Mammal, String> {
  const _MammalsayHiMethod();
  @override
  String get name => 'sayHi';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'namePerson',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required Mammal? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.sayHi(
        _fix0.getValueFromList(fixedValues),
      );
}

/*MAMMAL INSTANCE*/

class _Mammal extends GeneratedReflectedClass<Mammal> {
  const _Mammal();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => true;

  @override
  bool get isMixin => true;

  @override
  String get name => 'Mammal';

  @override
  List<GeneratedReflectedMethod> get methods => const [_MammalsayHiMethod()];

  @override
  List<GeneratedReflectedField> get fields => const [_MammalnumberOfLegs()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class Mutant   ----------------------------------*/

/*MUTANT FIELDS*/

/*MUTANT METHODS*/

class _MutantmutantTypeGetter extends GeneratedReflectedMethod<Mutant, Type> {
  const _MutantmutantTypeGetter();
  @override
  String get name => 'mutantType';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Type callReservedMethod({required Mutant? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.mutantType;
}

class _MutantsayHiMethod extends GeneratedReflectedMethod<Mutant, String> {
  const _MutantsayHiMethod();
  @override
  String get name => 'sayHi';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'namePerson',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required Mutant? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.sayHi(
        _fix0.getValueFromList(fixedValues),
      );
}

class _MutantnamedParametersMethod extends GeneratedReflectedMethod<Mutant, dynamic> {
  const _MutantnamedParametersMethod();
  @override
  String get name => 'namedParameters';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  static const _namnamedWithoutValue = GeneratedReflectedNamedParameter<String>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'namedWithoutValue',
  );
  static const _namnamedWithValue = GeneratedReflectedNamedParameter<String>(
    annotations: const [],
    defaultValue: '',
    hasDefaultValue: true,
    acceptNulls: false,
    name: 'namedWithValue',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namnamedWithoutValue, _namnamedWithValue];

  @override
  dynamic callReservedMethod({required Mutant? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.namedParameters(
        namedWithoutValue: _namnamedWithoutValue.getValueFromMap(namedValues),
        namedWithValue: _namnamedWithValue.getValueFromMap(namedValues),
      );
}

class _MutantfixedParametersMethod extends GeneratedReflectedMethod<Mutant, dynamic> {
  const _MutantfixedParametersMethod();
  @override
  String get name => 'fixedParameters';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'fixedWithoutValue',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  static const _fix1 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'fixedWithValue',
    position: 1,
    hasDefaultValue: true,
    defaultValue: 'jeje',
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0, _fix1];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required Mutant? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.fixedParameters(
        _fix0.getValueFromList(fixedValues),
        _fix1.getValueFromList(fixedValues),
      );
}

class _MutantBuilder extends GeneratedReflectedMethod<Mutant, Mutant> {
  const _MutantBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Mutant callReservedMethod({required Mutant? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => Mutant();
}

/*MUTANT INSTANCE*/

class _Mutant extends GeneratedReflectedClass<Mutant> {
  const _Mutant();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [Mammal];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'Mutant';

  @override
  List<GeneratedReflectedMethod> get methods => const [_MutantmutantTypeGetter(), _MutantsayHiMethod(), _MutantnamedParametersMethod(), _MutantfixedParametersMethod(), _MutantBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class Persons   ----------------------------------*/

/*PERSONS FIELDS*/

class _PersonsfirstName extends GeneratedReflectedField<Persons, String> with GeneratedReflectedModifiableField<Persons, String> {
  const _PersonsfirstName();
  @override
  List get annotations => const [];

  @override
  String get name => 'firstName';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  String? get defaulValue => 'super name';

  @override
  String getReservedValue({required Persons? entity}) => entity!.firstName;
  @override
  void setReservedValue({required Persons? entity, required String newValue}) => entity!.firstName = newValue;
}

class _PersonslastName extends GeneratedReflectedField<Persons, String> with GeneratedReflectedModifiableField<Persons, String> {
  const _PersonslastName();
  @override
  List get annotations => const [];

  @override
  String get name => 'lastName';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  String? get defaulValue => '';

  @override
  String getReservedValue({required Persons? entity}) => entity!.lastName;
  @override
  void setReservedValue({required Persons? entity, required String newValue}) => entity!.lastName = newValue;
}

class _PersonsisAdmin extends GeneratedReflectedField<Persons, bool> with GeneratedReflectedModifiableField<Persons, bool> {
  const _PersonsisAdmin();
  @override
  List get annotations => const [];

  @override
  String get name => 'isAdmin';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  bool? get defaulValue => false;

  @override
  bool getReservedValue({required Persons? entity}) => entity!.isAdmin;
  @override
  void setReservedValue({required Persons? entity, required bool newValue}) => entity!.isAdmin = newValue;
}

class _Personsage extends GeneratedReflectedField<Persons, int> with GeneratedReflectedModifiableField<Persons, int> {
  const _Personsage();
  @override
  List get annotations => const [];

  @override
  String get name => 'age';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 0;

  @override
  int getReservedValue({required Persons? entity}) => entity!.age;
  @override
  void setReservedValue({required Persons? entity, required int newValue}) => entity!.age = newValue;
}

class _PersonsidealAge extends GeneratedReflectedField<Persons, int> {
  const _PersonsidealAge();
  @override
  List get annotations => const [];

  @override
  String get name => 'idealAge';

  @override
  bool get isStatic => true;

  @override
  bool get isConst => true;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 90;

  @override
  int getReservedValue({required Persons? entity}) => Persons.idealAge;
}

/*PERSONS METHODS*/

class _PersonssayHiMethod extends GeneratedReflectedMethod<Persons, String> {
  const _PersonssayHiMethod();
  @override
  String get name => 'sayHi';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override, EssentialKey()];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'namePerson',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  static const _nambePolite = GeneratedReflectedNamedParameter<bool>(
    annotations: const [],
    defaultValue: true,
    hasDefaultValue: true,
    acceptNulls: false,
    name: 'bePolite',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_nambePolite];

  @override
  String callReservedMethod({required Persons? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.sayHi(
        _fix0.getValueFromList(fixedValues),
        bePolite: _nambePolite.getValueFromMap(namedValues),
      );
}

class _PersonsisHorribleGetter extends GeneratedReflectedMethod<Persons, bool> {
  const _PersonsisHorribleGetter();
  @override
  String get name => 'isHorrible';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  bool callReservedMethod({required Persons? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.isHorrible;
}

class _PersonsBuilder extends GeneratedReflectedMethod<Persons, Persons> {
  const _PersonsBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Persons callReservedMethod({required Persons? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => Persons();
}

/*PERSONS INSTANCE*/

class _Persons extends GeneratedReflectedClass<Persons> {
  const _Persons();
  @override
  List get annotations => const [reflect, EssentialKey()];

  @override
  Type? get baseClass => Thing;

  @override
  List<Type> get classThatImplement => const [Mammal];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'Persons';

  @override
  List<GeneratedReflectedMethod> get methods => const [_PersonssayHiMethod(), _PersonsisHorribleGetter(), _PersonsBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [_PersonsfirstName(), _PersonslastName(), _PersonsisAdmin(), _Personsage(), _PersonsidealAge()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class Pets   ----------------------------------*/

/*PETS FIELDS*/

class _Petsname extends GeneratedReflectedField<Pets, String> with GeneratedReflectedModifiableField<Pets, String> {
  const _Petsname();
  @override
  List get annotations => const [];

  @override
  String get name => 'name';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  String? get defaulValue => '';

  @override
  String getReservedValue({required Pets? entity}) => entity!.name;
  @override
  void setReservedValue({required Pets? entity, required String newValue}) => entity!.name = newValue;
}

class _Petsage extends GeneratedReflectedField<Pets, int> with GeneratedReflectedModifiableField<Pets, int> {
  const _Petsage();
  @override
  List get annotations => const [];

  @override
  String get name => 'age';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 0;

  @override
  int getReservedValue({required Pets? entity}) => entity!.age;
  @override
  void setReservedValue({required Pets? entity, required int newValue}) => entity!.age = newValue;
}

class _Petstype extends GeneratedReflectedField<Pets, TypeAnimal> with GeneratedReflectedModifiableField<Pets, TypeAnimal> {
  const _Petstype();
  @override
  List get annotations => const [];

  @override
  String get name => 'type';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  TypeAnimal? get defaulValue => TypeAnimal.cat;

  @override
  TypeAnimal getReservedValue({required Pets? entity}) => entity!.type;
  @override
  void setReservedValue({required Pets? entity, required TypeAnimal newValue}) => entity!.type = newValue;
}

class _PetsisBeautiful extends GeneratedReflectedField<Pets, bool> with GeneratedReflectedModifiableField<Pets, bool> {
  const _PetsisBeautiful();
  @override
  List get annotations => const [];

  @override
  String get name => 'isBeautiful';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  bool? get defaulValue => true;

  @override
  bool getReservedValue({required Pets? entity}) => entity!.isBeautiful;
  @override
  void setReservedValue({required Pets? entity, required bool newValue}) => entity!.isBeautiful = newValue;
}

/*PETS METHODS*/

class _PetsdoesThisThingMeowGetter extends GeneratedReflectedMethod<Pets, bool> {
  const _PetsdoesThisThingMeowGetter();
  @override
  String get name => 'doesThisThingMeow';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  bool callReservedMethod({required Pets? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.doesThisThingMeow;
}

class _PetsputNickNameSetter extends GeneratedReflectedMethod<Pets, dynamic> {
  const _PetsputNickNameSetter();
  @override
  String get name => 'putNickName';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.setMethod;

  @override
  List get annotations => const [];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'nickname',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required Pets? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.putNickName = _fix0.getValueFromList(fixedValues);
}

class _PetssayHiMethod extends GeneratedReflectedMethod<Pets, String> {
  const _PetssayHiMethod();
  @override
  String get name => 'sayHi';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [],
    name: 'namePerson',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required Pets? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.sayHi(
        _fix0.getValueFromList(fixedValues),
      );
}

class _PetsBuilder extends GeneratedReflectedMethod<Pets, Pets> {
  const _PetsBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Pets callReservedMethod({required Pets? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => Pets();
}

class _PetsmakeMonsterFactorie extends GeneratedReflectedMethod<Pets, Pets> {
  const _PetsmakeMonsterFactorie();
  @override
  String get name => 'makeMonster';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.factoryMethod;

  @override
  List get annotations => const [];

  static const _namname = GeneratedReflectedNamedParameter<String>(
    annotations: const [],
    defaultValue: 'zombie',
    hasDefaultValue: true,
    acceptNulls: false,
    name: 'name',
  );
  static const _namage = GeneratedReflectedNamedParameter<int>(
    annotations: const [],
    defaultValue: 69,
    hasDefaultValue: true,
    acceptNulls: false,
    name: 'age',
  );
  static const _namtest = GeneratedReflectedNamedParameter<TestConst>(
    annotations: const [],
    defaultValue: const TestConst(name: 'jeje'),
    hasDefaultValue: true,
    acceptNulls: false,
    name: 'test',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namname, _namage, _namtest];

  @override
  Pets callReservedMethod({required Pets? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => Pets.makeMonster(
        name: _namname.getValueFromMap(namedValues),
        age: _namage.getValueFromMap(namedValues),
        test: _namtest.getValueFromMap(namedValues),
      );
}

/*PETS INSTANCE*/

class _Pets extends GeneratedReflectedClass<Pets> {
  const _Pets();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [Mammal];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'Pets';

  @override
  List<GeneratedReflectedMethod> get methods => const [_PetsdoesThisThingMeowGetter(), _PetsputNickNameSetter(), _PetssayHiMethod(), _PetsBuilder(), _PetsmakeMonsterFactorie()];

  @override
  List<GeneratedReflectedField> get fields => const [_Petsname(), _Petsage(), _Petstype(), _PetsisBeautiful()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class Thing   ----------------------------------*/

/*THING FIELDS*/

/*THING METHODS*/

class _ThingisHorribleGetter extends GeneratedReflectedMethod<Thing, bool> {
  const _ThingisHorribleGetter();
  @override
  String get name => 'isHorrible';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  bool callReservedMethod({required Thing? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.isHorrible;
}

/*THING INSTANCE*/

class _Thing extends GeneratedReflectedClass<Thing> {
  const _Thing();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => true;

  @override
  bool get isMixin => false;

  @override
  String get name => 'Thing';

  @override
  List<GeneratedReflectedMethod> get methods => const [_ThingisHorribleGetter()];

  @override
  List<GeneratedReflectedField> get fields => const [];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class TestClassMakeIntList   ----------------------------------*/

/*TESTCLASSMAKEINTLIST FIELDS*/

/*TESTCLASSMAKEINTLIST METHODS*/

class _TestClassMakeIntListBuilder extends GeneratedReflectedMethod<TestClassMakeIntList, TestClassMakeIntList> {
  const _TestClassMakeIntListBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  TestClassMakeIntList callReservedMethod({required TestClassMakeIntList? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => TestClassMakeIntList();
}

/*TESTCLASSMAKEINTLIST INSTANCE*/

class _TestClassMakeIntList extends GeneratedReflectedClass<TestClassMakeIntList> {
  const _TestClassMakeIntList();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => GeneratorList;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'TestClassMakeIntList';

  @override
  List<GeneratedReflectedMethod> get methods => const [_TestClassMakeIntListBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class TestClassMakeRandomText   ----------------------------------*/

/*TESTCLASSMAKERANDOMTEXT FIELDS*/

/*TESTCLASSMAKERANDOMTEXT METHODS*/

class _TestClassMakeRandomTextcloneObjectMethod extends GeneratedReflectedMethod<TestClassMakeRandomText, dynamic> {
  const _TestClassMakeRandomTextcloneObjectMethod();
  @override
  String get name => 'cloneObject';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _fix0 = GeneratedReflectedFixedParameter<dynamic>(
    annotations: const [],
    name: 'originalItem',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required TestClassMakeRandomText? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.cloneObject(
        _fix0.getValueFromList(fixedValues),
      );
}

class _TestClassMakeRandomTextconvertObjectMethod extends GeneratedReflectedMethod<TestClassMakeRandomText, dynamic> {
  const _TestClassMakeRandomTextconvertObjectMethod();
  @override
  String get name => 'convertObject';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _fix0 = GeneratedReflectedFixedParameter<dynamic>(
    annotations: const [],
    name: 'originalItem',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required TestClassMakeRandomText? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.convertObject(
        _fix0.getValueFromList(fixedValues),
      );
}

class _TestClassMakeRandomTextgenerateEmptryObjectMethod extends GeneratedReflectedMethod<TestClassMakeRandomText, dynamic> {
  const _TestClassMakeRandomTextgenerateEmptryObjectMethod();
  @override
  String get name => 'generateEmptryObject';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required TestClassMakeRandomText? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.generateEmptryObject();
}

class _TestClassMakeRandomTextisCompatibleMethod extends GeneratedReflectedMethod<TestClassMakeRandomText, bool> {
  const _TestClassMakeRandomTextisCompatibleMethod();
  @override
  String get name => 'isCompatible';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _fix0 = GeneratedReflectedFixedParameter<dynamic>(
    annotations: const [],
    name: 'item',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  bool callReservedMethod({required TestClassMakeRandomText? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.isCompatible(
        _fix0.getValueFromList(fixedValues),
      );
}

class _TestClassMakeRandomTextisTypeCompatibleMethod extends GeneratedReflectedMethod<TestClassMakeRandomText, bool> {
  const _TestClassMakeRandomTextisTypeCompatibleMethod();
  @override
  String get name => 'isTypeCompatible';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _fix0 = GeneratedReflectedFixedParameter<Type>(
    annotations: const [],
    name: 'type',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  bool callReservedMethod({required TestClassMakeRandomText? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.isTypeCompatible(
        _fix0.getValueFromList(fixedValues),
      );
}

class _TestClassMakeRandomTextBuilder extends GeneratedReflectedMethod<TestClassMakeRandomText, TestClassMakeRandomText> {
  const _TestClassMakeRandomTextBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  TestClassMakeRandomText callReservedMethod({required TestClassMakeRandomText? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => TestClassMakeRandomText();
}

/*TESTCLASSMAKERANDOMTEXT INSTANCE*/

class _TestClassMakeRandomText extends GeneratedReflectedClass<TestClassMakeRandomText> {
  const _TestClassMakeRandomText();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [IValueGenerator];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'TestClassMakeRandomText';

  @override
  List<GeneratedReflectedMethod> get methods => const [
        _TestClassMakeRandomTextcloneObjectMethod(),
        _TestClassMakeRandomTextconvertObjectMethod(),
        _TestClassMakeRandomTextgenerateEmptryObjectMethod(),
        _TestClassMakeRandomTextisCompatibleMethod(),
        _TestClassMakeRandomTextisTypeCompatibleMethod(),
        _TestClassMakeRandomTextBuilder()
      ];

  @override
  List<GeneratedReflectedField> get fields => const [];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class SecondTestClassGenerator   ----------------------------------*/

/*SECONDTESTCLASSGENERATOR FIELDS*/

/*SECONDTESTCLASSGENERATOR METHODS*/

class _SecondTestClassGeneratorgenerateByMapMethod extends GeneratedReflectedMethod<SecondTestClassGenerator, SecondTestClass> {
  const _SecondTestClassGeneratorgenerateByMapMethod();
  @override
  String get name => 'generateByMap';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _namnamedParametesValues = GeneratedReflectedNamedParameter<Map<String, dynamic>>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'namedParametesValues',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namnamedParametesValues];

  @override
  SecondTestClass callReservedMethod({required SecondTestClassGenerator? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.generateByMap(
        namedParametesValues: _namnamedParametesValues.getValueFromMap(namedValues),
      );
}

class _SecondTestClassGeneratorgenerateByMethodMethod extends GeneratedReflectedMethod<SecondTestClassGenerator, SecondTestClass> {
  const _SecondTestClassGeneratorgenerateByMethodMethod();
  @override
  String get name => 'generateByMethod';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _namfixedParametersValues = GeneratedReflectedNamedParameter<List>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'fixedParametersValues',
  );
  static const _namnamedParametesValues = GeneratedReflectedNamedParameter<Map<String, dynamic>>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'namedParametesValues',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namfixedParametersValues, _namnamedParametesValues];

  @override
  SecondTestClass callReservedMethod({required SecondTestClassGenerator? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.generateByMethod(
        fixedParametersValues: _namfixedParametersValues.getValueFromMap(namedValues),
        namedParametesValues: _namnamedParametesValues.getValueFromMap(namedValues),
      );
}

class _SecondTestClassGeneratorBuilder extends GeneratedReflectedMethod<SecondTestClassGenerator, SecondTestClassGenerator> {
  const _SecondTestClassGeneratorBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  SecondTestClassGenerator callReservedMethod({required SecondTestClassGenerator? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => SecondTestClassGenerator();
}

/*SECONDTESTCLASSGENERATOR INSTANCE*/

class _SecondTestClassGenerator extends GeneratedReflectedClass<SecondTestClassGenerator> {
  const _SecondTestClassGenerator();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => ClassBuilderReflection;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'SecondTestClassGenerator';

  @override
  List<GeneratedReflectedMethod> get methods => const [_SecondTestClassGeneratorgenerateByMapMethod(), _SecondTestClassGeneratorgenerateByMethodMethod(), _SecondTestClassGeneratorBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class SecondTestClass   ----------------------------------*/

/*SECONDTESTCLASS FIELDS*/

class _SecondTestClasssuperList extends GeneratedReflectedField<SecondTestClass, List<int>> with GeneratedReflectedModifiableField<SecondTestClass, List<int>> {
  const _SecondTestClasssuperList();
  @override
  List get annotations => const [TestClassMakeIntList()];

  @override
  String get name => 'superList';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  List<int>? get defaulValue => [1, 2, 3, 4];

  @override
  List<int> getReservedValue({required SecondTestClass? entity}) => entity!.superList;
  @override
  void setReservedValue({required SecondTestClass? entity, required List<int> newValue}) => entity!.superList = newValue;
}

class _SecondTestClassrandomText extends GeneratedReflectedField<SecondTestClass, String> with GeneratedReflectedModifiableField<SecondTestClass, String> {
  const _SecondTestClassrandomText();
  @override
  List get annotations => const [TestClassMakeRandomText()];

  @override
  String get name => 'randomText';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  String? get defaulValue => 'kakakaka';

  @override
  String getReservedValue({required SecondTestClass? entity}) => entity!.randomText;
  @override
  void setReservedValue({required SecondTestClass? entity, required String newValue}) => entity!.randomText = newValue;
}

/*SECONDTESTCLASS METHODS*/

class _SecondTestClassgetterPersonMethod extends GeneratedReflectedMethod<SecondTestClass, dynamic> {
  const _SecondTestClassgetterPersonMethod();
  @override
  String get name => 'getterPerson';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  static const _fix0 = GeneratedReflectedFixedParameter<String>(
    annotations: const [TestClassMakeRandomText()],
    name: 'getterName',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required SecondTestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.getterPerson(
        _fix0.getValueFromList(fixedValues),
      );
}

class _SecondTestClassBuilder extends GeneratedReflectedMethod<SecondTestClass, SecondTestClass> {
  const _SecondTestClassBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  SecondTestClass callReservedMethod({required SecondTestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => SecondTestClass();
}

/*SECONDTESTCLASS INSTANCE*/

class _SecondTestClass extends GeneratedReflectedClass<SecondTestClass> {
  const _SecondTestClass();
  @override
  List get annotations => const [reflect, SecondTestClassGenerator()];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'SecondTestClass';

  @override
  List<GeneratedReflectedMethod> get methods => const [_SecondTestClassgetterPersonMethod(), _SecondTestClassBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [_SecondTestClasssuperList(), _SecondTestClassrandomText()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class TestClass   ----------------------------------*/

/*TESTCLASS FIELDS*/

class _TestClassidentifier extends GeneratedReflectedField<TestClass, int> with GeneratedReflectedModifiableField<TestClass, int> {
  const _TestClassidentifier();
  @override
  List get annotations => const [PrimaryKey()];

  @override
  String get name => 'identifier';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 0;

  @override
  int getReservedValue({required TestClass? entity}) => entity!.identifier;
  @override
  void setReservedValue({required TestClass? entity, required int newValue}) => entity!.identifier = newValue;
}

class _TestClassanyDatetime extends GeneratedReflectedField<TestClass, DateTime> with GeneratedReflectedModifiableField<TestClass, DateTime> {
  const _TestClassanyDatetime();
  @override
  List get annotations => const [];

  @override
  String get name => 'anyDatetime';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  DateTime? get defaulValue => null;

  @override
  DateTime getReservedValue({required TestClass? entity}) => entity!.anyDatetime;
  @override
  void setReservedValue({required TestClass? entity, required DateTime newValue}) => entity!.anyDatetime = newValue;
}

/*TESTCLASS METHODS*/

class _TestClasswhatIDoGetter extends GeneratedReflectedMethod<TestClass, String> {
  const _TestClasswhatIDoGetter();
  @override
  String get name => 'whatIDo';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.whatIDo;
}

class _TestClasstypeGetter extends GeneratedReflectedMethod<TestClass, TestClassType> {
  const _TestClasstypeGetter();
  @override
  String get name => 'type';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  TestClassType callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.type;
}

class _TestClassnameGetter extends GeneratedReflectedMethod<TestClass, String> {
  const _TestClassnameGetter();
  @override
  String get name => 'name';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.name;
}

class _TestClassgetterMethod extends GeneratedReflectedMethod<TestClass, dynamic> {
  const _TestClassgetterMethod();
  @override
  String get name => 'getter';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.getter();
}

class _TestClassgetterStaticMethod extends GeneratedReflectedMethod<TestClass, dynamic> {
  const _TestClassgetterStaticMethod();
  @override
  String get name => 'getterStatic';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => TestClass.getterStatic();
}

class _TestClassnameSetter extends GeneratedReflectedMethod<TestClass, dynamic> {
  const _TestClassnameSetter();
  @override
  String get name => 'name';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.setMethod;

  @override
  List get annotations => const [];

  static const _fix0 = GeneratedReflectedFixedParameter<dynamic>(
    annotations: const [],
    name: 'newValue',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  dynamic callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.name = _fix0.getValueFromList(fixedValues);
}

class _TestClasstoStringMethod extends GeneratedReflectedMethod<TestClass, String> {
  const _TestClasstoStringMethod();
  @override
  String get name => 'toString';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override, EssentialKey()];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.toString();
}

class _TestClassBuilder extends GeneratedReflectedMethod<TestClass, TestClass> {
  const _TestClassBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  TestClass callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => TestClass();
}

class _TestClasssuperHumanFactorie extends GeneratedReflectedMethod<TestClass, TestClass> {
  const _TestClasssuperHumanFactorie();
  @override
  String get name => 'superHuman';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.factoryMethod;

  @override
  List get annotations => const [];

  static const _namname = GeneratedReflectedNamedParameter<String>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'name',
  );
  static const _namdate = GeneratedReflectedNamedParameter<DateTime>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'date',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namname, _namdate];

  @override
  TestClass callReservedMethod({required TestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => TestClass.superHuman(
        name: _namname.getValueFromMap(namedValues),
        date: _namdate.getValueFromMap(namedValues),
      );
}

/*TESTCLASS INSTANCE*/

class _TestClass extends GeneratedReflectedClass<TestClass> {
  const _TestClass();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'TestClass';

  @override
  List<GeneratedReflectedMethod> get methods => const [
        _TestClasswhatIDoGetter(),
        _TestClasstypeGetter(),
        _TestClassnameGetter(),
        _TestClassgetterMethod(),
        _TestClassgetterStaticMethod(),
        _TestClassnameSetter(),
        _TestClasstoStringMethod(),
        _TestClassBuilder(),
        _TestClasssuperHumanFactorie()
      ];

  @override
  List<GeneratedReflectedField> get fields => const [_TestClassidentifier(), _TestClassanyDatetime()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class ThirdTestClass   ----------------------------------*/

/*THIRDTESTCLASS FIELDS*/

class _ThirdTestClassidentifier extends GeneratedReflectedField<ThirdTestClass, int> with GeneratedReflectedModifiableField<ThirdTestClass, int> {
  const _ThirdTestClassidentifier();
  @override
  List get annotations => const [PrimaryKey(), CheckNumberRange(maximum: 999)];

  @override
  String get name => 'identifier';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 0;

  @override
  int getReservedValue({required ThirdTestClass? entity}) => entity!.identifier;
  @override
  void setReservedValue({required ThirdTestClass? entity, required int newValue}) => entity!.identifier = newValue;
}

class _ThirdTestClassname extends GeneratedReflectedField<ThirdTestClass, String> with GeneratedReflectedModifiableField<ThirdTestClass, String> {
  const _ThirdTestClassname();
  @override
  List get annotations => const [EssentialKey(), CheckTextLength(minimum: 3, maximum: 120)];

  @override
  String get name => 'name';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  String? get defaulValue => '';

  @override
  String getReservedValue({required ThirdTestClass? entity}) => entity!.name;
  @override
  void setReservedValue({required ThirdTestClass? entity, required String newValue}) => entity!.name = newValue;
}

class _ThirdTestClassisAdmin extends GeneratedReflectedField<ThirdTestClass, bool> with GeneratedReflectedModifiableField<ThirdTestClass, bool> {
  const _ThirdTestClassisAdmin();
  @override
  List get annotations => const [];

  @override
  String get name => 'isAdmin';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  bool? get defaulValue => false;

  @override
  bool getReservedValue({required ThirdTestClass? entity}) => entity!.isAdmin;
  @override
  void setReservedValue({required ThirdTestClass? entity, required bool newValue}) => entity!.isAdmin = newValue;
}

class _ThirdTestClassage extends GeneratedReflectedField<ThirdTestClass, int> with GeneratedReflectedModifiableField<ThirdTestClass, int> {
  const _ThirdTestClassage();
  @override
  List get annotations => const [CheckNumberRange(minimum: 18, maximum: 120), EssentialKey()];

  @override
  String get name => 'age';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => false;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => true;
  @override
  int? get defaulValue => 0;

  @override
  int getReservedValue({required ThirdTestClass? entity}) => entity!.age;
  @override
  void setReservedValue({required ThirdTestClass? entity, required int newValue}) => entity!.age = newValue;
}

/*THIRDTESTCLASS METHODS*/

class _ThirdTestClassBuilder extends GeneratedReflectedMethod<ThirdTestClass, ThirdTestClass> {
  const _ThirdTestClassBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  ThirdTestClass callReservedMethod({required ThirdTestClass? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => ThirdTestClass();
}

/*THIRDTESTCLASS INSTANCE*/

class _ThirdTestClass extends GeneratedReflectedClass<ThirdTestClass> {
  const _ThirdTestClass();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'ThirdTestClass';

  @override
  List<GeneratedReflectedMethod> get methods => const [_ThirdTestClassBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [_ThirdTestClassidentifier(), _ThirdTestClassname(), _ThirdTestClassisAdmin(), _ThirdTestClassage()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class RemoteFunctionality   ----------------------------------*/

/*REMOTEFUNCTIONALITY FIELDS*/

class _RemoteFunctionalityname extends GeneratedReflectedField<RemoteFunctionality, String> {
  const _RemoteFunctionalityname();
  @override
  List get annotations => const [];

  @override
  String get name => 'name';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => true;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  String? get defaulValue => null;

  @override
  String getReservedValue({required RemoteFunctionality? entity}) => entity!.name;
}

class _RemoteFunctionalitytimeout extends GeneratedReflectedField<RemoteFunctionality, int> {
  const _RemoteFunctionalitytimeout();
  @override
  List get annotations => const [];

  @override
  String get name => 'timeout';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => true;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  int? get defaulValue => null;

  @override
  int getReservedValue({required RemoteFunctionality? entity}) => entity!.timeout;
}

/*REMOTEFUNCTIONALITY METHODS*/

class _RemoteFunctionalityrunFunctionalityMethod extends GeneratedReflectedMethod<RemoteFunctionality, Future<String>> {
  const _RemoteFunctionalityrunFunctionalityMethod();
  @override
  String get name => 'runFunctionality';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<String> callReservedMethod({required RemoteFunctionality? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.runFunctionality();
}

class _RemoteFunctionalityBuilder extends GeneratedReflectedMethod<RemoteFunctionality, RemoteFunctionality> {
  const _RemoteFunctionalityBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  static const _namname = GeneratedReflectedNamedParameter<dynamic>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'name',
  );
  static const _namtimeout = GeneratedReflectedNamedParameter<dynamic>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'timeout',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namname, _namtimeout];

  @override
  RemoteFunctionality callReservedMethod({required RemoteFunctionality? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => RemoteFunctionality(
        name: _namname.getValueFromMap(namedValues),
        timeout: _namtimeout.getValueFromMap(namedValues),
      );
}

/*REMOTEFUNCTIONALITY INSTANCE*/

class _RemoteFunctionality extends GeneratedReflectedClass<RemoteFunctionality> {
  const _RemoteFunctionality();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [IFunctionality];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'RemoteFunctionality';

  @override
  List<GeneratedReflectedMethod> get methods => const [_RemoteFunctionalityrunFunctionalityMethod(), _RemoteFunctionalityBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [_RemoteFunctionalityname(), _RemoteFunctionalitytimeout()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class RemoteFunctionalityStream   ----------------------------------*/

/*REMOTEFUNCTIONALITYSTREAM FIELDS*/

class _RemoteFunctionalityStreamname extends GeneratedReflectedField<RemoteFunctionalityStream, String> {
  const _RemoteFunctionalityStreamname();
  @override
  List get annotations => const [];

  @override
  String get name => 'name';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => true;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  String? get defaulValue => null;

  @override
  String getReservedValue({required RemoteFunctionalityStream? entity}) => entity!.name;
}

class _RemoteFunctionalityStreamtimeout extends GeneratedReflectedField<RemoteFunctionalityStream, int> {
  const _RemoteFunctionalityStreamtimeout();
  @override
  List get annotations => const [];

  @override
  String get name => 'timeout';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => true;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  int? get defaulValue => null;

  @override
  int getReservedValue({required RemoteFunctionalityStream? entity}) => entity!.timeout;
}

class _RemoteFunctionalityStreamlaunchException extends GeneratedReflectedField<RemoteFunctionalityStream, bool> {
  const _RemoteFunctionalityStreamlaunchException();
  @override
  List get annotations => const [];

  @override
  String get name => 'launchException';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => true;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  bool? get defaulValue => null;

  @override
  bool getReservedValue({required RemoteFunctionalityStream? entity}) => entity!.launchException;
}

/*REMOTEFUNCTIONALITYSTREAM METHODS*/

class _RemoteFunctionalityStreamrunFunctionalityMethod extends GeneratedReflectedMethod<RemoteFunctionalityStream, Future<String>> {
  const _RemoteFunctionalityStreamrunFunctionalityMethod();
  @override
  String get name => 'runFunctionality';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _nammanager = GeneratedReflectedNamedParameter<TextableFunctionalityExecutor<String>>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'manager',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_nammanager];

  @override
  Future<String> callReservedMethod({required RemoteFunctionalityStream? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.runFunctionality(
        manager: _nammanager.getValueFromMap(namedValues),
      );
}

class _RemoteFunctionalityStreamonCancelMethod extends GeneratedReflectedMethod<RemoteFunctionalityStream, dynamic> {
  const _RemoteFunctionalityStreamonCancelMethod();
  @override
  String get name => 'onCancel';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  static const _nammanager = GeneratedReflectedNamedParameter<InteractiveFunctionalityExecutor<Oration, String>>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'manager',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_nammanager];

  @override
  dynamic callReservedMethod({required RemoteFunctionalityStream? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.onCancel(
        manager: _nammanager.getValueFromMap(namedValues),
      );
}

class _RemoteFunctionalityStreamBuilder extends GeneratedReflectedMethod<RemoteFunctionalityStream, RemoteFunctionalityStream> {
  const _RemoteFunctionalityStreamBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  static const _namname = GeneratedReflectedNamedParameter<dynamic>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'name',
  );
  static const _namtimeout = GeneratedReflectedNamedParameter<dynamic>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'timeout',
  );
  static const _namlaunchException = GeneratedReflectedNamedParameter<dynamic>(
    annotations: const [],
    defaultValue: false,
    hasDefaultValue: true,
    acceptNulls: false,
    name: 'launchException',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namname, _namtimeout, _namlaunchException];

  @override
  RemoteFunctionalityStream callReservedMethod({required RemoteFunctionalityStream? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => RemoteFunctionalityStream(
        name: _namname.getValueFromMap(namedValues),
        timeout: _namtimeout.getValueFromMap(namedValues),
        launchException: _namlaunchException.getValueFromMap(namedValues),
      );
}

/*REMOTEFUNCTIONALITYSTREAM INSTANCE*/

class _RemoteFunctionalityStream extends GeneratedReflectedClass<RemoteFunctionalityStream> {
  const _RemoteFunctionalityStream();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [TextableFunctionality];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'RemoteFunctionalityStream';

  @override
  List<GeneratedReflectedMethod> get methods => const [_RemoteFunctionalityStreamrunFunctionalityMethod(), _RemoteFunctionalityStreamonCancelMethod(), _RemoteFunctionalityStreamBuilder()];

  @override
  List<GeneratedReflectedField> get fields => const [_RemoteFunctionalityStreamname(), _RemoteFunctionalityStreamtimeout(), _RemoteFunctionalityStreamlaunchException()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class FirstService   ----------------------------------*/

/*FIRSTSERVICE FIELDS*/

class _FirstServiceisMustFail extends GeneratedReflectedField<FirstService, bool> {
  const _FirstServiceisMustFail();
  @override
  List get annotations => const [];

  @override
  String get name => 'isMustFail';

  @override
  bool get isStatic => false;

  @override
  bool get isConst => false;

  @override
  bool get isLate => false;

  @override
  bool get isFinal => true;

  @override
  bool get acceptNull => false;

  @override
  bool get hasDefaultValue => false;
  @override
  bool? get defaulValue => null;

  @override
  bool getReservedValue({required FirstService? entity}) => entity!.isMustFail;
}

/*FIRSTSERVICE METHODS*/

class _FirstServiceserviceNameGetter extends GeneratedReflectedMethod<FirstService, String> {
  const _FirstServiceserviceNameGetter();
  @override
  String get name => 'serviceName';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.serviceName;
}

class _FirstServiceinitializeFunctionalityMethod extends GeneratedReflectedMethod<FirstService, Future<void>> {
  const _FirstServiceinitializeFunctionalityMethod();
  @override
  String get name => 'initializeFunctionality';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<void> callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.initializeFunctionality();
}

class _FirstServicepassSomeTextMethod extends GeneratedReflectedMethod<FirstService, Future<String>> {
  const _FirstServicepassSomeTextMethod();
  @override
  String get name => 'passSomeText';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<String> callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.passSomeText();
}

class _FirstServicepassSomeNumberMethod extends GeneratedReflectedMethod<FirstService, Future<int>> {
  const _FirstServicepassSomeNumberMethod();
  @override
  String get name => 'passSomeNumber';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<int> callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.passSomeNumber();
}

class _FirstServicegenerateSomeTextMethod extends GeneratedReflectedMethod<FirstService, Stream<String>> {
  const _FirstServicegenerateSomeTextMethod();
  @override
  String get name => 'generateSomeText';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  static const _namamount = GeneratedReflectedNamedParameter<int>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'amount',
  );
  static const _namwaitingSeconds = GeneratedReflectedNamedParameter<int>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'waitingSeconds',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namamount, _namwaitingSeconds];

  @override
  Stream<String> callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.generateSomeText(
        amount: _namamount.getValueFromMap(namedValues),
        waitingSeconds: _namwaitingSeconds.getValueFromMap(namedValues),
      );
}

class _FirstServicecreatePipeInSecondServiceMethod extends GeneratedReflectedMethod<FirstService, Future<void>> {
  const _FirstServicecreatePipeInSecondServiceMethod();
  @override
  String get name => 'createPipeInSecondService';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<void> callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.createPipeInSecondService();
}

class _FirstServicecallBackgroudFunctionalityMethod extends GeneratedReflectedMethod<FirstService, Future<String>> {
  const _FirstServicecallBackgroudFunctionalityMethod();
  @override
  String get name => 'callBackgroudFunctionality';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<String> callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.callBackgroudFunctionality();
}

class _FirstServiceBuilder extends GeneratedReflectedMethod<FirstService, FirstService> {
  const _FirstServiceBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  static const _namisMustFail = GeneratedReflectedNamedParameter<dynamic>(
    annotations: const [],
    defaultValue: null,
    hasDefaultValue: false,
    acceptNulls: false,
    name: 'isMustFail',
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [_namisMustFail];

  @override
  FirstService callReservedMethod({required FirstService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => FirstService(
        isMustFail: _namisMustFail.getValueFromMap(namedValues),
      );
}

/*FIRSTSERVICE INSTANCE*/

class _FirstService extends GeneratedReflectedClass<FirstService> {
  const _FirstService();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [StartableFunctionality, IThreadService];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'FirstService';

  @override
  List<GeneratedReflectedMethod> get methods => const [
        _FirstServiceserviceNameGetter(),
        _FirstServiceinitializeFunctionalityMethod(),
        _FirstServicepassSomeTextMethod(),
        _FirstServicepassSomeNumberMethod(),
        _FirstServicegenerateSomeTextMethod(),
        _FirstServicecreatePipeInSecondServiceMethod(),
        _FirstServicecallBackgroudFunctionalityMethod(),
        _FirstServiceBuilder()
      ];

  @override
  List<GeneratedReflectedField> get fields => const [_FirstServiceisMustFail()];
}
/*----------------------------------   x   ----------------------------------*/

/*----------------------------------   Class SecondService   ----------------------------------*/

/*SECONDSERVICE FIELDS*/

/*SECONDSERVICE METHODS*/

class _SecondServiceinitializeFunctionalityMethod extends GeneratedReflectedMethod<SecondService, Future<void>> {
  const _SecondServiceinitializeFunctionalityMethod();
  @override
  String get name => 'initializeFunctionality';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<void> callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.initializeFunctionality();
}

class _SecondServiceserviceNameGetter extends GeneratedReflectedMethod<SecondService, String> {
  const _SecondServiceserviceNameGetter();
  @override
  String get name => 'serviceName';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.getMehtod;

  @override
  List get annotations => const [override];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  String callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.serviceName;
}

class _SecondServicecallFromFirstServiceMethod extends GeneratedReflectedMethod<SecondService, Future<void>> {
  const _SecondServicecallFromFirstServiceMethod();
  @override
  String get name => 'callFromFirstService';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<void> callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.callFromFirstService();
}

class _SecondServicecallStreamFromFirstServiceMethod extends GeneratedReflectedMethod<SecondService, Stream<String>> {
  const _SecondServicecallStreamFromFirstServiceMethod();
  @override
  String get name => 'callStreamFromFirstService';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Stream<String> callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.callStreamFromFirstService();
}

class _SecondServicemountFirstServiceMethod extends GeneratedReflectedMethod<SecondService, Future<void>> {
  const _SecondServicemountFirstServiceMethod();
  @override
  String get name => 'mountFirstService';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<void> callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.mountFirstService();
}

class _SecondServiceusePipeMethod extends GeneratedReflectedMethod<SecondService, Future<void>> {
  const _SecondServiceusePipeMethod();
  @override
  String get name => 'usePipe';

  @override
  bool get isStatic => false;

  @override
  MethodDetectedType get methodType => MethodDetectedType.commonMethod;

  @override
  List get annotations => const [];

  static const _fix0 = GeneratedReflectedFixedParameter<IChannel<int, String>>(
    annotations: const [],
    name: 'pipe',
    position: 0,
    hasDefaultValue: false,
    defaultValue: null,
    acceptNulls: false,
  );
  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [_fix0];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  Future<void> callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => entity!.usePipe(
        _fix0.getValueFromList(fixedValues),
      );
}

class _SecondServiceBuilder extends GeneratedReflectedMethod<SecondService, SecondService> {
  const _SecondServiceBuilder();
  @override
  String get name => '';

  @override
  bool get isStatic => true;

  @override
  MethodDetectedType get methodType => MethodDetectedType.buildMethod;

  @override
  List get annotations => const [];

  @override
  List<GeneratedReflectedFixedParameter> get fixedParameters => const [];

  @override
  List<GeneratedReflectedNamedParameter> get namedParameters => const [];

  @override
  SecondService callReservedMethod({required SecondService? entity, required List fixedValues, required Map<String, dynamic> namedValues}) => SecondService();
}

/*SECONDSERVICE INSTANCE*/

class _SecondService extends GeneratedReflectedClass<SecondService> {
  const _SecondService();
  @override
  List get annotations => const [reflect];

  @override
  Type? get baseClass => null;

  @override
  List<Type> get classThatImplement => const [StartableFunctionality, IThreadService];

  @override
  bool get isAbstract => false;

  @override
  bool get isMixin => false;

  @override
  String get name => 'SecondService';

  @override
  List<GeneratedReflectedMethod> get methods => const [
        _SecondServiceinitializeFunctionalityMethod(),
        _SecondServiceserviceNameGetter(),
        _SecondServicecallFromFirstServiceMethod(),
        _SecondServicecallStreamFromFirstServiceMethod(),
        _SecondServicemountFirstServiceMethod(),
        _SecondServiceusePipeMethod(),
        _SecondServiceBuilder()
      ];

  @override
  List<GeneratedReflectedField> get fields => const [];
}
/*----------------------------------   x   ----------------------------------*/

class _AlbumTest extends GeneratedReflectorAlbum {
  const _AlbumTest();
  @override
  List<GeneratedReflectedClass> get classes => const [
        _Mammal(),
        _Mutant(),
        _Persons(),
        _Pets(),
        _Thing(),
        _TestClassMakeIntList(),
        _TestClassMakeRandomText(),
        _SecondTestClassGenerator(),
        _SecondTestClass(),
        _TestClass(),
        _ThirdTestClass(),
        _RemoteFunctionality(),
        _RemoteFunctionalityStream(),
        _FirstService(),
        _SecondService()
      ];

  @override
  List<TypeEnumeratorReflector> get enums => const [_TypeAnimalEnum(), _TestClassTypeEnum()];
}

const testReflectors = _AlbumTest();
