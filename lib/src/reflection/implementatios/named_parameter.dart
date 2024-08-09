import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ideclaration_reflector.dart';

class NamedParameter with IDeclarationReflector {
  final bool isRequierd;
  final dynamic optinalValue;
  final Type type;

  @override
  final String name;

  @override
  final List annotations;

  @override
  bool get isStatic => true;

  @override
  late final IReflectionType reflectedType;

  @override
  late final String formalName;

  @override
  late final List<ValueValidator> validators;

  NamedParameter({
    required this.annotations,
    required this.name,
    required this.isRequierd,
    required this.optinalValue,
    required this.type,
  }) {
    reflectedType = ReflectionManager.getReflectionType(type, annotations: annotations);
    formalName = FormalName.searchFormalName(realName: name, annotations: annotations);
    validators = annotations.whereType<ValueValidator>().toList();
  }
}
