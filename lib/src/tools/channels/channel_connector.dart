import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class ChannelConnector<R, S> with IDisposable, IChannel<R, S> {
  final Stream<R> _streamReceiver;
  final StreamSink<S> _streamSender;

  late final StreamController<R> _streamController;
  late final StreamSubscription<R> _receiverSubscription;

  @override
  bool get isActive => !wasDiscarded;

  ChannelConnector({required Stream<R> receiver, required StreamSink<S> sender})
      : _streamReceiver = receiver,
        _streamSender = sender {
    _streamSender.done.whenComplete(dispose);

    _receiverSubscription = _streamReceiver.listen(
      (x) => _streamController.addIfActive(x),
      onError: (x, y) => _streamController.addErrorIfActive(x, y),
      onDone: dispose,
    );

    _streamController = StreamController<R>.broadcast();
  }

  factory ChannelConnector.fromOtherChannel(IChannel<R, S> channel) => ChannelConnector(receiver: channel.receiver, sender: channel);

  @override
  Stream<R> get receiver => checkActivityBefore(
        () => _streamController.stream,
      );

  @override
  void add(S event) {
    checkActivityBefore(() => _streamSender.add(event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkActivityBefore(() => _streamSender.addError(error, stackTrace));
  }

  @override
  Future close() async {
    dispose();
  }

  @override
  void performObjectDiscard() {
    _receiverSubscription.cancel();
    _streamSender.close();
    _streamController.close();
  }

  @override
  Future get done => onDispose;
}
