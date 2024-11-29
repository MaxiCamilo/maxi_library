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

  factory TranslatableText.interpretFromJson({required dynamic text}) {
    if (text is String) {
      return volatile(detail: tr('The translatable text cannot be interpreted (it must be JSON)'), function: () => TranslatableText.interpret(map: json.decode(text)));
    } else if (text is Map<String, dynamic>) {
      return TranslatableText.interpret(map: text);
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: tr('The format of the translatable text is not correct'));
    }
  }
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

  @override
  int get hashCode => Object.hash(
        tokenId,
        message,
        _getListPart(0),
        _getListPart(1),
        _getListPart(2),
        _getListPart(3),
        _getListPart(4),
        _getListPart(5),
        _getListPart(6),
        _getListPart(7),
        _getListPart(8),
        _getListPart(9),
        _getListPart(10),
        _getListPart(11),
        _getListPart(12),
        _getListPart(13),
        _getListPart(14),
        _getListPart(15),
        _getListPart(16),
      );

  Object? _getListPart(int i) => textParts.length >= i ? null : textParts[i].hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! TranslatableText) {
      return false;
    }

    if (message != other.message || tokenId != other.tokenId || textParts.length != other.textParts.length) {
      return false;
    }

    for (int i = 0; i < textParts.length; i++) {
      if (textParts[i] != other.textParts[i]) {
        return false;
      }
    }
    return true;
  }
}
