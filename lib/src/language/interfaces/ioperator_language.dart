import 'package:maxi_library/maxi_library.dart';

mixin IOperatorLanguage on StartableFunctionality {
  String get prefixLanguage;

  String translateText(TranslatableText text);

  Future<void> changeLanguage(String newPrefixLanguage);

  Stream get notifyLanguageChange;
}
