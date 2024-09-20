import 'package:maxi_library/maxi_library.dart';

String tr(String part) {
  return LanguageManager.getTranslation(part);
}

String Function() trf(String part, [List parts = const []]) {
  return () => LanguageManager.getTranslation(part);
}

String trc(String text, List parts) {
  text = LanguageManager.getTranslation(text);

  TranslatableText translatedText = TranslatableText(text);
  for (final part in parts) {
    translatedText = translatedText.append(part.toString());
  }

  return translatedText.text;
}
