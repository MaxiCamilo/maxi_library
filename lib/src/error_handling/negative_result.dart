import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class NegativeResult implements Exception, CustomSerialization {
  NegativeResultCodes identifier;
  String message;
  DateTime whenWasIt;
  dynamic cause;

  NegativeResult({
    required this.identifier,
    required this.message,
    DateTime? whenWasIt,
    this.cause,
  }) : whenWasIt = whenWasIt ?? DateTime.now();

  @override
  String toString() => message;

  void printConsole() {
    log('[X: ${identifier.name}] $message');
  }

  static NegativeResult searchNegativity({
    required dynamic item,
    required String actionDescription,
    NegativeResultCodes codeDescription = NegativeResultCodes.externalFault,
  }) {
    if (item is NegativeResult) {
      return item;
    } else {
      return NegativeResult(identifier: codeDescription, message: trc('The functionality %1 failed', [actionDescription]));
    }
  }

  Map<String, dynamic> serialize() {
    if (cause == null) {
      return {
        'idError': identifier.index,
        'message': message,
        'whenWasIt': whenWasIt.millisecondsSinceEpoch,
      };
    } else {
      return {
        'idError': identifier.index,
        'message': message,
        'whenWasIt': whenWasIt.millisecondsSinceEpoch,
        'originalError': cause.toString(),
      };
    }
  }

  @override
  performSerialization({required entity, required IDeclarationReflector declaration, bool onlyModificable = true, bool allowStaticFields = false}) => serialize();
}
