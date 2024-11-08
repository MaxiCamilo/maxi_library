import 'package:maxi_library/maxi_library.dart';

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
  late final TranslatableText formalName;

  @override
  late final List<ValueValidator> validators;

  @override
  late final TranslatableText description;

  NamedParameter({
    required this.annotations,
    required this.name,
    required this.isRequierd,
    required this.optinalValue,
    required this.type,
  }) {
    description = Description.searchDescription(annotations: annotations);
    reflectedType = ReflectionManager.getReflectionType(type, annotations: annotations);
    formalName = FormalName.searchFormalName(realName: tr(name), annotations: annotations);
    validators = annotations.whereType<ValueValidator>().toList();
  }
}
