import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';

class EnumOptionDetected {
  final String value;
  final List<AnnotationDetected> annotations;

  const EnumOptionDetected({
    required this.value,
    required this.annotations,
  });

  factory EnumOptionDetected.fromEnumOptionAnalizer({required EnumConstantDeclaration declaration}) {
    return EnumOptionDetected(
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      value: declaration.name.toString(),
    );
  }
}
