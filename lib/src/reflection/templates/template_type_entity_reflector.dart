import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ifield_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';
import 'package:maxi_library/src/reflection/interfaces/itype_entity_reflection.dart';
import 'package:maxi_library/src/reflection/types/type_unknown_reflection.dart';

abstract class TemplateTypeEntityReflector with IReflectionType, ITypeEntityReflection {
  @override
  final List annotations;

  @override
  final Type type;

  @override
  final String name;

  bool _initialized = false;

  TemplateTypeEntityReflector({required this.annotations, required this.type, required this.name});

  late final List<IFieldReflection> modificableFields;

  void initializeReflector();

  dynamic buildEntityWithoutParameters();

  void initialized() {
    if (!_initialized) {
      addToErrorDescription(additionalDetails: () => trc('Initialized reflector of %1', [name]), function: initializeReflector);

      modificableFields = fields.where((x) => !x.isStatic && !x.onlyRead).where((x) => x.fieldType is! TypeUnknownReflection).toList();
      _initialized = true;
    }
  }

  @override
  buildEntity({String selectedBuild = '', List fixedParametersValues = const [], Map<String, dynamic> namedParametersValues = const {}, bool tryAccommodateParameters = true}) {
    initialized();

    if (isAbstract) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: 'The entity %1 is abstract, cannot create an object');
    }

    if (selectedBuild == '' && !hasDefaultConstructor) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: trc('The entity %1 does not have a default constructor', [name]));
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
  callMethod({required String name, required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues, bool tryAccommodateParameters = true}) {
    initialized();

    final method = methods.selectItem((x) => x.name == name);
    if (method == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: trc('The entity %1 does not have the method "%2"', [this.name, name]),
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
          message: trc('The field %1 of class %2 is read-only, it cannot be modified', [name, this.name]),
        );
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: trc('The entity %1 does not have the field %2', [this.name, name]),
        );
      }
    }

    volatile(
      detail: () => trc('The field %1 of class %2 did not accept the value change', [name, this.name]),
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
    final compatiblePropertys = originalItemReflector.fields.where((x) => modificableFields.any((y) => y.name == x.name && y.fieldType.isTypeCompatible(x.fieldType.type))).toList();

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
        message: trc('The entity %1 does not have the field "%2"', [this.name, name]),
      );
    }
  }

  @override
  bool isCompatible(item) {
    return isTypeCompatible(item.runtimeType);
  }

  @override
  bool isTypeCompatible(Type type) {
    initialized();
    return type == this.type || (baseClass != null && baseClass!.isTypeCompatible(type)) || inheritance.any((x) => x.isTypeCompatible(type));
  }

  @override
  serializeToMap(item, {bool onlyModificable = true, bool allowStaticFields = false}) {
    initialized();
    late final List<IFieldReflection> fields;

    if (onlyModificable || !allowStaticFields) {
      fields = modificableFields;
    } else if (allowStaticFields) {
      fields = this.fields.where((x) => x.fieldType is! TypeUnknownReflection).toList();
    } else {
      fields = this.fields.where((x) => !x.isStatic).where((x) => x.fieldType is! TypeUnknownReflection).toList();
    }

    final newMap = <String, dynamic>{};
    for (final field in fields) {
      final value = field.getValue(instance: item);
      newMap[field.name] = field.fieldType.serializeToMap(value);
    }

    return newMap;
  }
}
