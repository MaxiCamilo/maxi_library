import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class RunInteractiveFunctionalityAsFuture<I, R> with InteractiveFunctionality<I, R> {
  final FutureOr<R> Function(InteractiveFunctionalityExecutor<I, R> manager) function;
  final void Function()? onCancelFunction;
  final void Function(R? possibleResult, NegativeResult? possibleError)? onFinishFunction;
  final void Function(NegativeResult error, StackTrace stackTrace)? onErrorFunction;

  const RunInteractiveFunctionalityAsFuture({
    required this.function,
    this.onCancelFunction,
    this.onErrorFunction,
    this.onFinishFunction,
  });

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    return await function(manager);
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);

    if (onCancelFunction != null) {
      onCancelFunction!();
    }
  }

  @override
  void onError({required InteractiveFunctionalityExecutor<I, R> manager, required NegativeResult error, required StackTrace stackTrace}) {
    super.onError(manager: manager, error: error, stackTrace: stackTrace);
    if (onErrorFunction != null) {
      onErrorFunction!(error, stackTrace);
    }
  }

  @override
  void onFinish({required InteractiveFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {
    super.onFinish(manager: manager, possibleResult: possibleResult, possibleError: possibleError);

    if (onFinishFunction != null) {
      onFinishFunction!(possibleResult, possibleError);
    }
  }
}
