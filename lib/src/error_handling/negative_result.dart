import 'dart:developer';

import 'error_codes.dart';

class NegativeResult implements Exception {
  final NegativeResultCodes identifier;
  final String message;
  final DateTime whenWas;
  final dynamic cause;

  NegativeResult({
    required this.identifier,
    required this.message,
    DateTime? whenWas,
    this.cause,
  }) : whenWas = whenWas ?? DateTime.now();

  @override
  String toString() => message;

  void printConsole() {
    log('[X: ${identifier.name}] $message');
  }

  NegativeResult searchNegativity({
    required dynamic item,
    required String actionDescription,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
  }) {
    if (item is NegativeResult) {
      return item;
    } else {
      return NegativeResult(identifier: codeDescription, message: '');
    }
  }

  Map<String, dynamic> serialize() {
    if (cause == null) {
      return {
        'idError': identifier.index,
        'message': message,
        'whenWas': whenWas.millisecondsSinceEpoch,
      };
    } else {
      return {
        'idError': identifier.index,
        'message': message,
        'whenWas': whenWas.millisecondsSinceEpoch,
        'originalError': cause.toString(),
      };
    }
  }
}
