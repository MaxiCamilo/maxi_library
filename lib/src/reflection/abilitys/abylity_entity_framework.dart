import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ientity_framework.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';

import 'package:meta/meta.dart';

mixin AbylityEntityFramework on ITypeClassReflection, IEntityFramework {
  late final IGetterReflector? _primaryKey;
  late final CustomInterpretation? _customInterpretation;

  dynamic interpretAsMap({
    required Map<String, dynamic> mapValues,
    required bool tryToCorrectNames,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
    bool verify = true,
  });

  @override
  bool get hasPrimaryKey {
    initialized();
    return _primaryKey != null;
  }

  void initialized();

  @override
  IGetterReflector get primaryKey {
    initialized();
    if (!hasPrimaryKey) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'The entity %1 does not have a primary key', textParts: [name]),
      );
    }
    return _primaryKey!;
  }

  @override
  int getPrimaryKey({required instance}) {
    initialized();
    final result = primaryKey.getValue(instance: instance);

    if (result is int) {
      return result;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'Entity %1 was expected to return a number for its primary key %2, but returned a value of type %3 instead', textParts: [name, primaryKey.name, result.runtimeType]),
      );
    }
  }

  @override
  void changePrimaryKey({required instance, required int newId}) {
    initialized();
    final primaryKey = this.primaryKey;
    if (primaryKey is ISetterReflector) {
      (primaryKey as ISetterReflector).setValue(instance: instance, newValue: newId);
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'The primary key %1 of the entity %2 cannot be modified', textParts: [primaryKey.name, name]),
      );
    }
  }

  @protected
  void initializeEntityFramework() {
    _customInterpretation = annotations.selectByType<CustomInterpretation>();

    _searchPrimaryKey();
  }

  void _searchPrimaryKey() {
    final primaryList = fields.where((x) => x.annotations.any((y) => y is PrimaryKey)).cast<IGetterReflector>().toList();
    primaryList.addAll(getters.where((x) => x.annotations.any((y) => y is PrimaryKey)).toList());

    if (primaryList.length > 1) {
      final onlyFileds = primaryList.whereType<IFieldReflection>();

      if (onlyFileds.length == 1) {
        _primaryKey = onlyFileds.first;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: Oration(message: 'The entity %1 has more than one primary key, but only one is allowed', textParts: [name]),
        );
      }
    } else if (primaryList.isNotEmpty) {
      _primaryKey = primaryList.first;
    } else {
      _primaryKey = null;
    }
  }

  @override
  dynamic interpret({
    required dynamic value,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  }) {
    initialized();
    if (enableCustomInterpretation && _customInterpretation != null) {
      return _customInterpretation.performInterpretation(value: value, declaration: this);
    }

    if (value is Map<String, dynamic>) {
      return interpretAsMap(
        mapValues: value,
        tryToCorrectNames: tryToCorrectNames,
        acceptZeroIdentifier: acceptZeroIdentifier,
        primaryKeyMustBePresent: primaryKeyMustBePresent,
        essentialKeysMustBePresent: essentialKeysMustBePresent,
      );
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'For the interpretation of entity %1, a named map is needed', textParts: [formalName]),
      );
    }
  }
}
