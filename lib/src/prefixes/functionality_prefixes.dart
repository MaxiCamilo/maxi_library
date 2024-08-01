import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

Future<void> continueOtherFutures() {
  return Future.delayed(Duration.zero);
}

T? containError<T>({
  required T Function() function,
  void Function(NegativeResult)? ifFails,
  void Function(dynamic)? ifUnknownFails,
}) {
  try {
    return function();
  } catch (ex) {
    if (ifFails != null && ex is NegativeResult) {
      ifFails(ex);
    }

    if (ifUnknownFails != null) {
      ifUnknownFails(ex);
    }
    return null;
  }
}

T? containErrorLog<T>({
  required String detail,
  required T Function() function,
  void Function(String, NegativeResult)? ifFails,
  void Function(String, dynamic)? ifUnknownFails,
}) {
  return containError(
    function: function,
    ifFails: (x) {
      log('[X] ${tr('Negative response was contained in ')} "$detail": ${x.toString()}');
      if (ifFails != null) {
        ifFails(detail, x);
      }
    },
    ifUnknownFails: (x) {
      log('[¡X!] ${tr('Failure contained in')} "$detail": $x');

      if (ifUnknownFails != null) {
        ifUnknownFails(detail, x);
      }
    },
  );
}

Future<T?> containErrorAsync<T>({
  required Future<T> Function() function,
  void Function(NegativeResult)? ifFails,
  void Function(dynamic)? ifUnknownFails,
}) async {
  try {
    return await function();
  } catch (ex) {
    if (ifFails != null && ex is NegativeResult) {
      ifFails(ex);
    }

    if (ifUnknownFails != null) {
      ifUnknownFails(ex);
    }
    return null;
  }
}

Future<T?> containErrorLogAsync<T>({
  required Future<T> Function() function,
  required String Function() detail,
}) {
  return containErrorAsync(
    function: function,
    ifFails: (x) => log('[X] ${tr('Negative response contained in')} "${detail()}": ${x.toString()}'),
    ifUnknownFails: (x) => log('[¡X!] ${tr('failure contained in')} "${detail()}": $x'),
  );
}

T volatile<T>({
  required String Function() detail,
  required T Function() function,
  void Function(NegativeResult)? ifFails,
  void Function(dynamic)? ifUnknownFails,
  void Function(dynamic)? ifFailsAnyway,
  NegativeResult Function(dynamic)? errorFactory,
}) {
  try {
    return function();
  } on NegativeResult catch (rn) {
    if (ifFails != null) {
      containError(function: () => ifFails(rn));
    }
    if (ifFailsAnyway != null) {
      containError(function: () => ifFailsAnyway(rn));
    }
    rethrow;
  } catch (ex) {
    late final NegativeResult rn;
    if (errorFactory == null) {
      rn = NegativeResult(
        identifier: NegativeResultCodes.nonStandardError,
        message: '${tr('An error occurred while executing the functionality')} "${detail()}", the error was: $ex',
        cause: ex,
      );
    } else {
      rn = errorFactory(ex);
    }

    if (ifFails != null) {
      containError(function: () => ifFails(rn));
    }

    if (ifUnknownFails != null) {
      containError(function: () => ifUnknownFails(ex));
    }

    if (ifFailsAnyway != null) {
      containError(function: () => ifFailsAnyway(rn));
    }

    throw rn;
  }
}

T volatileByFunctionality<T>({
  required String Function() errorMessage,
  required T Function() funcion,
}) =>
    volatile(
      detail: () => '',
      function: funcion,
      errorFactory: (p0) => NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: errorMessage(),
      ),
    );

Future<T> volatileAsync<T>({
  required String Function() detail,
  required Future<T> Function() function,
  void Function(NegativeResult)? ifFails,
  void Function(dynamic)? ifUnknownFails,
  void Function(dynamic)? ifFailsAnyway,
  NegativeResult Function(dynamic)? errorFactory,
}) async {
  try {
    return await function();
  } on NegativeResult catch (rn) {
    if (ifFails != null) {
      containError(function: () => ifFails(rn));
    }

    if (ifFailsAnyway != null) {
      containError(function: () => ifFailsAnyway(rn));
    }
    rethrow;
  } catch (ex) {
    late final NegativeResult rn;
    if (errorFactory == null) {
      rn = NegativeResult(
        identifier: NegativeResultCodes.nonStandardError,
        message: '${tr('An error occurred while executing the functionality')} "${detail()}", the error was: $ex',
      );
    } else {
      rn = errorFactory(ex);
    }

    if (ifFails != null) {
      containError(function: () => ifFails(rn));
    }

    if (ifUnknownFails != null) {
      containError(function: () => ifUnknownFails(ex));
    }

    if (ifFailsAnyway != null) {
      containError(function: () => ifFailsAnyway(rn));
    }

    throw rn;
  }
}

T cautious<T>({
  required String Function() reasonFailure,
  required T Function() function,
  NegativeResultCodes codeReasonFailure = NegativeResultCodes.invalidFunctionality,
  void Function(NegativeResult)? ifFails,
  void Function(dynamic)? ifUnknownFails,
}) =>
    volatile(
      detail: reasonFailure,
      function: function,
      errorFactory: (x) => NegativeResult(
        identifier: codeReasonFailure,
        message: reasonFailure(),
        cause: x,
      ),
      ifFails: ifFails,
      ifUnknownFails: ifUnknownFails,
    );

T programmingFailure<T>({
  required String Function() reasonFailure,
  required T Function() function,
}) =>
    volatile(
      detail: reasonFailure,
      function: function,
      errorFactory: (x) => NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: reasonFailure(),
        cause: x,
      ),
    );

void checkProgrammingFailure<T>({
  required String Function() thatChecks,
  required bool Function() result,
}) {
  final resultFunction = programmingFailure(
    reasonFailure: () => '$thatChecks ${tr('fired an error')}',
    function: result,
  );

  if (!resultFunction) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: '${tr('The checker ')} "$thatChecks" ${tr(' tested negative')}',
    );
  }
}
