import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OnlineWebSocket with IPipe {
  final Uri url;
  final WebSocketChannel channel;
  final bool disableIfNoOneListens;

  bool _isActive = true;

  int _numberOfClients = 0;

  final _streamController = StreamController.broadcast();
  final _waiter = Completer();

  @override
  bool get isActive => _isActive;

  static Future<OnlineWebSocket> connect({
    required Uri url,
    required bool disableIfNoOneListens,
    required Duration timeout,
  }) async {
    final wsUrl = url;
    final channel = WebSocketChannel.connect(wsUrl);
    await channel.ready;

    return OnlineWebSocket._(url: url, channel: channel, disableIfNoOneListens: disableIfNoOneListens);
  }

  OnlineWebSocket._({required this.url, required this.channel, required this.disableIfNoOneListens}) {
    channel.stream.listen(_reactDataReceive, onError: _reactErrorReceive, onDone: _reactClosedChannel);
  }

  @override
  void add(event) {
    if (!isActive) {
      return;
    }

    if (event is String) {
      channel.sink.add(event);
    } else if (event is List<int>) {
      channel.sink.add(event);
    } else if (event is List) {
      channel.sink.add(ReflectionManager.serializeListToJson(value: event, setTypeValue: true));
    } else {
      channel.sink.add(ReflectionManager.getReflectionEntity(event.runtimeType).serializeToJson(value: event));
    }

    
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (!isActive) {
      return;
    }

    final rn = NegativeResult.searchNegativity(item: error, actionDescription: tr('Server error'));
    channel.sink.add(rn.serializeToJson());
  }

  @override
  Future addStream(Stream stream) async {
    if (!isActive) {
      return;
    }
    await for (final item in stream) {
      if (!isActive) {
        break;
      }

      add(item);
    }
  }

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;

    _streamController.close();
    _waiter.completeIfIncomplete();
    await channel.sink.close();
  }

  @override
  Future get done => _waiter.future;

  void _reactDataReceive(event) {
    _streamController.add(event);
  }

  void _reactErrorReceive(error, StackTrace trace) {
    _streamController.addError(error, trace);
  }

  void _reactClosedChannel() {
    close();
  }

  @override
  Stream get stream {
    checkProgrammingFailure(thatChecks: tr('Pipe is active'), result: () => isActive);
    _numberOfClients += 1;

    if (disableIfNoOneListens) {
      return _streamController.stream.doOnCancel(_checkIfThereAreClients);
    } else {
      return _streamController.stream;
    }
  }

  void _checkIfThereAreClients() {
    _numberOfClients -= 1;
    if (_numberOfClients <= 0) {
      close();
    }
  }
}
