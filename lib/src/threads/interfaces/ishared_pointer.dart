import 'dart:async';

import 'package:maxi_library/maxi_library.dart';


mixin ISharedPointer<T> {
  Future<T> getItem();

  Future<R> execute<R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<R> Function(T item, InvocationParameters para) function,
  });

  Stream<R> getStream<R>({
    required FutureOr<Stream<R>> Function(T item, InvocationParameters para) function,
    InvocationParameters parameters = InvocationParameters.emptry,
  });

  InteractiveFunctionality<I, R> executeFunctionality<I, R>({
    required InteractiveFunctionality<I, R> Function(T item, InvocationParameters para) function,
    InvocationParameters parameters = InvocationParameters.emptry,
  });

  
}



