import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

abstract class ReflectedMethodTemplate with IDeclarationReflector, IMethodReflection {
  @override
  final List annotations;

  @override
  final List<FixedParameter> fixedParametes;

  @override
  final bool isStatic;

  @override
  final String name;

  @override
  late final String formalName;

  @override
  final List<NamedParameter> namedParametes;

  @override
  final IReflectionType reflectedType;

  @override
  late final List<ValueValidator> validators;

  bool get isGetter;
  bool get isSetter;

  late final bool isCallWithoutParameters;

  late final List<FixedParameter> fixedParametesRequired;
  late final List<FixedParameter> fixedParametesOptionals;

  late final List<NamedParameter> namedParametesRequired;
  late final List<NamedParameter> namedParametesOptionals;

  ReflectedMethodTemplate({required this.annotations, required this.fixedParametes, required this.isStatic, required this.name, required this.namedParametes, required this.reflectedType}) {
    validators = annotations.whereType<ValueValidator>().toList();
    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);

    fixedParametesRequired = fixedParametes.where((x) => !x.isOptional).toList();
    fixedParametesOptionals = fixedParametes.where((x) => x.isOptional).toList();

    namedParametesRequired = namedParametes.where((x) => !x.isRequierd).toList();
    namedParametesOptionals = namedParametes.where((x) => x.isRequierd).toList();

    isCallWithoutParameters = fixedParametes.isEmpty && namedParametes.isEmpty;
  }

  @protected
  dynamic callMethodImplementationWithoutParameters({required instance});
  @protected
  dynamic callMethodImplementation({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues});

  @override
  callMethod({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues, bool tryAccommodateParameters = true}) {
    if (instance == null && !isStatic) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The method %1 is not static, it requires an instance', [formalName]),
      );
    }

    if (isCallWithoutParameters) {
      return callMethodImplementationWithoutParameters(instance: instance);
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
        message: tr('The method %1 requires a minimum of %2 fixed values, and %3 values were entered', [formalName, fixedParametesRequired.length, fixedParametersValues.length]),
      );
    }

    //if (fixedParametersValues.length > fixedParametesRequired.length + fixedParametesOptionals.length) {

    /*
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The Method %1 has a total of %2 fixed values, but %3 values were entered', [formalName, fixedParametesRequired.length + fixedParametesOptionals.length, fixedParametersValues.length]),
      );
      */
    // }

    if (fixedParametersValues.length < (fixedParametesRequired.length + fixedParametesOptionals.length)) {
      final maxValue = fixedParametesRequired.length + fixedParametesOptionals.length;
      while (fixedParametersValues.length < maxValue) {
        final parameter = fixedParametesOptionals[fixedParametersValues.length - fixedParametesRequired.length];
        fixedParametersValues.add(parameter.optionalValue);
      }
    }

    fixedParametersValues = fixedParametersValues.toList();
    namedParametesValues = Map.from(namedParametesValues);

    while (fixedParametersValues.length > fixedParametesRequired.length + fixedParametesOptionals.length) {
      fixedParametersValues.removeLast();
    }

    for (final parameter in namedParametes) {
      if (!namedParametesValues.containsKey(parameter.name)) {
        if (parameter.isRequierd) {
          throw NegativeResult(
            identifier: NegativeResultCodes.invalidFunctionality,
            message: tr('The named parameter %1 of method %2 requires a value', [parameter.formalName, formalName]),
          );
        } else {
          namedParametesValues[parameter.name] = parameter.optinalValue;
        }
      }
    }

    _sanitizeParameters(fixedParametersValues, namedParametesValues);

    return callMethodImplementation(fixedParametersValues: fixedParametersValues, instance: instance, namedParametesValues: namedParametesValues);
  }

  dynamic _callMethodDirectly({required instance, required List fixedParametersValues, required Map<String, dynamic> namedParametesValues}) {
    if (fixedParametersValues.length < fixedParametesRequired.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The method %1 requires a minimum of %2 fixed values, and %3 values were entered', [formalName, fixedParametesRequired.length, fixedParametersValues.length]),
      );
    }

    if (fixedParametersValues.length > fixedParametesRequired.length + fixedParametesOptionals.length) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: tr('The Method %1 has a total of %2 fixed values, but %3 values were entered', [formalName, fixedParametesRequired.length + fixedParametesOptionals.length, fixedParametersValues.length]),
      );
    }

    for (final parameter in namedParametes) {
      if (!namedParametesValues.containsKey(parameter.name)) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidFunctionality,
          message: tr('The named parameter %1 of method %2 requires a value', [parameter.formalName, formalName]),
        );
      }
    }

    return callMethodImplementation(fixedParametersValues: fixedParametersValues, instance: instance, namedParametesValues: namedParametesValues);
  }

  void _sanitizeParameters(List fixedParametersValues, Map<String, dynamic> namedParametesValues) {
    for (int i = 0; i < fixedParametersValues.length; i++) {
      final parameter = fixedParametes[i];
      final value = fixedParametersValues[i];

      if (!parameter.reflectedType.isCompatible(value)) {
        fixedParametersValues[i] = addToErrorDescription(
          additionalDetails: tr('Fixed parameter  N° %1 "%2" ', [i + 1, formalName]),
          function: () => parameter.reflectedType.convertObject(value),
        );
      }
    }

    for (final part in namedParametesValues.entries.toList()) {
      final nameParameter = part.key;
      final value = part.value;

      final parameter = namedParametes.selectItem((x) => x.name == nameParameter);
      if (parameter == null) {
        namedParametesValues.remove(nameParameter);
        continue;
      }

      if (parameter.reflectedType is! TypeUnknownReflection && !parameter.reflectedType.isCompatible(value)) {
        namedParametesValues[nameParameter] = addToErrorDescription(
          additionalDetails: tr('Named parameter "%1": ', [formalName]),
          function: () => parameter.reflectedType.convertObject(value),
        );
      }
    }
  }
}
