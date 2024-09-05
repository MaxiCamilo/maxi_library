import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';
import 'package:maxi_library/src/reflection/build/detected/method_parameter_detected.dart';

enum MethodDetectedType { commonMethod, getMehtod, setMethod, buildMethod, factoryMethod }

class MethodDetected {
  final List<AnnotationDetected> annotations;
  final String name;
  final String typeReturn;
  final MethodDetectedType type;
  final bool isStatic;
  final List<MethodParameterDetected> parameters;

  bool get isPrivate => name.first == '_';

  const MethodDetected({
    required this.annotations,
    required this.name,
    required this.typeReturn,
    required this.type,
    required this.isStatic,
    required this.parameters,
  });

  factory MethodDetected.fromMethodAnalizer({required MethodDeclaration declaration}) {
    return MethodDetected(
      isStatic: declaration.isStatic,
      name: declaration.name.toString(),
      typeReturn: _getTypeReturn(declaration),
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      type: _checkMethodType(declaration),
      parameters: MethodParameterDetected.getAnalizerParameters(parameters: declaration.parameters),
    );
  }

  factory MethodDetected.fromConstructAnalizer({required ConstructorDeclaration declaration}) {
    return MethodDetected(
      isStatic: true,
      name: declaration.name?.toString() ?? '',
      typeReturn: declaration.returnType.name,
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      type: declaration.factoryKeyword == null ? MethodDetectedType.buildMethod : MethodDetectedType.factoryMethod,
      parameters: MethodParameterDetected.getAnalizerParameters(parameters: declaration.parameters),
    );
  }

  static MethodDetectedType _checkMethodType(MethodDeclaration declaration) {
    if (declaration.isGetter) {
      return MethodDetectedType.getMehtod;
    } else if (declaration.isSetter) {
      return MethodDetectedType.setMethod;
    } else {
      return MethodDetectedType.commonMethod;
    }
  }

  static String _getTypeReturn(MethodDeclaration declaration) {
    return declaration.returnType?.toString() ?? 'void';
  }
}
