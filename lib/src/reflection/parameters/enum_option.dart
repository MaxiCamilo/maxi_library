class EnumOption {
  final List annotations;
  final Enum value;

  String get name => value.name;
  int get position => value.index;

  const EnumOption({required this.annotations, required this.value});
}
