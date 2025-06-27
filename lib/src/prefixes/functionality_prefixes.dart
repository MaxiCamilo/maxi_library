import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_as_future.dart';

Future<void> continueOtherFutures() {
  return Future.delayed(Duration.zero);
}

Future<(dynamic, StackTrace)?> maxiScheduleMicrotask(FutureOr Function() callback) {
  final stackTrace = StackTrace.current;
  final completer = Completer<(dynamic, StackTrace)?>();

  scheduleMicrotask(() async {
    try {
      await callback();
      completer.completeIfIncomplete(null);
    } catch (ex, st) {
      final newSt = StackTrace.fromString('${st.toString()}\n-------------------------------------- Schedule Microtask --------------------------------------\n${stackTrace.toString()}');
      log('[Schedule Microtask Error]: $ex \n $newSt\n------------------------------------------------------------------------------');
      completer.completeIfIncomplete((ex, newSt));
    }
  });

  return completer.future;
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
  required Oration detail,
  required T Function() function,
  void Function(Oration, NegativeResult)? ifFails,
  void Function(Oration, dynamic)? ifUnknownFails,
}) {
  return containError(
    function: function,
    ifFails: (x) {
      log(Oration(message: '[X] Negative response was contained in "%1": %2', textParts: [detail, x]).toString());
      if (ifFails != null) {
        ifFails(detail, x);
      }
    },
    ifUnknownFails: (x) {
      log(Oration(message: '[¡X!] Failure contained in: "%1": %2', textParts: [detail, x]).toString());

      if (ifUnknownFails != null) {
        ifUnknownFails(detail, x);
      }
    },
  );
}

Future<T?> containErrorAsync<T>({
  required FutureOr<T> Function() function,
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
  required Oration detail,
  required FutureOr<T> Function() function,
}) {
  return containErrorAsync(
    function: function,
    ifFails: (x) => log(Oration(message: '[X] Negative response contained in "%1": "%2"', textParts: [detail, x]).toString()),
    ifUnknownFails: (x) => log(Oration(message: '[¡X!] Failure contained in "%1": "%2"', textParts: [detail, x]).toString()),
  );
}

T addToErrorDescription<T>({
  required Oration additionalDetails,
  required T Function() function,
  bool before = true,
  NegativeResultCodes ifIsUnknownError = NegativeResultCodes.implementationFailure,
}) {
  try {
    return function();
  } on NegativeResult catch (nr) {
    nr.message = Oration(message: '%1%2', textParts: before ? [additionalDetails, nr.message] : [nr.message, additionalDetails]);

    //before ? '${additionalDetails.toString()}${nr.message.toString()}' : '${nr.message.toString()}${additionalDetails.toString()}';
    rethrow;
  } catch (ex) {
    throw NegativeResult(
      identifier: ifIsUnknownError,
      message: Oration(message: '%1: "%2"', textParts: [additionalDetails, ex]),
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

T volatile<T>(
    {required Oration detail,
    required T Function() function,
    void Function(NegativeResult)? ifFails,
    void Function(dynamic)? ifUnknownFails,
    void Function(dynamic)? ifFailsAnyway,
    NegativeResultCodes errorID = NegativeResultCodes.nonStandardError}) {
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
    final rn = NegativeResult(
      identifier: errorID,
      message: detail,
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
  required Oration errorMessage,
  required T Function() function,
}) =>
    volatileFactory(
      function: function,
      errorFactory: (p0) => NegativeResult(
        identifier: NegativeResultCodes.invalidFunctionality,
        message: errorMessage,
      ),
    );

Future<T> volatileAsync<T>({
  required Oration detail,
  required FutureOr<T> Function() function,
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
        message: Oration(message: 'Something went wrong while the function was running "%1", the error was: %2', textParts: [detail, ex]),
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
/*
T cautious<T>({
  required Oration reasonFailure,
  required T Function() function,
  NegativeResultCodes codeReasonFailure = NegativeResultCodes.invalidFunctionality,
}) =>
    volatileFactory(
      function: function,
      errorFactory: (x) => NegativeResult(
        identifier: codeReasonFailure,
        message: reasonFailure,
        cause: x,
      ),
    );*/

T programmingFailure<T>({
  required Oration reasonFailure,
  required T Function() function,
}) =>
    volatileFactory(
      function: function,
      errorFactory: (x) => NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: reasonFailure,
        cause: x,
      ),
    );

void checkProgrammingFailure<T>({
  required Oration thatChecks,
  required bool Function() result,
}) {
  final resultFunction = programmingFailure(
    reasonFailure: Oration(message: '%1 fired an error', textParts: [thatChecks]),
    function: result,
  );

  if (!resultFunction) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: Oration(message: 'The checker "%1" tested negative', textParts: [thatChecks]),
    );
  }
}

Future<void> checkProgrammingFailureAsync<T>({
  required Oration thatChecks,
  required FutureOr<bool> Function() result,
}) async {
  final resultFunction = await volatileAsync<bool>(
    detail: Oration(message: '%1 fired an error', textParts: [thatChecks]),
    function: result,
  );

  if (!resultFunction) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: Oration(message: 'The checker "%1" tested negative', textParts: [thatChecks]),
    );
  }
}

void checkValue({
  required Oration errorLabel,
  required bool Function() result,
}) {
  if (!result()) {
    throw NegativeResult(identifier: NegativeResultCodes.invalidValue, message: errorLabel);
  }
}

T volatileProperty<T>({
  required Oration formalName,
  required String propertyName,
  required T Function() function,
  void Function(NegativeResultValue)? ifFails,
  void Function(dynamic)? ifUnknownFails,
  void Function(dynamic)? ifFailsAnyway,
  NegativeResultValue Function(String, dynamic)? errorFactory,
}) {
  try {
    return function();
  } on NegativeResult catch (nr) {
    final rnp = NegativeResultValue.fromNegativeResult(name: propertyName, formalName: formalName, nr: nr);
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
        name: propertyName,
        formalName: formalName,
        message: Oration(message: 'An error occurred while executing the functionality in the property %1, the error was: %2', textParts: [propertyName, ex]),
        cause: ex,
      );
    } else {
      rnp = errorFactory(propertyName.toString(), ex);
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

T makeSeveralAttempts<T>({
  required T Function() function,
  required int attempts,
  void Function(int, dynamic, StackTrace)? onError,
}) {
  int i = 1;
  while (true) {
    try {
      return function();
    } catch (ex, st) {
      if (onError != null) {
        onError(i, ex, st);
      }

      log('[SeveralAttempts, $i/$attempts] $ex\n$st');

      if (i >= attempts) {
        rethrow;
      }

      i += 1;
    }
  }
}

InteractiveFunctionality<I, R> asyncFunctionality<I, R>(
  FutureOr<R> Function(InteractiveFunctionalityExecutor<I, R>) function, {
  void Function()? onCancel,
  void Function(NegativeResult, StackTrace)? onError,
  void Function(R?, NegativeResult?)? onFinish,
}) {
  return RunInteractiveFunctionalityAsFuture<I, R>(
    function: function,
    onCancelFunction: onCancel,
    onErrorFunction: onError,
    onFinishFunction: onFinish,
  );
}

TextableFunctionality<R> asyncTextable<R>(
  FutureOr<R> Function(InteractiveFunctionalityExecutor<Oration, R>) function, {
  void Function()? onCancel,
  void Function(NegativeResult, StackTrace)? onError,
  void Function(R?, NegativeResult?)? onFinish,
}) =>
    asyncFunctionality(function, onCancel: onCancel, onError: onError, onFinish: onFinish);
