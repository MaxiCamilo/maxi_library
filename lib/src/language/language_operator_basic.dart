import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/ibundle_translated_text.dart';

class LanguageOperatorBasic with StartableFunctionality, IOperatorLanguage {
  @override
  String get prefixLanguage => 'en';

  @override
  List<IBundleTranslatedText> get availableBundle => const [];

  @override
  String getTranslation(String reference) {
    return reference;
  }

  @override
  Future<void> initializeFunctionality() async {}

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    log('[LanguageOperatorBasic] WARNING! A language operator has not been assigned, so only English text will be displayed');
  }
}
