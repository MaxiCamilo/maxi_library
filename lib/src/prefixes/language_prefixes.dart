import 'package:maxi_library/maxi_library.dart';

String tr(String part) {
  return LanguageManager.getTranslation(part);
}

String trc(String text, List parts) {
  TranslatableText translatedText = TranslatableText(text);
  for (final part in parts) {
    translatedText = translatedText.append(part.toString());
  }

  return LanguageManager.getTranslation(translatedText.text);
}
