import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin InteractableFunctionalityOperator<I, R> on IDisposable {
  Stream<I> get itemStream;
  int get identifier;

  void start();
  void cancel();
  MaxiFuture<R> waitResult({void Function(I item)? onItem});
/*
  MaxiFuture<R> joinOperator({
    required InteractableFunctionalityOperator<I, dynamic> other,
    required void Function(I) onItem,
  }) {
   other.onDispose.whenComplete(() => ,);
    return waitResult(onItem: onItem);
  }*/
}

mixin InteractableFunctionalityExecutor<I, R> on IDisposable, PaternalFunctionality {
  int get identifier;
  void sendItem(I item);
  void checkActivity();
  Future<void> delayed(Duration time);
  Future<T> waitFuture<T>({required Future<T> future, Duration? timeout, FutureOr<T> Function()? onTimeout});
  Future<void> sendItemAsync(I item) async {
    await continueOtherFutures();
    checkActivity();
    sendItem(item);
    await continueOtherFutures();
    checkActivity();
  }

  Future<void> checkActivityAsync() async {
    await continueOtherFutures();
    checkActivity();
  }
}
