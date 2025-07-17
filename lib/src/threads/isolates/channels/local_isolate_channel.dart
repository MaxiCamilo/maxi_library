import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/iisolate_thread_channel_manager.dart';

class LocalIsolateChannel<R, S> with IDisposable, IChannel<R, S>, ISlaveChannel<R, S> {
  final int identifier;
  final IIsolateThreadChannelManager channelManager;

  final _streamController = StreamController<R>.broadcast();

  LocalIsolateChannel({required this.identifier, required this.channelManager});

  @override
  bool get isActive => !wasDiscarded;

  @override
  Stream<R> get receiver => checkActivityBefore(() => _streamController.stream);

  @override
  void add(S event) {
    checkActivityBefore(() {});

    channelManager.sendExternalValue(identifier: identifier, value: event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkActivityBefore(() {});

    channelManager.sendExternalError(identifier: identifier, error: error, stackTrace: stackTrace);
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
      log('[LocalIsolateChannel] Value received is ${item.runtimeType}, but $R was expected');
    }
  }

  @override
  void closeMasterChannel() {
    close();
  }

  @override
  Future get done => onDispose;

  @override
  Future close() async {
    dispose();
  }

  @override
  void performObjectDiscard() {
    _streamController.close();
    channelManager.closeExternalChannel(identifier: identifier);
  }
}
