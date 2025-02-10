import 'package:maxi_library/maxi_library.dart';

class TranslatedOration extends Oration {
  const TranslatedOration({required super.message, super.textParts, super.tokenId});

  factory TranslatedOration.translate({required Oration text}) {
    return TranslatedOration(message: text.toString());
  }

  factory TranslatedOration.interpretFromJson({required String text}) {
    return TranslatedOration.translate(text: Oration.interpretFromJson(text: text));
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
