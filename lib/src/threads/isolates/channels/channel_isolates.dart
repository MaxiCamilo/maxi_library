import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';

class ChannelIsolates with IChannel {
  final bool isDetination;
  final ReceivePort _receiver;

  final _completerDone = MaxiCompleter<ChannelIsolates>();
  final _completerInitilizer = MaxiCompleter<ChannelIsolates>();

  SendPort? _serder;

  bool _isFinalized = false;

  final _dataReceivedNotifier = StreamController.broadcast();

  @override
  Stream get receiver => _dataReceivedNotifier.stream;

  @override
  bool get isActive => !_isFinalized;

  SendPort get serder => _receiver.sendPort;

  Future<ChannelIsolates> get wasInitialized => _completerInitilizer.future;

  ChannelIsolates._({required this.isDetination, required ReceivePort receiver, SendPort? serder}) : _receiver = receiver {
    _serder = serder;

    _receiver.listen(
      _processDataReceived,
      onDone: () => close(),
    );
  }

  void _checkActivity() {
    if (_serder == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'Its not possible to pass the object to the thread, because the transmission channel was not initialized'),
      );
    }

    if (_isFinalized) {
      throw NegativeResult(
        identifier: NegativeResultCodes.statusFunctionalityInvalid,
        message: Oration(message: 'Its not possible to pass the object to the thread, because the transmission channel closed'),
      );
    }
  }

  factory ChannelIsolates.createInitialChannelManually() {
    return ChannelIsolates._(isDetination: false, receiver: ReceivePort());
  }

  factory ChannelIsolates.createDestinationChannel({
    required SendPort sender,
    required bool sendSender,
  }) {
    final receiver = ReceivePort();
    if (sendSender) {
      sender.send(receiver.sendPort);
    }
    final channel = ChannelIsolates._(isDetination: true, receiver: receiver, serder: sender);

    channel._completerInitilizer.completeIfIncomplete(channel);

    return channel;
  }

  static Future<ChannelIsolates> createInitialChannel({required void Function(SendPort) pointerSender}) async {
    final receiver = ReceivePort();
    final channel = ChannelIsolates._(isDetination: false, receiver: receiver);
    final waiterSender = MaxiCompleter();

    late final StreamSubscription subscription;
    subscription = channel.receiver.listen(
      (x) {
        if (!waiterSender.isCompleted) {
          waiterSender.complete(x);
        }
        subscription.cancel();
      },
      onError: (x) {
        if (!waiterSender.isCompleted) {
          waiterSender.completeError(NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'No sender was received from the isolator.')));
        }
        subscription.cancel();
      },
      onDone: () {
        if (!waiterSender.isCompleted) {
          waiterSender.completeError(NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'No sender was received from the isolator.')));
        }
        subscription.cancel();
      },
    );

    maxiScheduleMicrotask(() => pointerSender(receiver.sendPort));

    try {
      final sender = await waiterSender.future;

      if (sender is SendPort) {
        channel._serder = sender;
        channel._completerInitilizer.completeIfIncomplete(channel);
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: Oration(message: 'It was expected that the isolator would return a "Sendport", but it returned a %1', textParts: [sender.runtimeType]),
        );
      }
    } catch (_) {
      receiver.close();
      rethrow;
    }

    return channel;
  }

  void defineSender(SendPort sender) {
    if (_serder != null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'Transmission has already been initialized'),
      );
    }

    _serder = sender;
  }

  void _processDataReceived(message) {
    if (_serder == null) {
      if (message is SendPort) {
        _serder = message;
        _completerInitilizer.completeIfIncomplete(this);
        return;
      } else {
        log('[ChannelIsolates] DANGER!: The sender was not sent! The channel is not working yet');
      }
    }

    _dataReceivedNotifier.add(message);
  }

  @override
  Future<ChannelIsolates> get done => _completerDone.future;

  @override
  void add(item) {
    _checkActivity();

    try {
      _serder!.send(item);
    } catch (ex) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'Its not possible to pass the object to the thread, because the object has some non-passable value through the channel'),
        cause: ex,
      );
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    final rn = NegativeResult.searchNegativity(item: error, actionDescription: Oration(message: 'wire current'));
    add(rn);
  }

  @override
  Future close() async {
    if (_isFinalized) {
      return;
    }

    _isFinalized = true;
    _receiver.close();
    _completerDone.completeIfIncomplete(this);
  }

  @override
  Future addStream(Stream stream) async {
    if (!isActive) {
      log('[ChannelIsolates] The pipe is closed');
      return;
    }

    final compelteter = MaxiCompleter();

    final subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => compelteter.completeIfIncomplete(),
    );

    final future = done.whenComplete(() => compelteter.completeIfIncomplete());

    await compelteter.future;

    subscription.cancel();
    future.ignore();
  }
}
