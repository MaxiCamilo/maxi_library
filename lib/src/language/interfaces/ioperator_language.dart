import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';

mixin IOperatorLanguage on StartableFunctionality {
  String get prefixLanguage;

  List<IBundleTranslatedText> get availableBundle;

  String getTranslation(String reference);

  Future<void> changeLanguage(String newPrefixLanguage);
}
