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
      log(trc('[X] Negative response was contained in "%1": %2', [detail, x]));
      if (ifFails != null) {
        ifFails(detail, x);
      }
    },
    ifUnknownFails: (x) {
      log(trc('[¡X!] Failure contained in: "%1": %2', [detail, x]));

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
  required String Function() detail,
  required Future<T> Function() function,
}) {
  return containErrorAsync(
    function: function,
    ifFails: (x) => log(trc('[X] Negative response contained in "%1": "%2"', [detail(), x])),
    ifUnknownFails: (x) => log(trc('[¡X!] Failure contained in "%1": "%2"', [detail(), x])),
  );
}

T addToErrorDescription<T>({
  required String Function() additionalDetails,
  required T Function() function,
  bool before = true,
  NegativeResultCodes ifIsUnknownError = NegativeResultCodes.implementationFailure,
}) {
  try {
    return function();
  } on NegativeResult catch (nr) {
    nr.message = before ? '${additionalDetails()}${nr.message}' : '${nr.message}${additionalDetails()}';
    rethrow;
  } catch (ex) {
    throw NegativeResult(
      identifier: ifIsUnknownError,
      message: '${additionalDetails()}: "$ex"',
      cause: ex,
    );
  }
}

T volatileFactory<T>({
  required T Function() function,
  NegativeResult Function(NegativeResult)? negativeFactory,
  NegativeResult Function(dynamic)? errorFactory,
}) {
  try {
    return function();
  } catch (ex) {
    if (negativeFactory != null && ex is NegativeResult) {
      throw negativeFactory(ex);
    } else if (errorFactory != null) {
      throw errorFactory(ex);
    } else {
      rethrow;
    }
  }
}

T volatile<T>({
  required String Function() detail,
  required T Function() function,
  void Function(NegativeResult)? ifFails,
  void Function(dynamic)? ifUnknownFails,
  void Function(dynamic)? ifFailsAnyway,
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
    final NegativeResult rn = NegativeResult(
      identifier: NegativeResultCodes.nonStandardError,
      message: trc('An error occurred while executing the functionality "%1", the error was: %2', [detail(), ex]),
      cause: ex,
    );

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
  required T Function() function,
}) =>
    volatileFactory(
      function: function,
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
        message: trc('Something went wrong while the function was running "%1", the error was: %2', [detail(), ex]),
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
}) =>
    volatileFactory(
      function: function,
      errorFactory: (x) => NegativeResult(
        identifier: codeReasonFailure,
        message: reasonFailure(),
        cause: x,
      ),
    );

T programmingFailure<T>({
  required String Function() reasonFailure,
  required T Function() function,
}) =>
    volatileFactory(
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
    reasonFailure: () => trc('%1 fired an error', [thatChecks]),
    function: result,
  );

  if (!resultFunction) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: trc('The checker "%1" tested negative', [thatChecks]),
    );
  }
}

T volatileProperty<T>({
  required String Function() propertyName,
  required T Function() function,
  void Function(NegativeResultValue)? ifFails,
  void Function(dynamic)? ifUnknownFails,
  void Function(dynamic)? ifFailsAnyway,
  NegativeResultValue Function(String, dynamic)? errorFactory,
}) {
  try {
    return function();
  } on NegativeResult catch (nr) {
    final rnp = NegativeResultValue.fromNegativeResult(name: propertyName(), nr: nr);
    if (ifFails != null) {
      containError(function: () => ifFails(rnp));
    }
    if (ifFailsAnyway != null) {
      containError(function: () => ifFailsAnyway(rnp));
    }
    throw rnp;
  } catch (ex) {
    late final NegativeResultValue rnp;
    if (errorFactory == null) {
      rnp = NegativeResultValue(
        name: propertyName(),
        message: trc('An error occurred while executing the functionality in the property %1, the error was: %2', [propertyName(), ex]),
        cause: ex,
      );
    } else {
      rnp = errorFactory(propertyName(), ex);
    }

    if (ifFails != null) {
      containError(function: () => ifFails(rnp));
    }

    if (ifUnknownFails != null) {
      containError(function: () => ifUnknownFails(ex));
    }

    if (ifFailsAnyway != null) {
      containError(function: () => ifFailsAnyway(rnp));
    }

    throw rnp;
  }
}
