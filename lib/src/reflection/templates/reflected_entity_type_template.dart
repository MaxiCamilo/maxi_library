import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/abilitys/abylity_entity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/ientity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/ifield_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

import 'package:meta/meta.dart';

abstract class ReflectedEntityTypeTemplate with IReflectionType, IDeclarationReflector, ITypeClassReflection, IEntityFramework, AbylityEntityFramework, ITypeEntityReflection {
  @override
  final List annotations;

  @override
  final Type type;

  @override
  final String name;

  @override
  late final String formalName;

  @override
  late final List<ValueValidator> validators;

  late final ClassBuilderReflection? customBuilder;
  late final CustomSerialization? custorSerialization;

  bool _initialized = false;

  ReflectedEntityTypeTemplate({required this.annotations, required this.type, required this.name}) {
    validators = annotations.whereType<ValueValidator>().toList();

    customBuilder = annotations.selectByType<ClassBuilderReflection>();
    custorSerialization = annotations.selectByType<CustomSerialization>();

    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
  }

  late final List<IFieldReflection> modificableFields;

  late final List<IGetterReflector> propertys;
  late final List<ISetterReflector> modificablePropertys;

  @override
  IReflectionType get reflectedType {
    initialized();
    return this;
  }

  @protected
  void initializeReflector();

  @protected
  dynamic buildEntityWithoutParameters();

  @override
  void initialized() {
    if (!_initialized) {
      addToErrorDescription(additionalDetails: () => trc('Initialized reflector of %1', [formalName]), function: initializeReflector);
      _initialized = true;

      modificableFields = fields.where((x) => !x.isStatic && !x.onlyRead).where((x) => x.reflectedType is! TypeUnknownReflection).toList();

      propertys = [...getters, ...fields];
      modificablePropertys = [...setters, ...fields.where((x) => !x.onlyRead)];

      initializeEntityFramework();
    }
  }

  @override
  buildEntity({
    String selectedBuild = '',
    List fixedParametersValues = const [],
    Map<String, dynamic> namedParametersValues = const {},
    bool tryAccommodateParameters = true,
    bool useCustomConstructor = true,
  }) {
    initialized();

    if (useCustomConstructor && customBuilder != null) {
      return customBuilder!.generateByMethod(fixedParametersValues: fixedParametersValues, namedParametesValues: namedParametersValues);
    }

    if (isAbstract) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: 'The entity %1 is abstract, cannot create an object');
    }

    if (selectedBuild == '' && !hasDefaultConstructor) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: trc('The entity %1 does not have a default constructor', [formalName]));
    }

    if (selectedBuild.isEmpty && fixedParametersValues.isEmpty && namedParametersValues.isEmpty) {
      return buildEntityWithoutParameters();
    }

    final constructor = constructors.selectItem((x) => x.name == selectedBuild);
    if (constructor == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('The entity %1 does not have the contructor "%2"', [selectedBuild, name]),
      );
    }

    return constructor.callMethod(
      instance: null,
      fixedParametersValues: fixedParametersValues,
      namedParametesValues: namedParametersValues,
      tryAccommodateParameters: tryAccommodateParameters,
    );
  }

  @override
  callMethod({required String name, required instance, List fixedParametersValues = const [], Map<String, dynamic> namedParametesValues = const {}, bool tryAccommodateParameters = true}) {
    initialized();

    final method = methods.selectItem((x) => x.name == name);
    if (method == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('The entity %1 does not have the method "%2"', [formalName, name]),
      );
    }

    return method.callMethod(instance: instance, fixedParametersValues: fixedParametersValues, namedParametesValues: namedParametesValues, tryAccommodateParameters: tryAccommodateParameters);
  }

  @override
  void changeFieldValue({required String name, required instance, required newValue}) {
    initialized();
    final field = modificableFields.selectItem((x) => x.name == name);
    if (field == null) {
      if (fields.any((x) => x.name == name)) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: trc('The field %1 of class %2 is read-only, it cannot be modified', [name, formalName]),
        );
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: trc('The entity %1 does not have the field %2', [formalName, name]),
        );
      }
    }

    volatile(
      detail: () => trc('The field %1 of class %2 did not accept the value change', [name, formalName]),
      function: () => field.setValue(instance: instance, newValue: newValue),
    );
  }

  @override
  cloneObject(originalItem) {
    initialized();
    if (originalItem.runtimeType != type) {
      return convertObject(originalItem);
    }

    final listValues = modificableFields.map((x) => x.getValue(instance: originalItem)).toList();
    final newItem = generateEmptryObject();

    for (int i = 0; i < modificableFields.length; i++) {
      final value = listValues[i];
      final field = modificableFields[i];

      field.setValue(instance: newItem, newValue: value);
    }

    return newItem;
  }

  @override
  convertObject(originalItem) {
    initialized();
    if (originalItem.runtimeType == type) {
      return cloneObject(originalItem);
    }

    final originalItemReflector = ReflectionManager.getReflectionEntity(type);
    final compatiblePropertys = originalItemReflector.fields.where((x) => modificableFields.any((y) => y.name == x.name && y.reflectedType.isTypeCompatible(x.reflectedType.type))).toList();

    final newItem = generateEmptryObject();
    for (final field in compatiblePropertys) {
      final value = field.getValue(instance: originalItem);
      changeFieldValue(instance: newItem, newValue: value, name: field.name);
    }
  }

  @override
  generateEmptryObject() {
    initialized();
    return buildEntity();
  }

  @override
  getFieldValue({required String name, required instance}) {
    initialized();

    final field = fields.selectItem((x) => x.name == name);
    if (field == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('The entity %1 does not have the field "%2"', [formalName, name]),
      );
    }

    return field.getValue(instance: instance);
  }

  @override
  bool isCompatible(item) {
    return isTypeCompatible(item.runtimeType);
  }

  @override
  bool isTypeCompatible(Type type) {
    initialized();
    return type == this.type || type == dynamic || (baseClass != null && baseClass!.isTypeCompatible(type)) || inheritance.any((x) => x.isTypeCompatible(type));
  }

  @override
  serializeToMap(item, {bool onlyModificable = true, bool allowStaticFields = false}) {
    initialized();

    if (custorSerialization != null) {
      return custorSerialization!.performSerialization(entity: item, declaration: this, allowStaticFields: allowStaticFields, onlyModificable: onlyModificable);
    }

    late final List<IFieldReflection> fields;

    if (onlyModificable || !allowStaticFields) {
      fields = modificableFields;
    } else if (allowStaticFields) {
      fields = this.fields.where((x) => x.reflectedType is! TypeUnknownReflection).toList();
    } else {
      fields = this.fields.where((x) => !x.isStatic).where((x) => x.reflectedType is! TypeUnknownReflection).toList();
    }

    final newMap = <String, dynamic>{};
    for (final field in fields) {
      final value = field.getValue(instance: item);
      newMap[field.name] = field.reflectedType.serializeToMap(value);
    }

    return newMap;
  }

  @override
  dynamic getProperty({
    required String name,
    required dynamic instance,
  }) {
    initialized();
    final property = propertys.selectItem((x) => x.name == name);
    if (property == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('The entity %1 does not have the property "%2"', [formalName, name]),
      );
    }

    return property.getValue(instance: instance);
  }

  @override
  void changeProperty({
    required String name,
    required dynamic instance,
    required dynamic newValue,
  }) {
    initialized();
    final property = modificablePropertys.selectItem((x) => x.name == name);
    if (property == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('The entity %1 does not have the modifiable property %2', [formalName, name]),
      );
    }

    property.setValue(instance: instance, newValue: newValue);
  }

  @override
  NegativeResult? verifyValue({required dynamic value, required dynamic parentEntity}) {
    initialized();
    final errorList = <NegativeResultValue>[];

    for (final field in modificableFields) {
      final error = field.checkValueIsCorrect(instance: value);
      if (error != null) {
        if (error is NegativeResultValue) {
          errorList.add(error);
        } else {
          errorList.add(NegativeResultValue.fromNegativeResult(name: field.formalName, nr: error));
        }
      }
    }

    if (errorList.isNotEmpty) {
      return NegativeResultEntity(
        message: trc('Entity %1 contains %2 invalid %3', [formalName, errorList.length, errorList.length == 1 ? tr('property') : tr('properties')]),
        name: name,
        invalidProperties: errorList,
      );
    }

    return super.verifyValue(value: value, parentEntity: parentEntity);
  }

  @override
  dynamic interpretAsMap(Map<String, dynamic> mapValues) {
    initialized();
    final newItem = generateEmptryObject();

    final errorList = <NegativeResultValue>[];

    for (final prop in modificableFields) {
      final value = mapValues[prop.name];
      if (value == null) {
        if (prop.isRequired) {
          errorList.add(NegativeResultValue(
            message: trc('Entity %1 needs the value of %2, but its value was not defined', [formalName, prop.formalName]),
            name: name,
          ));
        }
        continue;
      }

      try {
        prop.setValue(instance: newItem, newValue: value);
      } catch (ex) {
        errorList.add(NegativeResultValue.searchNegativity(
          error: ex,
          value: value,
          propertyName: formalName,
        ));
      }
    }

    _throwErrorIfThereErrorInList(errorList);

    for (final val in validators) {
      final error = val.performValidation(name: formalName, item: newItem, parentEntity: null);
      if (error != null) {
        throw NegativeResultEntity(
          message: trc('The entity %1 is invalid', [name]),
          name: name,
          invalidProperties: [NegativeResultValue.searchNegativity(error: error, propertyName: val.formalName)],
        );
      }
    }

    if (newItem is NeedsAdditionalVerification) {
      try {
        newItem.performAdditionalVerification();
      } catch (ex) {
        throw NegativeResultEntity(
          message: trc('The entity %1 is invalid', [name]),
          name: name,
          invalidProperties: [NegativeResultValue.searchNegativity(error: ex, propertyName: formalName)],
        );
      }
    }

    return newItem;
  }

  void _throwErrorIfThereErrorInList(List<NegativeResultValue> errorList) {
    if (errorList.isNotEmpty) {
      throw NegativeResultEntity(
        message: trc('The entity %1 contains %2 invalid %3', [name, errorList.length, errorList.length == 1 ? tr('property') : tr('properties')]),
        name: name,
        invalidProperties: errorList,
      );
    }
  }

  @override
  dynamic interpretationFromJson({
    required String rawJson,
    bool enableCustomInterpretation = true,
    bool verify = true,
  }) {
    initialized();
    final mapJson = volatile(
      detail: () => tr('The textual content was expected to be valid JSON'),
      function: () => json.decode(rawJson),
    );

    if (mapJson is! Map<String, dynamic>) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: trc('To create a %1 entity from a JSON, the JSON data must be in object format, not an array or a simple value', [formalName]),
      );
    }

    return interpret(value: mapJson, enableCustomInterpretation: enableCustomInterpretation, verify: enableCustomInterpretation);
  }

  @override
  String serializeToJson({required dynamic value}) {
    final mapValue = serializeToMap(value);
    return json.encode(mapValue);
  }

  @override
  List<T> interpretAslist<T>({
    required dynamic value,
    bool enableCustomInterpretation = true,
    bool verify = true,
  }) {
    initialized();
    checkProgrammingFailure(
      thatChecks: () => trc('The type %1 is compatible with reflector %2', [T, name]),
      result: () => isTypeCompatible(T),
    );

    final newList = <T>[];

    if (value is Iterable) {
      int i = 1;
      for (final item in value) {
        final digestedValue = volatileFactory(
          errorFactory: (x) => NegativeResultValue.fromException(ex: x, value: item, name: trc('Validate item N° %1', [i])),
          function: () => interpret(
            value: item,
            enableCustomInterpretation: enableCustomInterpretation,
            verify: verify,
          ),
        );
        i += 1;
        checkProgrammingFailure(thatChecks: () => trc('The generated value N° %1 is type %2', [i, T]), result: () => digestedValue is T);
        newList.add(digestedValue);
      }
    } else {
      newList.add(interpret(
        value: value,
        enableCustomInterpretation: enableCustomInterpretation,
        verify: verify,
      ));
    }

    return newList;
  }

  @override
  String toString() => 'Entity type $name';
}
