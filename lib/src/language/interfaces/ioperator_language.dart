import 'package:maxi_library/maxi_library.dart';

mixin IOperatorLanguage {
  String get prefixLanguage;

  String translateText(Oration text);

  String translateString(String text);

  Future<void> changeLanguage(String newPrefixLanguage);

  //Stream get notifyLanguageChange;
}
