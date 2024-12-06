import 'package:maxi_library/maxi_library.dart';

mixin LanguageManager {
  static IOperatorLanguage _instance = LanguageOperatorBasic();

  static IOperatorLanguage get instance => _instance;

  static String translateText(TranslatableText text) => _instance.translateText(text);

  static String translateString(String text) => _instance.translateString(text);

  static Stream get notifyLanguageChange => _instance.notifyLanguageChange;

  static Future<void> changeOperator(IOperatorLanguage newOperator) async {
    _instance = newOperator;
    if (_instance is StartableFunctionality) {
      await (_instance as StartableFunctionality).initialize();
    }
  }
}
