import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/method_parameter_detected.dart';
import 'package:maxi_library/src/reflection/build/utils/build_reflector_utilities.dart';

class GeneratedReflectedNamedParameter<T> {
  final List annotations;
  final String name;
  final bool hasDefaultValue;
  final T? defaultValue;
  final bool acceptNulls;

  Type get type => T;

  const GeneratedReflectedNamedParameter({
    required this.annotations,
    required this.name,
    required this.hasDefaultValue,
    required this.defaultValue,
    required this.acceptNulls,
  });

  NamedParameter generateForReflectedInstance() {
    return NamedParameter(
      annotations: annotations,
      name: name,
      isRequierd: !hasDefaultValue,
      optinalValue: defaultValue,
      type: T,
    );
  }

  static String makeFieldScript({required MethodParameterDetected parameter}) {
    return 'static const _nam${parameter.name} = ${makeScript(parameter: parameter)};';
  }

  static String makeScript({required MethodParameterDetected parameter}) {
    assert(parameter.isNamed);

    return '''
GeneratedReflectedNamedParameter<${parameter.typeValue}>(
      annotations: ${BuildReflectorUtilities.makeAnnotationsScript(anotations: parameter.annotations)},
      defaultValue: ${parameter.hasDefaultValue ? parameter.defaultValue : 'null'},
      hasDefaultValue: ${parameter.hasDefaultValue ? 'true' : 'false'},
      acceptNulls: ${parameter.acceptNulls ? 'true' : 'false'},
      name: '${parameter.name}',
)
''';
  }

  T getValueFromMap(Map<String, dynamic> map) {
    final value = map[name];
    if (value == null) {
      if (hasDefaultValue) {
        assert(defaultValue != null);
        return defaultValue!;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.nonExistent,
          message: tr('The parameter named %1 needs a value', [name]),
        );
      }
    } else if (value is T) {
      return value;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr(
          'The parameter named %1 is expected to be of type %2, but the value provided (%3) is not compatible',
          [name, T, value.runtimeType],
        ),
      );
    }
  }
/*
  static GeneratedReflectedNamedParameter<String> test() {
    GeneratedReflectedNamedParameter<String>(
      annotations: [],
      defaultValue: 'jeje',
      hasDefaultValue: true,
      name: 'prueba',
    );
  }
  */
}
