import 'package:maxi_library/maxi_library.dart';

abstract class ValueValidator {
  Oration get formalName;

  const ValueValidator();

  NegativeResult? performValidation({required String name, required Oration formalName, required dynamic item, required dynamic parentEntity});

  void directValidation({required String name, required Oration formalName, required dynamic item, required dynamic parentEntity}) {
    final error = performValidation(formalName: formalName, name: name, item: item, parentEntity: parentEntity);
    if (error != null) {
      throw error;
    }
  }
}
