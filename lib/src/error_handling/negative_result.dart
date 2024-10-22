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
        'whenWasIt': whenWasIt.millisecondsSinceEpoch,
      };
    } else {
      return {
        '\$type': 'error',
        'idError': identifier.index,
        'message': message.serialize(),
        'whenWasIt': whenWasIt.millisecondsSinceEpoch,
        'originalError': cause.toString(),
      };
    }
  }

  String serializeToJson() => json.encode(serialize());

  @override
  performSerialization({required entity, required IDeclarationReflector declaration, bool onlyModificable = true, bool allowStaticFields = false}) => serialize();
}
