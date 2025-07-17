import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/iisolate_thread_channel_manager.dart';

class ExternIsolateChannel<R, S> with IDisposable, IChannel<R, S>, ISlaveChannel<R, S> {
  final int identifier;
  final IIsolateThreadChannelManager channelManager;

  final _streamController = StreamController<R>.broadcast();

  @override
  bool get isActive => !wasDiscarded;

  @override
  Stream<R> get receiver => checkActivityBefore(() => _streamController.stream);

  ExternIsolateChannel({required this.identifier, required this.channelManager});

  @override
  void add(S event) {
    checkActivityBefore(() {});

    channelManager.sendLocalValue(identifier: identifier, value: event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkActivityBefore(() {});

    channelManager.sendLocalError(identifier: identifier, error: error, stackTrace: stackTrace);
  }

  @override
  void addErrorFromMaste(Object error, [StackTrace? stackTrace]) {
    _streamController.addErrorIfActive(error, stackTrace);
  }

  @override
  void addFromMaste(dynamic item) {
    if (item is R) {
      _streamController.addIfActive(item);
    } else {
      log('[ExternIsolateChannel] Value received is ${item.runtimeType}, but $R was expected');
    }
  }

  @override
  void closeMasterChannel() {
    close();
  }

  @override
  Future close() async {
    dispose();
  }

  @override
  Future get done => onDispose;

  @override
  void performObjectDiscard() {
    _streamController.close();
    channelManager.closeLocalChannel(identifier: identifier);
  }
}
