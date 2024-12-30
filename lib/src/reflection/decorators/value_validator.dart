import 'package:maxi_library/maxi_library.dart';

abstract class ValueValidator {
  TranslatableText get formalName;

  const ValueValidator();

  NegativeResult? performValidation({required String name, required TranslatableText formalName, required dynamic item, required dynamic parentEntity});
}
