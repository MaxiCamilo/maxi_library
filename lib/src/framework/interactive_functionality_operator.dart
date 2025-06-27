import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin InteractiveFunctionalityOperator<I, R> on IDisposable {
  Stream<I> get itemStream;
  int get identifier;

  void start();
  void cancel();
  MaxiFuture<R> waitResult({void Function(I item)? onItem});

  InteractiveFunctionality<I, R> get asFunctionality => _InteractiveFunctionalityOperatorAsFunctionality<I, R>(mainOperator: this);
/*
  MaxiFuture<R> joinOperator({
    required InteractiveFunctionalityOperator<I, dynamic> other,
    required void Function(I) onItem,
  }) {
   other.onDispose.whenComplete(() => ,);
    return waitResult(onItem: (item) => other.,);
  }*/
}

mixin InteractiveFunctionalityExecutor<I, R> on IDisposable, PaternalFunctionality {
  int get identifier;
  Future<bool> get onCancelOrDone;

  void sendItem(I item);
  void checkActivity();
  Future<void> delayed(Duration time);
  Future<T> waitFuture<T>({required Future<T> future, Duration? timeout, FutureOr<T> Function()? onTimeout});
  Future<void> sendItemAsync(I item) async {
    await continueOtherFutures();
    sendItem(item);
    await continueOtherFutures();
  }

  Future<void> continueOtherFutures() async {
    checkActivity();
    await Future.delayed(Duration.zero);
    checkActivity();
  }

  Future<T> waitFutureFunction<T>({required Future<T> Function() function, Duration? timeout, FutureOr<T> Function()? onTimeout}) {
    final future = function();
    return waitFuture<T>(future: future, onTimeout: onTimeout, timeout: timeout);
  }
}

class _InteractiveFunctionalityOperatorAsFunctionality<I, R> with InteractiveFunctionality<I, R> {
  final InteractiveFunctionalityOperator<I, R> mainOperator;

  const _InteractiveFunctionalityOperatorAsFunctionality({required this.mainOperator});

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    return await mainOperator.waitResult(onItem: manager.sendItem);
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    mainOperator.cancel();
  }
}
