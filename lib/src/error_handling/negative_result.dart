import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class NegativeResult implements Exception, CustomSerialization, ICustomSerialization {
  NegativeResultCodes identifier;
  Oration message;
  DateTime whenWasIt;
  dynamic cause;
  String stackTrace;

  NegativeResult({
    required this.identifier,
    required this.message,
    DateTime? whenWasIt,
    this.cause,
    String? stackTrace,
  })  : whenWasIt = whenWasIt ?? DateTime.now(),
        stackTrace = stackTrace ?? StackTrace.current.toString();

  factory NegativeResult.interpretJson({required String jsonText, bool checkTypeFlag = true}) => NegativeResult.interpret(values: ConverterUtilities.interpretToObjectJson(text: jsonText), checkTypeFlag: checkTypeFlag);

  factory NegativeResult.interpret({required Map<String, dynamic> values, required bool checkTypeFlag}) {
    if (checkTypeFlag && (!values.containsKey('\$type') || values['\$type'] is! String || !(values['\$type']! as String).startsWith('error'))) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'Errors or negative results are invalid or do not have their type label'),
      );
    }

    if (values.containsKey('\$type') && values['\$type'] is String && (values['\$type']! as String) == NegativeResultValue.labelType) {
      return NegativeResultValue.interpret(values: values, checkTypeFlag: false);
    }

    return NegativeResult(
      message: Oration.interpretFromJson(text: volatileProperty(propertyName: 'message', formalName: const Oration(message: 'Error message'), function: () => values['message']!)),
      identifier: volatileProperty(propertyName: 'identifier', formalName: const Oration(message: 'Error Identifier'), function: () => NegativeResultCodes.values[((values['identifier'] ?? values['idError'])! as int)]),
      whenWasIt:
          DateTime.fromMillisecondsSinceEpoch(volatileProperty(propertyName: 'whenWasIt', formalName: const Oration(message: 'Error date and time'), function: () => values['whenWasIt']! as int), isUtc: true).toLocal(),
      stackTrace: values['stackTrace'] ?? '',
    );
  }

  factory NegativeResult.searchNegativity({
    required dynamic item,
    required Oration actionDescription,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
    StackTrace? stackTrace,
  }) {
    if (item is NegativeResult) {
      return item;
    }
    if (item is ArgumentError) {
      return NegativeResult(identifier: NegativeResultCodes.invalidValue, message: Oration(message: 'Argument error: %1', textParts: [item.message]), stackTrace: stackTrace?.toString() ?? '');
    }
    if (item is SocketException) {
      return NegativeResult(
          identifier: NegativeResultCodes.systemFailure,
          message: Oration(message: 'A connection error occurred, Socket error %1: %2', textParts: [item.osError?.errorCode, item.message]),
          stackTrace: stackTrace?.toString() ?? '');
    } else {
      return NegativeResult(identifier: codeDescription, message: Oration(message: 'The functionality %1 failed: %2', textParts: [actionDescription, item.toString()]), stackTrace: stackTrace?.toString() ?? '');
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
        'stackTrace': stackTrace,
      };
    } else {
      return {
        '\$type': 'error',
        'idError': identifier.index,
        'message': message.serialize(),
        'whenWasIt': whenWasIt.toUtc().millisecondsSinceEpoch,
        'originalError': cause.toString(),
        'stackTrace': stackTrace,
      };
    }
  }

  String serializeToJson() => json.encode(serialize());

  @override
  performSerialization({required value, required IDeclarationReflector declaration, bool onlyModificable = true, bool allowStaticFields = false}) => serialize();
}
