import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class Oration with ICustomSerialization {
  static const empty = TranslatedText(message: '');

  final String tokenId;
  final String message;
  final List textParts;

  bool get isFixed => textParts.isEmpty;
  bool get isNotEmpty => message.isNotEmpty;
  bool get isEmpty => message.isEmpty;

  const Oration({required this.message, this.tokenId = '', this.textParts = const []});

  factory Oration.changeMessage({required Oration original, required String text}) {
    return Oration(message: text, textParts: original.textParts, tokenId: original.tokenId);
  }

  factory Oration.interpretFromJson({required dynamic text}) {
    if (text is String) {
      if (text.isEmpty) {
        return const TranslatedText(message: '');
      }
      return volatile(detail: Oration(message: 'The translatable text cannot be interpreted (it must be JSON)'), function: () => Oration.interpret(map: json.decode(text)));
    } else if (text is Map<String, dynamic>) {
      return Oration.interpret(map: text);
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'The format of the translatable text is not correct'));
    }
  }
  factory Oration.interpret({required Map<String, dynamic> map}) {
    final textParts = [];

    for (final item in volatileProperty(formalName: Oration(message: 'Text Parts'), propertyName: 'textParts', function: () => map['textParts'] as List)) {
      if (item is Map<String, dynamic>) {
        textParts.add(Oration.interpret(map: item));
        continue;
      }

      final text = item.toString();
      if (text.startsWith('{')) {
        textParts.add(Oration.interpretFromJson(text: text));
      } else {
        textParts.add(text);
      }
    }

    return Oration(
      tokenId: volatileProperty(formalName: Oration(message: 'Message Identifier Token'), propertyName: 'tokenId', function: () => map['tokenId'].toString()),
      message: volatileProperty(formalName: Oration(message: 'Text message'), propertyName: 'message', function: () => map['message'].toString()),
      textParts: textParts,
    );
  }

  @override
  String toString() {
    return LanguageManager.translateText(this);
  }

  @override
  Map<String, dynamic> serialize() {
    final list = [];
    for (final item in textParts) {
      if (item is Oration) {
        list.add(item.serialize());
      } else {
        list.add(item.toString());
      }
    }

    return {
      'message': message,
      'tokenId': tokenId,
      'textParts': list,
      '\$type': 'Oration',
    };
  }

  String serializeToJson() => json.encode(serialize());

  @override
  int get hashCode => Object.hash(
        runtimeType.toString(),
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

  Object? _getListPart(int i) => textParts.length <= i ? 0 : textParts[i].hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Oration || other.runtimeType != runtimeType) {
      return false;
    }

    if (tokenId != other.tokenId || textParts.length != other.textParts.length || message != other.message) {
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
