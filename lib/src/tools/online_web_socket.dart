import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OnlineWebSocket with IDisposable, IChannel {
  final Uri url;
  final WebSocketChannel channel;
  final bool disableIfNoOneListens;
  int _numberOfClients = 0;
  final _streamController = StreamController.broadcast();

  @override
  bool get isActive => !wasDiscarded;

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
      channel.sink.add(ReflectionManager.getReflectionEntity(event.runtimeType).serializeToJson(value: event, setTypeValue: true));
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (!isActive) {
      return;
    }

    final rn = NegativeResult.searchNegativity(item: error, actionDescription: Oration(message: 'Server error'));
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
    dispose();
  }

  @override
  Future get done => onDispose;

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
  Stream get receiver {
    checkProgrammingFailure(thatChecks: Oration(message: 'Pipe is active'), result: () => isActive);
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

  @override
  void performObjectDiscard() {
    _streamController.close();
    containErrorLogAsync(detail: const Oration(message: 'Dispose Channel sink'), function: () => channel.sink.close());
  }
}
