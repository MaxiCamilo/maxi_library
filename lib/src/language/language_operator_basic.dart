import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class LanguageOperatorBasic with IOperatorLanguage {

  @override
  String get prefixLanguage => 'en';

  

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    log('[LanguageOperatorBasic] WARNING! A language operator has not been assigned, so only English text will be displayed');
  }

  @override
  String translateString(String text) {
    return text;
  }

  @override
  String translateText(Oration text) {
    String formated = LanguageManager.translateString(text.message);

    if (text.isFixed) {
      return formated;
    }

    for (int i = 0; i < text.textParts.length; i++) {
      final part = text.textParts[i];
      late String textGenerated;
      if (part is TranslatedOration) {
        textGenerated = part.toString();
      }
      if (part is Oration) {
        textGenerated = translateText(part);
      } else {
        textGenerated = part.toString();
      }

      formated = formated.replaceAll('%${i + 1}', textGenerated);
    }
    return formated;
  }
}
