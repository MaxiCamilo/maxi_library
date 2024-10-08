import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/language_operator_basic.dart';

mixin LanguageManager {
  static IOperatorLanguage _instance = LanguageOperatorBasic();

  static IOperatorLanguage get instance => _instance;

  static String translateText(TranslatableText text) => _instance.translateText(text);

  static Stream get notifyLanguageChange => _instance.notifyLanguageChange;

  static Future<void> changeOperator(IOperatorLanguage newOperator) async {
    _instance = newOperator;
    return _instance.initialize();
  }
}
