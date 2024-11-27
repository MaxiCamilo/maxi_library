import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';

mixin IEntityFramework {
  bool get hasPrimaryKey;

  IGetterReflector get primaryKey;

  int getPrimaryKey({required instance});

  void changePrimaryKey({required instance, required int newId});

  dynamic interpret({
    required dynamic value,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  });

  List createList([Iterable? content]);

  List<T> interpretAslist<T>({
    required dynamic value,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  });

  List<T> interpretJsonAslist<T>({
    required String rawText,
    required bool tryToCorrectNames,
    bool enableCustomInterpretation = true,
    bool verify = true,
    bool acceptZeroIdentifier = true,
    bool primaryKeyMustBePresent = true,
    bool essentialKeysMustBePresent = true,
  }) {
    final jsonContent = volatile(detail: tr('The text is not valid json'), function: () => json.decode(rawText));
    return interpretAslist<T>(
      value: jsonContent,
      tryToCorrectNames: tryToCorrectNames,
      enableCustomInterpretation: enableCustomInterpretation,
      verify: verify,
      acceptZeroIdentifier: acceptZeroIdentifier,
      primaryKeyMustBePresent: primaryKeyMustBePresent,
      essentialKeysMustBePresent: essentialKeysMustBePresent,
    );
  }
}
