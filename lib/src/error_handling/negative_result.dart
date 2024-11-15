import 'dart:convert';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class NegativeResult implements Exception, CustomSerialization, ICustomSerialization {
  NegativeResultCodes identifier;
  TranslatableText message;
  DateTime whenWasIt;
  dynamic cause;
  String stackTrace;

  NegativeResult({
    required this.identifier,
    required this.message,
    DateTime? whenWasIt,
    this.cause,
    this.stackTrace = '',
  }) : whenWasIt = whenWasIt ?? DateTime.now();

  factory NegativeResult.interpret({required Map<String, dynamic> values, required bool checkTypeFlag}) {
    if (checkTypeFlag && (!values.containsKey('\$type') || values['\$type'] is! String || !(values['\$type']! as String).startsWith('error'))) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('Errors or negative results are invalid or do not have their type label'),
      );
    }

    return NegativeResult(
      message: TranslatableText.interpretFromJson(text: volatileProperty(propertyName: tr('message'), function: () => values['message']!)),
      identifier: NegativeResultCodes.values[volatileProperty(propertyName: tr('identifier'), function: () => values['identifier']! as int)],
      whenWasIt: DateTime.fromMillisecondsSinceEpoch(volatileProperty(propertyName: tr('whenWasIt'), function: () => values['whenWasIt']! as int), isUtc: true).toLocal(),
    );
  }

  @override
  String toString() => LanguageManager.translateText(message);

  void printConsole() {
    log('[X: ${identifier.name}] $message');
  }

  static NegativeResult searchNegativity({
    required dynamic item,
    required TranslatableText actionDescription,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
  }) {
    if (item is NegativeResult) {
      return item;
    } else {
      return NegativeResult(identifier: codeDescription, message: tr('The functionality %1 failed', [actionDescription]));
    }
  }

  @override
  Map<String, dynamic> serialize() {
    if (cause == null) {
      return {
        '\$type': 'error',
        'idError': identifier.index,
        'message': message.serialize(),
        'whenWasIt': whenWasIt.toUtc().millisecondsSinceEpoch,
      };
    } else {
      return {
        '\$type': 'error',
        'idError': identifier.index,
        'message': message.serialize(),
        'whenWasIt': whenWasIt.toUtc().millisecondsSinceEpoch,
        'originalError': cause.toString(),
      };
    }
  }

  String serializeToJson() => json.encode(serialize());

  @override
  performSerialization({required entity, required IDeclarationReflector declaration, bool onlyModificable = true, bool allowStaticFields = false}) => serialize();
}
