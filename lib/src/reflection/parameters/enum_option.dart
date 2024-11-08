import 'package:maxi_library/maxi_library.dart';

class EnumOption {
  final List annotations;
  final Enum value;

  String get name => value.name;
  int get position => value.index;
  TranslatableText get formalName => FormalName.searchFormalName(realName: tr(name), annotations: annotations);
  TranslatableText get description => Description.searchDescription(annotations: annotations);

  const EnumOption({required this.annotations, required this.value});
}
