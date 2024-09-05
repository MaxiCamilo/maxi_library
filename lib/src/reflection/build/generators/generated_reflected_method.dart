import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/method_detected.dart';
import 'package:maxi_library/src/reflection/build/generators/generated_reflected_fixed_parameter.dart';
import 'package:maxi_library/src/reflection/build/generators/generated_reflected_named_parameter.dart';
import 'package:maxi_library/src/reflection/build/utils/build_reflector_utilities.dart';
import 'package:meta/meta.dart';

abstract class GeneratedReflectedMethod<T, R> {
  List get annotations;
  String get name;
  List<GeneratedReflectedFixedParameter> get fixedParameters;
  List<GeneratedReflectedNamedParameter> get namedParameters;
  bool get isStatic;
  MethodDetectedType get methodType;

  const GeneratedReflectedMethod();

  Type get typeReturn => R;

  R callMethod({required entity, required List fixedValues, required Map<String, dynamic> namedValues}) {
    if (!isStatic && entity == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: trc('The method %1 of the entity %2 is not static, instance is required', [name, T]),
      );
    }

    if (!isStatic && entity is! T) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: trc('The %1 method of the %2 object requires a %2 instance or a compatible one', [name, T]),
      );
    }

    return callReservedMethod(entity: entity, fixedValues: fixedValues, namedValues: namedValues);
  }

  @protected
  R callReservedMethod({required T? entity, required List fixedValues, required Map<String, dynamic> namedValues});

  static (String, String) makeScript({required String entityName, required MethodDetected method}) {
    final buffer = StringBuffer();
    final typeReturn = method.typeReturn == 'void' ? 'dynamic' : method.typeReturn;
    final className = _generateName(entityName, method);

    //header
    buffer.write('class $className extends GeneratedReflectedMethod<$entityName, $typeReturn> {\n');
    //const construct
    buffer.write('const $className();\n');

    //Name and if it's static
    buffer.write('''
@override
String get name => '${method.name}';

@override
bool get isStatic => ${method.isStatic ? 'true' : 'false'};

@override
MethodDetectedType get methodType => MethodDetectedType.${method.type.name};\n
''');

    //Anotations
    buffer.write('''
@override
List get annotations => ${BuildReflectorUtilities.makeAnnotationsScript(anotations: method.annotations)};\n
''');

    ///Reflector parameters
    for (final item in method.parameters.where((x) => !x.isNamed)) {
      buffer.write(GeneratedReflectedFixedParameter.makeFieldScript(parameter: item));
    }

    for (final item in method.parameters.where((x) => x.isNamed)) {
      buffer.write(GeneratedReflectedNamedParameter.makeFieldScript(parameter: item));
    }

    buffer.write('''
@override
List<GeneratedReflectedFixedParameter> get fixedParameters => const [${TextUtilities.generateCommand(list: method.parameters.where((x) => !x.isNamed).map((x) => '_fix${x.position}'))}];\n
''');

    buffer.write('''
@override
List<GeneratedReflectedNamedParameter> get namedParameters => const [${TextUtilities.generateCommand(list: method.parameters.where((x) => x.isNamed).map((x) => '_nam${x.name}'))}];\n
''');

    buffer.write('''
@override
$typeReturn callReservedMethod({required $entityName? entity, required List fixedValues, required Map<String, dynamic> namedValues}) =>
''');
/*
    if (returnsSomething) {
      buffer.write('return ');
    }
    */

    if (method.isStatic) {
      buffer.write(entityName);
    } else {
      buffer.write('entity!');
    }

    if (method.type != MethodDetectedType.buildMethod) {
      buffer.write('.${method.name}');
    }

    if (method.type == MethodDetectedType.setMethod) {
      buffer.write(' = _fix0.getValueFromList(fixedValues)');
    } else if (method.type != MethodDetectedType.getMehtod) {
      buffer.write('(');

      for (final fix in method.parameters.where((x) => !x.isNamed)) {
        buffer.write('_fix${fix.position}.getValueFromList(fixedValues),');
      }

      for (final nam in method.parameters.where((x) => x.isNamed)) {
        buffer.write('${nam.name}: _nam${nam.name}.getValueFromMap(namedValues),');
      }

      buffer.write(')');
    }

    buffer.write(';\n}\n');

    //(buffer.toString());

    return (className, buffer.toString());
  }

  static String _generateName(String entityName, MethodDetected method) {
    return switch (method.type) {
      MethodDetectedType.commonMethod => '_$entityName${method.name}Method',
      MethodDetectedType.getMehtod => '_$entityName${method.name}Getter',
      MethodDetectedType.setMethod => '_$entityName${method.name}Setter',
      MethodDetectedType.buildMethod => '_${entityName}Builder',
      MethodDetectedType.factoryMethod => '_$entityName${method.name}Factorie',
    };
  }
}
