import 'package:maxi_library/maxi_library.dart';

mixin IDeclarationReflector {
  List get annotations;
  List<ValueValidator> get validators;

  String get name;
  TranslatableText get formalName;
  IReflectionType get reflectedType;
  bool get isStatic;
  TranslatableText get description;

  NegativeResultValue? verifyValue({required dynamic value, required dynamic parentEntity}) {
    for (final val in validators) {
      final negative = val.performValidation(name: name, formalName: formalName, item: value, parentEntity: parentEntity);
      if (negative != null) {
        return NegativeResultValue.fromNegativeResult(name: name, formalName: formalName, nr: negative);
      }
    }

    if (value is IPostVerification) {
      try {
        value.postVerification();
      } catch (ex) {
        final nr = NegativeResultValue.searchNegativity(
          error: ex,
          formalName: formalName,
          name: name,
          value: value,
        );
        return nr;
      }
    }

    return null;
  }

  List<NegativeResultValue> listErrors({required dynamic value, required dynamic parentEntity}) {
    final list = <NegativeResultValue>[];

    for (final val in validators) {
      final negative = val.performValidation(name: name, formalName: formalName, item: value, parentEntity: parentEntity);
      if (negative != null) {
        list.add(NegativeResultValue.fromNegativeResult(name: name, formalName: formalName, nr: negative));
      }
    }

    if (value is IPostVerification) {
      try {
        value.postVerification();
      } catch (ex) {
        final nr = NegativeResultValue.searchNegativity(
          error: ex,
          name: name,
          formalName: formalName,
          value: value,
        );
        list.add(nr);
      }
    }

    return list;
  }

  void verifyValueDirectly({required dynamic value, required dynamic parentEntity}) {
    final error = verifyValue(value: value, parentEntity: parentEntity);
    if (error != null) {
      throw error;
    }
  }
}
