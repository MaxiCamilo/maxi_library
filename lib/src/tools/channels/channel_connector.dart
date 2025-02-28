import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class ChannelConnector<R, S> with IChannel<R, S> {
  final Stream<R> _streamReceiver;
  final StreamSink<S> _streamSender;

  late final StreamController<R> _streamController;
  late final StreamSubscription<R> _receiverSubscription;

  bool _isActive = true;

  @override
  bool get isActive => _isActive;

  late final Completer _waiterDone;

  ChannelConnector({required Stream<R> receiver, required StreamSink<S> sender})
      : _streamReceiver = receiver,
        _streamSender = sender {
    _streamSender.done.whenComplete(_reactClosedPoint);

    _receiverSubscription = _streamReceiver.listen(
      (x) => _streamController.addIfActive(x),
      onError: (x, y) => _streamController.addErrorIfActive(x, y),
      onDone: _reactClosedPoint,
    );

    _streamController = StreamController<R>.broadcast();
    _waiterDone = Completer();
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
    if (!_isActive) {
      return;
    }

    _reactClosedPoint();
  }

  @override
  Future get done async {
    if (!_isActive) {
      return;
    }

    return await _waiterDone.future;
  }

  void _reactClosedPoint() {
    if (!_isActive) {
      return;
    }

    _isActive = false;

    _receiverSubscription.cancel();
    _streamSender.close();
    _streamController.close();
    _waiterDone.completeIfIncomplete();
  }
}
