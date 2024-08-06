class FixedParameter {
  final int position;
  final String name;
  final bool isOptional;
  final dynamic optionalValue;
  final Type type;

  const FixedParameter({required this.position, required this.name, required this.isOptional, required this.optionalValue, required this.type});
}
