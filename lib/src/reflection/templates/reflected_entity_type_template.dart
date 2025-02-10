import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/abilitys/abylity_entity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/ientity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

import 'package:meta/meta.dart';

abstract class ReflectedEntityTypeTemplate with IReflectionType, IDeclarationReflector, ITypeClassReflection, IEntityFramework, AbylityEntityFramework, ITypeEntityReflection, IValueGenerator {
  @override
  final List annotations;

  @override
  final Type type;

  @override
  final String name;

  @override
  late final Oration formalName;

  @override
  late final List<ValueValidator> validators;

  late final ClassBuilderReflection? customBuilder;
  late final CustomSerialization? custorSerialization;

  @override
  late final Oration description;

  bool _initialized = false;

  ReflectedEntityTypeTemplate({required this.annotations, required this.type, required this.name}) {
    validators = annotations.whereType<ValueValidator>().toList();
    description = Description.searchDescription(annotations: annotations);

    customBuilder = annotations.selectByType<ClassBuilderReflection>();
    custorSerialization = annotations.selectByType<CustomSerialization>();

    formalName = FormalName.searchFormalName(realName: Oration(message: name), annotations: annotations);
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
      addToErrorDescription(additionalDetails: Oration(message: 'Initialized reflector of %1', textParts: [formalName]), function: initializeReflector);
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
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: Oration(message: 'The entity %1 is abstract, cannot create an object', textParts: [formalName]));
    }

    if (selectedBuild == '' && !hasDefaultConstructor) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: Oration(message: 'The entity %1 does not have a default constructor', textParts: [formalName]));
    }

    if (selectedBuild.isEmpty && fixedParametersValues.isEmpty && namedParametersValues.isEmpty) {
      return buildEntityWithoutParameters();
    }

    final constructor = constructors.selectItem((x) => x.name == selectedBuild);
    if (constructor == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'The entity %1 does not have the contructor "%2"', textParts: [selectedBuild, name]),
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
        message: Oration(message: 'The entity %1 does not have the method "%2"', textParts: [formalName, name]),
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
          message: Oration(message: 'The field %1 of class %2 is read-only, it cannot be modified', textParts: [name, formalName]),
        );
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: Oration(message: 'The entity %1 does not have the field %2', textParts: [formalName, name]),
        );
      }
    }

    volatile(
      detail: Oration(message: 'The field %1 of class %2 did not accept the value change', textParts: [name, formalName]),
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
        message: Oration(message: 'The entity %1 does not have the field "%2"', textParts: [formalName, name]),
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
        message: Oration(message: 'The entity %1 does not have the property "%2"', textParts: [formalName, name]),
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
        message: Oration(message: 'The entity %1 does not have the modifiable property %2', textParts: [formalName, name]),
      );
    }

    property.setValue(instance: instance, newValue: newValue);
  }

  @override
  NegativeResultValue? verifyValue({required dynamic value, required dynamic parentEntity}) {
    initialized();
    final errorList = <NegativeResultValue>[];

    for (final field in modificableFields) {
      final error = field.checkValueIsCorrect(instance: value);
      if (error != null) {
        if (error is NegativeResultValue) {
          errorList.add(error);
        } else {
          errorList.add(NegativeResultValue.fromNegativeResult(name: field.name, formalName: field.formalName, nr: error));
        }
      }
    }

    if (errorList.isNotEmpty) {
      return NegativeResultEntity(
        message: Oration(message: 'Entity %1 contains %2 invalid %3', textParts: [formalName, errorList.length, errorList.length == 1 ? const Oration(message: 'property') : const Oration(message: 'properties')]),
        name: name,
        formalName: formalName,
        invalidProperties: errorList,
      );
    }

    return super.verifyValue(value: value, parentEntity: parentEntity);
  }

  @override
  List<NegativeResultValue> listErrors({required dynamic value, required dynamic parentEntity}) {
    initialized();
    final errorList = <NegativeResultValue>[];

    for (final field in modificableFields) {
      final error = field.checkValueIsCorrect(instance: value);
      if (error != null) {
        if (error is NegativeResultValue) {
          errorList.add(error);
        } else {
          errorList.add(NegativeResultValue.fromNegativeResult(name: field.name, formalName: field.formalName, nr: error));
        }
      }
    }

    return [...errorList, ...super.listErrors(value: value, parentEntity: parentEntity)];
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
            name: name,
            message: Oration(message: 'Entity "%1" needs the value of "%2", but its value was not defined', textParts: [formalName, prop.formalName]),
            formalName: formalName,
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
          name: name,
          formalName: formalName,
        ));
      }
    }

    _throwErrorIfThereErrorInList(errorList);

    if (verify) {
      for (final val in validators) {
        final error = val.performValidation(name: name, formalName: formalName, item: newItem, parentEntity: null);
        if (error != null) {
          throw NegativeResultEntity(
            message: Oration(message: 'The entity %1 is invalid', textParts: [formalName]),
            name: name,
            formalName: formalName,
            invalidProperties: [NegativeResultValue.searchNegativity(error: error, formalName: val.formalName, name: name)],
          );
        }
      }
    }

    if (newItem is NeedsAdditionalVerification) {
      try {
        newItem.performAdditionalVerification();
      } catch (ex) {
        throw NegativeResultEntity(
          message: Oration(message: 'The entity %1 is invalid', textParts: [name]),
          formalName: formalName,
          name: name,
          invalidProperties: [NegativeResultValue.searchNegativity(error: ex, name: name, formalName: formalName)],
        );
      }
    }

    if (hasPrimaryKey && !acceptZeroIdentifier && getPrimaryKey(instance: newItem) <= 0) {
      throw NegativeResultEntity(
        message: Oration(message: 'The entity %1 is invalid', textParts: [formalName]),
        formalName: formalName,
        name: name,
        invalidProperties: [
          NegativeResultValue.searchNegativity(
            error: NegativeResult(identifier: NegativeResultCodes.invalidProperty, message: Oration(message: 'The primary key (%2) for entity %1 needs to be defined', textParts: [primaryKey.formalName, formalName])),
            formalName: primaryKey.formalName,
            name: name,
          )
        ],
      );
    }

    return newItem;
  }

  void _throwErrorIfThereErrorInList(List<NegativeResultValue> errorList) {
    if (errorList.isNotEmpty) {
      throw NegativeResultEntity(
        message: Oration(message: 'The entity %1 contains %2 invalid %3', textParts: [name, errorList.length, errorList.length == 1 ? Oration(message: 'property') : Oration(message: 'properties')]),
        formalName: formalName,
        invalidProperties: errorList,
        name: name,
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
      detail: Oration(message: 'The textual content was expected to be valid JSON'),
      function: () => json.decode(rawJson),
    );

    if (mapJson is! Map<String, dynamic>) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'To create a %1 entity from a JSON, the JSON data must be in object format, not an array or a simple value', textParts: [formalName]),
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
      thatChecks: Oration(message: 'The type %1 is compatible with reflector %2', textParts: [T, name]),
      result: () => isTypeCompatible(T),
    );

    final newList = <T>[];

    if (value is Iterable) {
      int i = 1;
      for (final item in value) {
        final digestedValue = volatileFactory(
          errorFactory: (x) => NegativeResultValue.fromException(ex: x, value: item, formalName: Oration(message: 'Validate item N° %1', textParts: [i]), name: name),
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
        checkProgrammingFailure(thatChecks: Oration(message: 'The generated value N° %1 is type %2', textParts: [i, T]), result: () => digestedValue is T);
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

  @override
  bool areSame({required dynamic first, required dynamic second}) {
    if (!isCompatible(first) || !isCompatible(second)) {
      return false;
    }

    for (final field in fields) {
      if (!field.areSame(first: first, second: second)) {
        return false;
      }
    }

    return true;
  }

  @override
  int generateHashCode({required dynamic item, required bool addName}) {
    final readableFields = fields.where((x) => !x.onlyRead).toList(growable: false);

    checkProgrammingFailure(thatChecks: Oration(message: 'Class %1 has at least one readable field'), result: () => readableFields.isNotEmpty);

    final values = fields.map((x) {
      final value = x.getValue(instance: item);
      if (ReflectionUtilities.isPrimitive(value.runtimeType) != null) {
        return value.hashCode;
      }

      final isEntity = ReflectionManager.tryGetReflectionEntity(value.runtimeType);
      if (isEntity != null) {
        return isEntity.generateHashCode(item: value, addName: addName);
      }

      if (value is List) {
        if (value.isEmpty) {
          return 0;
        }
        final listSubValue = <int>[];
        for (final subValue in value) {
          final isEntity = ReflectionManager.tryGetReflectionEntity(subValue);
          if (isEntity == null) {
            return subValue.hashCode;
          } else {
            return isEntity.generateHashCode(item: subValue, addName: addName);
          }
        }

        return Object.hashAll(listSubValue);
      }

      return value.hashCode;
    }).toList();

    if (addName) {
      values.add(name.hashCode);
    }

    return Object.hashAll(values);
  }
/*
  static dynamic _getValueFieldByPosition({required dynamic item, required int position, required List<IFieldReflection> readableFields}) {
    if (position >= readableFields.length) {
      return null;
    }

    return readableFields[position].getValue(instance: item);
  }
  */
}
