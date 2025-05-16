import 'dart:async';

mixin IExecutionStatesManagerPoint<T> {
  bool isThisPoint(T item);
  FutureOr<void> declareActive(T newValue);
  FutureOr<void> declareInactive();
}
