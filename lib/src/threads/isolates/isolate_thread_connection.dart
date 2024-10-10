import 'dart:async';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithead_connection.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/connection_closed_message.dart';

class IsolateThreadConnection implements StreamSink, ITheadConnection {
  final ChannelIsolates channel;

  final _messageReceiver = StreamController<IThreadMessage>.broadcast();
  final _notifyConnectionClosure = StreamController<ITheadConnection>.broadcast();
  final _notifyNewSender = StreamController<SendPort>.broadcast();

  final _done = Completer();

  Stream<SendPort> get notifyNewSender => _notifyNewSender.stream;

  bool _isActive = true;

  IsolateThreadConnection({required this.channel}) {
    channel.dataReceivedNotifier.whereType<IThreadMessage>().repeatWithController(repeater: _messageReceiver);
    channel.dataReceivedNotifier.whereType<SendPort>().repeatWithController(repeater: _notifyNewSender);
    channel.finalizationNotifier.listen((_) => defineConnectionClosed());
  }

  @override
  bool get isActive => _isActive;

  @override
  Stream<IThreadMessage> get messageReceiver => _messageReceiver.stream;

  @override
  Stream<ITheadConnection> get notifyConnectionClosure => _notifyConnectionClosure.stream;


  @override
  void defineConnectionClosed() {
    _isActive = false;

    _notifyConnectionClosure.add(this);
    _notifyConnectionClosure.close();
    _messageReceiver.close();
    _notifyConnectionClosure.close();
    _notifyNewSender.close();

    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  @override
  Future<void> sendMessage({required IThreadMessage message}) async {
    channel.sendObject(message);
  }

  @override
  void add(event) {
    channel.sendObject(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    channel.sendObject(error);
  }

  @override
  Future addStream(Stream stream) {
    return stream.waitFinish(reactionItem: (x) => add(x), finished: [done]);
  }

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    await sendMessage(message: const ConnectionClosedMessage());
    defineConnectionClosed();
    channel.closeConnection();
  }

  @override
  Future get done => _done.future;
}
