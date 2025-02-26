import 'dart:async';

mixin Ichannel<R, S> implements StreamSink<S> {
  bool get isActive;

  Stream<R> get receiver;
}
