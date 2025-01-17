import 'dart:convert';
import 'dart:developer';
import 'dart:io';

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

  factory NegativeResult.interpretJson({required String jsonText, bool checkTypeFlag = true}) => NegativeResult.interpret(values: ConverterUtilities.interpretToObjectJson(text: jsonText), checkTypeFlag: checkTypeFlag);

  factory NegativeResult.interpret({required Map<String, dynamic> values, required bool checkTypeFlag}) {
    if (checkTypeFlag && (!values.containsKey('\$type') || values['\$type'] is! String || !(values['\$type']! as String).startsWith('error'))) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: tr('Errors or negative results are invalid or do not have their type label'),
      );
    }

    return NegativeResult(
      message: TranslatableText.interpretFromJson(text: volatileProperty(propertyName: 'message', formalName: const TranslatableText(message: 'Error message'), function: () => values['message']!)),
      identifier:
          NegativeResultCodes.values[volatileProperty(propertyName: 'identifier', formalName: const TranslatableText(message: 'Error Identifier'), function: () => (values['identifier'] ?? values['idError'])! as int)],
      whenWasIt:
          DateTime.fromMillisecondsSinceEpoch(volatileProperty(propertyName: 'whenWasIt', formalName: const TranslatableText(message: 'Error date and time'), function: () => values['whenWasIt']! as int), isUtc: true)
              .toLocal(),
    );
  }

  factory NegativeResult.searchNegativity({
    required dynamic item,
    required TranslatableText actionDescription,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
    StackTrace? stackTrace,
  }) {
    if (item is NegativeResult) {
      return item;
    }
    if (item is ArgumentError) {
      return NegativeResult(identifier: NegativeResultCodes.invalidValue, message: tr('Argument error: %1', [item.message]), stackTrace: stackTrace?.toString() ?? '');
    }
    if (item is SocketException) {
      return NegativeResult(
          identifier: NegativeResultCodes.systemFailure, message: tr('A connection error occurred, Socket error %1: %2', [item.osError?.errorCode, item.message]), stackTrace: stackTrace?.toString() ?? '');
    } else {
      return NegativeResult(identifier: codeDescription, message: tr('The functionality %1 failed: %2', [actionDescription, item.toString()]), stackTrace: stackTrace?.toString() ?? '');
    }
  }

  @override
  String toString() => LanguageManager.translateText(message);

  void printConsole() {
    log('[X: ${identifier.name}] $message');
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
