import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/implementatios/fixed_parameter.dart';
import 'package:maxi_library/src/reflection/implementatios/named_parameter.dart';
import 'package:maxi_library/src/reflection/interfaces/imethod_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/ireflection_type.dart';

abstract class TemplateMethodReflection with IMethodReflection {
  @override
  final List annotations;

  @override
  final List<FixedParameter> fixedParametes;

  @override
  final bool isStatic;

  @override
  final String name;

  @override
  final List<NamedParameter> namedParametes;

  @override
  final IReflectionType returnType;

  late final List<FixedParameter> fixedParametesRequired;
  late final List<FixedParameter> fixedParametesOptionals;

  late final List<NamedParameter> namedParametesRequired;
  late final List<NamedParameter> namedParametesOptionals;

  TemplateMethodReflection({required this.annotations, required this.fixedParametes, required this.isStatic, required this.name, required this.namedParametes, required this.returnType}) {
    fixedParametesRequired = fixedParametes.where((x) => !x.isOptional).toList();
    fixedParametesOptionals = fixedParametes.where((x) => x.isOptional).toList();

    namedParametesRequired = namedParametes.where((x) => !x.isRequierd).toList();
    namedParametesOptionals = namedParametes.where((x) => x.isRequierd).toList();
  }

  dynamic callMethodImplementation({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues});

  @override
  callMethod({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues, bool tryAccommodateParameters = true}) {
    if (instance == null && !isStatic) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The method %1 is not static, it requires an instance', [name]),
      );
    }

    if (tryAccommodateParameters) {
      return _callMethodFormated(instance: instance, fixedParametersValues: fixedParametersValues, namedParametesValues: namedParametesValues);
    } else {
      return _callMethodDirectly(instance: instance, fixedParametersValues: fixedParametersValues, namedParametesValues: namedParametesValues);
    }
  }

  dynamic _callMethodFormated({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues}) {
    if (fixedParametersValues.length < fixedParametesRequired.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The method %1 requires a minimum of %2 fixed values, and %3 values were entered', [name, fixedParametesRequired.length, fixedParametersValues.length]),
      );
    }

    if (fixedParametersValues.length > fixedParametesRequired.length + fixedParametesOptionals.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The Method %1 has a total of %2 fixed values, but %3 values were entered', [name, fixedParametesRequired.length + fixedParametesOptionals.length, fixedParametersValues.length]),
      );
    }

    if (fixedParametersValues.length < (fixedParametesRequired.length + fixedParametesOptionals.length)) {
      final maxValue = fixedParametesRequired.length + fixedParametesOptionals.length;
      while (fixedParametersValues.length < maxValue) {
        final parameter = fixedParametesOptionals[fixedParametersValues.length - fixedParametesRequired.length];
        fixedParametersValues.add(parameter.optionalValue);
      }
    }

    for (final parameter in namedParametes) {
      if (!namedParametesValues.containsKey(parameter.name)) {
        if (parameter.isRequierd) {
          throw NegativeResult(
            identifier: NegativeResultCodes.invalidFunctionality,
            message: trc('The named parameter %1 of method %2 requires a value', [parameter.name, name]),
          );
        } else {
          namedParametesValues[parameter.name] = parameter.optinalValue;
        }
      }
    }

    return callMethodImplementation(fixedParametersValues: fixedParametersValues, instance: instance, namedParametesValues: namedParametesValues);
  }

  dynamic _callMethodDirectly({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues}) {
    if (fixedParametersValues.length < fixedParametesRequired.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The method %1 requires a minimum of %2 fixed values, and %3 values were entered', [name, fixedParametesRequired.length, fixedParametersValues.length]),
      );
    }

    if (fixedParametersValues.length > fixedParametesRequired.length + fixedParametesOptionals.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: trc('The Method %1 has a total of %2 fixed values, but %3 values were entered', [name, fixedParametesRequired.length + fixedParametesOptionals.length, fixedParametersValues.length]),
      );
    }

    for (final parameter in namedParametes) {
      if (!namedParametesValues.containsKey(parameter.name)) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidFunctionality,
          message: trc('The named parameter %1 of method %2 requires a value', [parameter.name, name]),
        );
      }
    }

    return callMethodImplementation(fixedParametersValues: fixedParametersValues, instance: instance, namedParametesValues: namedParametesValues);
  }
}
