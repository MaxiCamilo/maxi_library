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
      addToErrorDescription(additionalDetails: tr('Initialized reflector of %1', [formalName]), function: initializeReflector);
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
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: tr('The entity %1 is abstract, cannot create an object', [formalName]));
    }

    if (selectedBuild == '' && !hasDefaultConstructor) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: tr('The entity %1 does not have a default constructor', [formalName]));
    }

    if (selectedBuild.isEmpty && fixedParametersValues.isEmpty && namedParametersValues.isEmpty) {
      return buildEntityWithoutParameters();
    }

    final constructor = constructors.selectItem((x) => x.name == selectedBuild);
    if (constructor == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: tr('The entity %1 does not have the contructor "%2"', [selectedBuild, name]),
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
        message: tr('The entity %1 does not have the method "%2"', [formalName, name]),
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
          message: tr('The field %1 of class %2 is read-only, it cannot be modified', [name, formalName]),
        );
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: tr('The entity %1 does not have the field %2', [formalName, name]),
        );
      }
    }

    volatile(
      detail: tr('The field %1 of class %2 did not accept the value change', [name, formalName]),
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
        message: tr('The entity %1 does not have the field "%2"', [formalName, name]),
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
  serializeToMap(item, {bool onlyModificable = true, bool allowStaticFields = false, bool setTypeValue = false}) {
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
      dynamic value = field.getValue(instance: item);

      if (value is ICustomSerialization) {
        newMap[field.name] = value.serialize();
      } else {
        newMap[field.name] = field.reflectedType.serializeToMap(value);
      }
    }

    if (setTypeValue) {
      newMap['\$type'] = name;
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
        message: tr('The entity %1 does not have the property "%2"', [formalName, name]),
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
        message: tr('The entity %1 does not have the modifiable property %2', [formalName, name]),
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
          errorList.add(NegativeResultValue.fromNegativeResult(name: tr(field.formalName), nr: error));
        }
      }
    }

    if (errorList.isNotEmpty) {
      return NegativeResultEntity(
        message: tr('Entity %1 contains %2 invalid %3', [formalName, errorList.length, errorList.length == 1 ? tr('property') : tr('properties')]),
        name: tr(name),
        invalidProperties: errorList,
      );
    }

    return super.verifyValue(value: value, parentEntity: parentEntity);
  }

  @override
  dynamic interpretAsMap({
    required Map<String, dynamic> mapValues,
    required bool tryToCorrectNames,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
    bool verify = true,
  }) {
    initialized();

    if (tryToCorrectNames) {
      mapValues = _tryToCorrectNames(mapValues);
    }

    final newItem = generateEmptryObject();
    final errorList = <NegativeResultValue>[];

    for (final prop in modificableFields) {
      final value = mapValues.entries.selectItem((x) => x.key == prop.name || (tryToCorrectNames && x.key == prop.nameInLowerCase))?.value;
      if (value == null) {
        if (prop.isRequired || (prop.isEssentialKey && essentialKeysMustBePresent) || (prop.isPrimaryKey && primaryKeyMustBePresent)) {
          errorList.add(NegativeResultValue(
            message: tr('Entity "%1" needs the value of "%2", but its value was not defined', [formalName, prop.formalName]),
            name: tr(name),
          ));
        }

        continue;
      }

      try {
        prop.setValue(instance: newItem, newValue: value, beforeVerifying: verify);
      } catch (ex) {
        errorList.add(NegativeResultValue.searchNegativity(
          error: ex,
          value: value,
          propertyName: tr(formalName),
        ));
      }
    }

    _throwErrorIfThereErrorInList(errorList);

    if (verify) {
      for (final val in validators) {
        final error = val.performValidation(name: formalName, item: newItem, parentEntity: null);
        if (error != null) {
          throw NegativeResultEntity(
            message: tr('The entity %1 is invalid', [name]),
            name: tr(name),
            invalidProperties: [NegativeResultValue.searchNegativity(error: error, propertyName: tr(val.formalName))],
          );
        }
      }
    }

    if (newItem is NeedsAdditionalVerification) {
      try {
        newItem.performAdditionalVerification();
      } catch (ex) {
        throw NegativeResultEntity(
          message: tr('The entity %1 is invalid', [name]),
          name: tr(name),
          invalidProperties: [NegativeResultValue.searchNegativity(error: ex, propertyName: tr(formalName))],
        );
      }
    }

    if (hasPrimaryKey && !acceptZeroIdentifier && getPrimaryKey(instance: newItem) <= 0) {
      throw NegativeResultEntity(
        message: tr('The entity %1 is invalid', [name]),
        name: tr(name),
        invalidProperties: [
          NegativeResultValue.searchNegativity(
            error: NegativeResult(identifier: NegativeResultCodes.invalidProperty, message: tr('The primary key (%2) for entity %1 needs to be defined', [primaryKey.formalName, formalName])),
            propertyName: tr(primaryKey.formalName),
          )
        ],
      );
    }

    return newItem;
  }

  void _throwErrorIfThereErrorInList(List<NegativeResultValue> errorList) {
    if (errorList.isNotEmpty) {
      throw NegativeResultEntity(
        message: tr('The entity %1 contains %2 invalid %3', [name, errorList.length, errorList.length == 1 ? tr('property') : tr('properties')]),
        name: tr(name),
        invalidProperties: errorList,
      );
    }
  }

  @override
  dynamic interpretationFromJson({
    required String rawJson,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  }) {
    initialized();
    final mapJson = volatile(
      detail: tr('The textual content was expected to be valid JSON'),
      function: () => json.decode(rawJson),
    );

    if (mapJson is! Map<String, dynamic>) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('To create a %1 entity from a JSON, the JSON data must be in object format, not an array or a simple value', [formalName]),
      );
    }

    return interpret(
      value: mapJson,
      tryToCorrectNames: tryToCorrectNames,
      enableCustomInterpretation: enableCustomInterpretation,
      verify: enableCustomInterpretation,
      acceptZeroIdentifier: acceptZeroIdentifier,
      primaryKeyMustBePresent: acceptZeroIdentifier,
      essentialKeysMustBePresent: acceptZeroIdentifier,
    );
  }

  @override
  String serializeToJson({required dynamic value, bool setTypeValue = false}) {
    final mapValue = serializeToMap(value, setTypeValue: setTypeValue);
    return json.encode(mapValue);
  }

  @override
  List<T> interpretAslist<T>({
    required dynamic value,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  }) {
    initialized();
    checkProgrammingFailure(
      thatChecks: tr('The type %1 is compatible with reflector %2', [T, name]),
      result: () => isTypeCompatible(T),
    );

    final newList = <T>[];

    if (value is Iterable) {
      int i = 1;
      for (final item in value) {
        final digestedValue = volatileFactory(
          errorFactory: (x) => NegativeResultValue.fromException(ex: x, value: item, name: tr('Validate item N° %1', [i])),
          function: () => interpret(
            value: item,
            tryToCorrectNames: tryToCorrectNames,
            enableCustomInterpretation: enableCustomInterpretation,
            verify: verify,
            acceptZeroIdentifier: acceptZeroIdentifier,
            primaryKeyMustBePresent: acceptZeroIdentifier,
            essentialKeysMustBePresent: acceptZeroIdentifier,
          ),
        );
        i += 1;
        checkProgrammingFailure(thatChecks: tr('The generated value N° %1 is type %2', [i, T]), result: () => digestedValue is T);
        newList.add(digestedValue);
      }
    } else {
      newList.add(interpret(
        value: value,
        tryToCorrectNames: tryToCorrectNames,
        enableCustomInterpretation: enableCustomInterpretation,
        verify: verify,
      ));
    }

    return newList;
  }

  @override
  String toString() => 'Entity type $name';

  Map<String, dynamic> _tryToCorrectNames(Map<String, dynamic> mapValues) {
    final newMap = <String, dynamic>{};

    for (final item in mapValues.entries) {
      final newName = TextUtilities.parseSnakeCaseToCamelCase(item.key).toLowerCase();
      newMap[newName] = item.value;
    }

    return newMap;
  }
}
