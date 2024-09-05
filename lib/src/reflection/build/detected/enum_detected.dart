import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';
import 'package:maxi_library/src/reflection/build/detected/enum_option_detected.dart';

class EnumDetected {
  final String name;
  final List<EnumOptionDetected> options;
  final List<AnnotationDetected> annotations;

  bool get isPrivate => name.first == '_';

  const EnumDetected({required this.name, required this.options, required this.annotations});

  factory EnumDetected.fromenumFactory({required EnumDeclaration declaration}) {
    return EnumDetected(
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      name: declaration.name.toString(),
      options: declaration.constants.map((x) => EnumOptionDetected.fromEnumOptionAnalizer(declaration: x)).toList(),
    );
  }
}
