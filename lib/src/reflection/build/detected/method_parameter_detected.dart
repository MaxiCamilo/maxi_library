import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';

class MethodParameterDetected {
  final List<AnnotationDetected> annotations;
  final String name;
  final String typeValue;
  final int position;
  final bool isNamed;
  final bool hasDefaultValue;
  final String defaultValue;
  final bool acceptNulls;

  const MethodParameterDetected({
    required this.annotations,
    required this.name,
    required this.typeValue,
    required this.position,
    required this.isNamed,
    required this.hasDefaultValue,
    required this.defaultValue,
    required this.acceptNulls,
  });

  factory MethodParameterDetected.fromAnalizer({required int position, required FormalParameter declaration}) {
    /*
    if (declaration is DefaultFormalParameter) {
      return MethodParameterDetected.fromAnalizer(position: position, declaration: declaration.parameter);
    }*/
    final type = _getTypeValue(declaration);

    return MethodParameterDetected(
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      isNamed: declaration.isNamed,
      name: declaration.name.toString(),
      position: position,
      typeValue: type,
      acceptNulls: type.last == '?',
      hasDefaultValue: !declaration.isRequired,
      defaultValue: _getDefaultValue(typeParameter: type, declaration: declaration),
    );
  }

  static List<MethodParameterDetected> getAnalizerParameters({required FormalParameterList? parameters}) {
    if (parameters == null) {
      return const [];
    }

    final list = <MethodParameterDetected>[];

    for (int i = 0; i < parameters.parameters.length; i++) {
      final item = MethodParameterDetected.fromAnalizer(position: i, declaration: parameters.parameters[i]);
      list.add(item);
    }

    return list;
  }

  static String _getTypeValue(FormalParameter declaration) {
    if (declaration is SimpleFormalParameter) {
      return declaration.type?.toString() ?? 'dynamic';
    }
    if (declaration is DefaultFormalParameter) {
      return _getTypeValue(declaration.parameter);
    }
    return 'dynamic';
    //return declaration.declaredElement?.type.toString() ?? 'dynamic';
  }

  static String _getDefaultValue({required String typeParameter, required FormalParameter declaration}) {
    if (declaration.isRequired) {
      return '';
    }
    if (declaration is DefaultFormalParameter) {
      return declaration.defaultValue?.toString() ?? '';
    } else {
      return 'dynamic';
      //return declaration.declaredElement?.defaultValueCode ?? '';
    }
  }
}
