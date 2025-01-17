import 'package:maxi_library/maxi_library.dart';

class AlreadyTranslatedText extends TranslatableText {
  const AlreadyTranslatedText({required super.message, super.textParts, super.tokenId});

  factory AlreadyTranslatedText.translate({required TranslatableText text}) {
    return AlreadyTranslatedText(message: text.toString());
  }

  factory AlreadyTranslatedText.interpretFromJson({required String text}) {
    return AlreadyTranslatedText.translate(text: TranslatableText.interpretFromJson(text: text));
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
