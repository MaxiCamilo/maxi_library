import 'package:maxi_library/maxi_library.dart';

mixin LanguageManager {
  static IOperatorLanguage _instance = LanguageOperatorBasic();

  static IOperatorLanguage get instance => _instance;

  static String translateText(Oration text) => _instance.translateText(text);

  static String translateString(String text) => _instance.translateString(text);

  static final notifyLanguageChangeOperator = IsolatedEvent<String>(name: '&#MxLang.&.nlc');

  static Stream<String> get notifyLanguageChange async* {
    await notifyLanguageChangeOperator.initialize();
    yield* notifyLanguageChangeOperator.receiver;
  }

  static Future<void> changeOperator(IOperatorLanguage newOperator) async {
    //await notifyLanguageChange.initialize();
    _instance = newOperator;
    if (_instance is StartableFunctionality) {
      await (_instance as StartableFunctionality).initialize();
    }
  }

  static Future<void> changeLanguage(String prefix) {
    return _instance.changeLanguage(prefix);
  }
}
