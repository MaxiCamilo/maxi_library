import 'package:maxi_library/maxi_library.dart';

mixin IDeclarationReflector {
  List get annotations;
  List<ValueValidator> get validatos;

  String get name;
  String get formalName;
  IReflectionType get reflectedType;
  bool get isStatic;

  NegativeResult? verifyValue({required dynamic value}) {
    for (final val in validatos) {
      final negative = val.performValidation(name: name, item: value, entity: null);
      if (negative != null) {
        return NegativeResultValue.fromNegativeResult(name: formalName, nr: negative);
      }
    }

    if (value is IPostVerification) {
      try {
        value.postVerification();
      } catch (ex) {
        final nr = NegativeResultValue.searchNegativity(
          item: ex,
          actionDescription: 'Post validation of "$formalName"',
          propertyName: formalName,
          value: value,
        );
        return nr;
      }
    }

    return null;
  }

  void verifyValueDirectly({required dynamic value}) {
    final error = verifyValue(value: value);
    if (error != null) {
      throw error;
    }
  }
}
