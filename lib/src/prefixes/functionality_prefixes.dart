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
  required TranslatableText detail,
  required T Function() function,
  void Function(TranslatableText, NegativeResult)? ifFails,
  void Function(TranslatableText, dynamic)? ifUnknownFails,
}) {
  return containError(
    function: function,
    ifFails: (x) {
      log(tr('[X] Negative response was contained in "%1": %2', [detail, x]).toString());
      if (ifFails != null) {
        ifFails(detail, x);
      }
    },
    ifUnknownFails: (x) {
      log(tr('[¡X!] Failure contained in: "%1": %2', [detail, x]).toString());

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
  required TranslatableText detail,
  required Future<T> Function() function,
}) {
  return containErrorAsync(
    function: function,
    ifFails: (x) => log(tr('[X] Negative response contained in "%1": "%2"', [detail, x]).toString()),
    ifUnknownFails: (x) => log(tr('[¡X!] Failure contained in "%1": "%2"', [detail, x]).toString()),
  );
}

T addToErrorDescription<T>({
  required TranslatableText additionalDetails,
  required T Function() function,
  bool before = true,
  NegativeResultCodes ifIsUnknownError = NegativeResultCodes.implementationFailure,
}) {
  try {
    return function();
  } on NegativeResult catch (nr) {
    nr.message = tr('%1%2', before ? [additionalDetails, nr.message] : [nr.message, additionalDetails]);

    //before ? '${additionalDetails.toString()}${nr.message.toString()}' : '${nr.message.toString()}${additionalDetails.toString()}';
    rethrow;
  } catch (ex) {
    throw NegativeResult(
      identifier: ifIsUnknownError,
      message: tr('%1: "%2"', [additionalDetails, ex]),
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
  required TranslatableText detail,
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
      message: tr('An error occurred while executing the functionality "%1", the error was: %2', [detail, ex]),
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
  required TranslatableText errorMessage,
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
  required TranslatableText detail,
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
        message: tr('Something went wrong while the function was running "%1", the error was: %2', [detail, ex]),
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
  required TranslatableText reasonFailure,
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
    );

T programmingFailure<T>({
  required TranslatableText reasonFailure,
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
  required TranslatableText thatChecks,
  required bool Function() result,
}) {
  final resultFunction = programmingFailure(
    reasonFailure: tr('%1 fired an error', [thatChecks]),
    function: result,
  );

  if (!resultFunction) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: tr('The checker "%1" tested negative', [thatChecks]),
    );
  }
}

T volatileProperty<T>({
  required TranslatableText propertyName,
  required T Function() function,
  void Function(NegativeResultValue)? ifFails,
  void Function(dynamic)? ifUnknownFails,
  void Function(dynamic)? ifFailsAnyway,
  NegativeResultValue Function(String, dynamic)? errorFactory,
}) {
  try {
    return function();
  } on NegativeResult catch (nr) {
    final rnp = NegativeResultValue.fromNegativeResult(name: propertyName, nr: nr);
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
        message: tr('An error occurred while executing the functionality in the property %1, the error was: %2', [propertyName, ex]),
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
