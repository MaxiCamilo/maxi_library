import 'package:maxi_library/maxi_library.dart';

class EnumOption {
  final List annotations;
  final Enum value;

  String get name => value.name;
  int get position => value.index;
  Oration get formalName => FormalName.searchFormalName(realName: Oration(message: name), annotations: annotations);
  Oration get description => Description.searchDescription(annotations: annotations);

  const EnumOption({required this.annotations, required this.value});
}
