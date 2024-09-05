import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/method_parameter_detected.dart';
import 'package:maxi_library/src/reflection/build/utils/build_reflector_utilities.dart';

class GeneratedReflectedFixedParameter<T> {
  final List annotations;
  final String name;
  final int position;
  final bool hasDefaultValue;
  final T? defaultValue;
  final bool acceptNulls;

  const GeneratedReflectedFixedParameter({
    required this.annotations,
    required this.name,
    required this.position,
    required this.hasDefaultValue,
    required this.defaultValue,
    required this.acceptNulls,
  });

  Type get type => T;

  FixedParameter generateForReflectedInstance() {
    return FixedParameter(
      annotations: annotations,
      isOptional: hasDefaultValue,
      name: name,
      optionalValue: defaultValue,
      position: position,
      type: T,
    );
  }

  T getValueFromList(List list) {
    if (position >= list.length ) {
      if (hasDefaultValue) {
        assert(defaultValue != null);
        return defaultValue!;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: trc('The parameter at position %1 (%2) needs a value', [position, name]),
        );
      }
    }

    final value = list[position];
    if (value == null) {
      if (hasDefaultValue) {
        assert(defaultValue != null);
        return defaultValue!;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nullValue,
          message: trc('The parameter at position %1 (%2) cannot be null', [position, name]),
        );
      }
    } else if (value is T) {
      return value;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: trc(
          'The parameter at position %1 is expected to be of type %2, but the value provided (%3) is not compatible',
          [position, T, value.runtimeType],
        ),
      );
    }
  }

  static String makeFieldScript({required MethodParameterDetected parameter}) {
    return 'static const _fix${parameter.position} = ${makeScript(parameter: parameter)};\n';
  }

  static String makeScript({required MethodParameterDetected parameter}) {
    assert(!parameter.isNamed);

    return '''
GeneratedReflectedFixedParameter<${parameter.typeValue}>(
      annotations: ${BuildReflectorUtilities.makeAnnotationsScript(anotations: parameter.annotations)},
      name: '${parameter.name}',
      position: ${parameter.position},
      hasDefaultValue: ${parameter.hasDefaultValue ? 'true' : 'false'},
      defaultValue: ${parameter.hasDefaultValue ? parameter.defaultValue : 'null'},
      acceptNulls: ${parameter.acceptNulls ? 'true' : 'false'},
    )
''';
  }
}
