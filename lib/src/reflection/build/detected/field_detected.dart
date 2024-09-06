import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';

class FieldDetected {
  final List<AnnotationDetected> annotations;
  final String name;
  final String typeValue;
  final bool isStatic;
  final bool isConst;
  final bool isLate;
  final bool isFinal;
  final bool hasDefaultValue;
  final String defaulValue;

  bool get isPrivate => name.first == '_';
  bool get acceptNull => name.last == '?';

  const FieldDetected({
    required this.annotations,
    required this.name,
    required this.typeValue,
    required this.isStatic,
    required this.isConst,
    required this.isLate,
    required this.isFinal,
    required this.hasDefaultValue,
    required this.defaulValue,
  });

  factory FieldDetected.fromFieldAnalizer({required VariableDeclaration declaration}) {
    final parentList = volatile(detail: () => trc('Parent of variable %1 is "VariableDeclarationList"', [declaration.toString()]), function: () => declaration.parent as VariableDeclarationList);
    final parent = volatile(detail: () => trc('Parent of variable %1 is "VariableDeclaration"', [parentList.toString()]), function: () => parentList.parent as FieldDeclaration);

    return FieldDetected(
      annotations: parent.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      name: declaration.name.toString(),
      typeValue: parentList.type?.toString() ?? 'dynamic',
      isConst: declaration.isConst,
      isFinal: declaration.isFinal,
      isLate: declaration.isLate,
      isStatic: parent.isStatic,
      defaulValue: declaration.initializer?.toString() ?? '',
      hasDefaultValue: declaration.initializer != null,
    );
  }
}
