import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IChannel<R, S> implements StreamSink<S> {
  bool get isActive;

  Stream<R> get receiver;

  void dispose() => close();

  T checkActivityBefore<T>(T Function() function) {
    if (!isActive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: const Oration(message: 'The channel is closed'),
      );
    }
    return function();
  }

  @override
  Future addStream(Stream<S> stream) async {
    checkActivityBefore(() {});
    final waiter = Completer<void>();

    late final StreamSubscription<S> subscription;
    subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => waiter.complete(),
    );

    final future = done.whenComplete(() => subscription.cancel());

    await waiter.future;
    future.ignore();
  }

  void addIfActive(S event) {
    if (isActive) {
      add(event);
    }
  }

  void addErrorIfActive(Object error, [StackTrace? stackTrace]) {
    if (isActive) {
      addError(error, stackTrace);
    }
  }

  void joinWithOtherChannel({
    required IChannel<S, R> channel,
    required bool closeOtherChannelIfFinished,
    required bool closeThisChannelIfFinish,
  }) {
    channel.receiver.listen(
      (x) => addIfActive(x),
      onError: (x, y) => addErrorIfActive(x, y),
    );

    receiver.listen(
      (x) => channel.addIfActive(x),
      onError: (x, y) => channel.addErrorIfActive(x, y),
    );

    if (closeOtherChannelIfFinished) {
      done.whenComplete(() => channel.close());
    }

    if (closeThisChannelIfFinish) {
      channel.done.whenComplete(() => close());
    }
  }
}

mixin IMasterChannel<R, S> on IChannel<R, S> {
  ISlaveChannel<S, R> createSlave();
  ISlaveChannel<S, R> createSlaveFromBuilder(ISlaveChannel<S, R> Function(IMasterChannel<R, S>) function);

  Future<void> waitForNewConnection({required bool omitIfAlreadyConnection});
  void addFromSlave(R item);
  void addErrorFromSlave(Object error, [StackTrace? stackTrace]);
}

mixin ISlaveChannel<R, S> on IChannel<R, S> {
  void closeMasterChannel();

  void addFromMaste(R item);
  void addErrorFromMaste(Object error, [StackTrace? stackTrace]);
}
