import 'package:maxi_library/maxi_library.dart';

class FixedParameter with IDeclarationReflector {
  final int position;

  final bool isOptional;
  final dynamic optionalValue;
  final Type type;
  
  @override
  final String name;

  @override
  final List annotations;

  @override
  bool get isStatic => false;

  @override
  late final IReflectionType reflectedType;

  @override
  late final TranslatableText formalName;

  @override
  late final List<ValueValidator> validators;

  @override
  late final TranslatableText description;

  FixedParameter({
    required this.position,
    required this.name,
    required this.isOptional,
    required this.optionalValue,
    required this.type,
    required this.annotations,
  }) {
    description = Description.searchDescription(annotations: annotations);
    reflectedType = ReflectionManager.getReflectionType(type, annotations: annotations);
    formalName = FormalName.searchFormalName(realName: tr(name), annotations: annotations);
    validators = annotations.whereType<ValueValidator>().toList();
  }
}
