import 'package:maxi_library/maxi_library.dart';

mixin IDeclarationReflector {
  List get annotations;
  List<ValueValidator> get validators;

  String get name;
  String get formalName;
  IReflectionType get reflectedType;
  bool get isStatic;

  NegativeResult? verifyValue({required dynamic value, required dynamic parentEntity}) {
    for (final val in validators) {
      final negative = val.performValidation(name: name, item: value, parentEntity: parentEntity);
      if (negative != null) {
        return NegativeResultValue.fromNegativeResult(name: tr(formalName), nr: negative);
      }
    }

    if (value is IPostVerification) {
      try {
        value.postVerification();
      } catch (ex) {
        final nr = NegativeResultValue.searchNegativity(
          error: ex,
          propertyName: tr(formalName),
          value: value,
        );
        return nr;
      }
    }

    return null;
  }

  void verifyValueDirectly({required dynamic value, required dynamic parentEntity}) {
    final error = verifyValue(value: value, parentEntity: parentEntity);
    if (error != null) {
      throw error;
    }
  }
}
