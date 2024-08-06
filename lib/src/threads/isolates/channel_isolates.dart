import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';

class ChannelIsolates {
  final bool isDetination;
  final ReceivePort _receiver;

  SendPort? _serder;

  bool _isFinalized = false;

  final _dataReceivedNotifier = StreamController.broadcast();
  final _finalizationNotifier = StreamController<ChannelIsolates>.broadcast();

  Stream get dataReceivedNotifier => _dataReceivedNotifier.stream;

  Stream<ChannelIsolates> get finalizationNotifier => _finalizationNotifier.stream;

  bool get isActive => !_isFinalized;

  SendPort get serder => _receiver.sendPort;

  ChannelIsolates._({required this.isDetination, required ReceivePort receiver, SendPort? serder}) : _receiver = receiver {
    _serder = serder;

    _receiver.listen(
      _processDataReceived,
      onDone: closeConnection,
    );
  }

  void _checkActivity() {
    if (_serder == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: tr('Its not possible to pass the object to the thread, because the transmission channel was not initialized'),
      );
    }

    if (_isFinalized) {
      throw NegativeResult(
        identifier: NegativeResultCodes.statusFunctionalityInvalid,
        message: tr('Its not possible to pass the object to the thread, because the transmission channel closed'),
      );
    }
  }

  void sendObject(dynamic item) {
    _checkActivity();

    try {
      _serder!.send(item);
    } catch (ex) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: 'Its not possible to pass the object to the thread, because the object has some non-passable value through the channel',
        cause: ex,
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
    return ChannelIsolates._(isDetination: true, receiver: receiver, serder: sender);
  }

  static Future<ChannelIsolates> createInitialChannel({required void Function(SendPort) pointerSender}) async {
    final receiver = ReceivePort();
    final channel = ChannelIsolates._(isDetination: false, receiver: receiver);
    final waiterSender = Completer();

    late final StreamSubscription subscription;
    subscription = channel.dataReceivedNotifier.listen(
      (x) {
        if (!waiterSender.isCompleted) {
          waiterSender.complete(x);
        }
        subscription.cancel();
      },
      onError: (x) {
        if (!waiterSender.isCompleted) {
          waiterSender.completeError(NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: tr('No sender was received from the isolator.')));
        }
        subscription.cancel();
      },
      onDone: () {
        if (!waiterSender.isCompleted) {
          waiterSender.completeError(NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: tr('No sender was received from the isolator.')));
        }
        subscription.cancel();
      },
    );

    scheduleMicrotask(() => pointerSender(receiver.sendPort));

    try {
      final sender = await waiterSender.future;

      if (sender is SendPort) {
        channel._serder = sender;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: trc('It was expected that the isolator would return a "Sendport", but it returned a %1', [sender.runtimeType]),
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
        message: tr('Transmission has already been initialized'),
      );
    }

    _serder = sender;
  }

  void closeConnection() {
    _isFinalized = true;
    _receiver.close();
  }

  void _processDataReceived(message) {
    if (_serder == null) {
      if (message is SendPort) {
        _serder = message;
        return;
      } else {
        log('[ChannelIsolates] DANGER!: The sender was not sent! The channel is not working yet');
      }
    }

    _dataReceivedNotifier.add(message);
  }
}
