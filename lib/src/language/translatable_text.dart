import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class TranslatableText with ICustomSerialization {
  final String tokenId;
  final String message;
  final List textParts;

  bool get isFixed => textParts.isEmpty;
  bool get isNotEmpty => message.isNotEmpty;
  bool get isEmpty => message.isEmpty;

  static const TranslatableText empty = TranslatableText(message: '');

  const TranslatableText({required this.message, this.tokenId = '', this.textParts = const []});

  factory TranslatableText.changeMessage({required TranslatableText original, required String text}) {
    return TranslatableText(message: text, textParts: original.textParts, tokenId: original.tokenId);
  }

  factory TranslatableText.interpretFromJson({required String text}) =>
      volatile(detail: tr('The translatable text cannot be interpreted (it must be JSON)'), function: () => TranslatableText.interpret(map: json.decode(text)));

  factory TranslatableText.interpret({required Map<String, dynamic> map}) {
    final textParts = [];

    for (final item in volatileProperty(propertyName: tr('Text Parts'), function: () => map['textParts'] as List)) {
      final text = item.toString();
      if (text.startsWith('{')) {
        textParts.add(TranslatableText.interpretFromJson(text: text));
      } else {
        textParts.add(text);
      }
    }

    return TranslatableText(
      tokenId: volatileProperty(propertyName: tr('Token Id'), function: () => map['tokenId'].toString()),
      message: volatileProperty(propertyName: tr('message'), function: () => map['message'].toString()),
      textParts: textParts,
    );
  }

  @override
  String toString() {
    if (isFixed) {
      return message;
    }

    String formated = message;

    for (int i = 0; i < textParts.length; i++) {
      final part = textParts[i];
      late final String textGenerated;
      if (part is TranslatableText) {
        textGenerated = LanguageManager.translateText(part);
      } else {
        textGenerated = part.toString();
      }

      formated = formated.replaceAll('%${i + 1}', textGenerated);
    }
    return formated;
  }

  @override
  Map<String, dynamic> serialize() {
    final list = [];

    for (final item in textParts) {
      if (item is TranslatableText) {
        list.add(item.serialize());
      } else {
        list.add(item.toString());
      }
    }

    return {
      'message': message,
      'tokenId': tokenId,
      'textParts': list,
      '\$type': 'TranslatableText',
    };
  }

  String serializeToJson() => json.encode(serialize());
}
