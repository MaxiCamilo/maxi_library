import 'package:maxi_library/maxi_library.dart';

class TranslatedText extends Oration {
  const TranslatedText({required super.message, super.textParts, super.tokenId});

  factory TranslatedText.translate({required Oration text}) {
    return TranslatedText(message: text.toString());
  }

  factory TranslatedText.interpretFromJson({required String text}) {
    return TranslatedText.translate(text: Oration.interpretFromJson(text: text));
  }

  @override
  String toString() {
    if (textParts.isEmpty) {
      return message;
    }

    String formated = message;
    for (int i = 0; i < textParts.length; i++) {
      formated = formated.replaceAll('%${i + 1}', textParts[i].toString());
    }
    return formated;
  }
}
