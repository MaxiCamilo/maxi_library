import 'package:maxi_library/maxi_library.dart';

abstract class ValueValidator {
  String get formalName;

  const ValueValidator();

  NegativeResult? performValidation({required String name, required dynamic item, required dynamic parentEntity});
}
