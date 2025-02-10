import 'package:maxi_library/maxi_library.dart';

abstract class ValueValidator {
  Oration get formalName;

  const ValueValidator();

  NegativeResult? performValidation({required String name, required Oration formalName, required dynamic item, required dynamic parentEntity});
}
