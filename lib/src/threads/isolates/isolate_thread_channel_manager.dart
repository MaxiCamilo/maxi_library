import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/iisolate_thread_channel_manager.dart';
import 'package:maxi_library/src/threads/isolates/channels/extern_isolate_channel.dart';
import 'package:maxi_library/src/threads/isolates/channels/local_isolate_channel.dart';
import 'package:maxi_library/src/threads/isolates/ithread_isolador.dart';

class IsolateThreadChannelManager with IIsolateThreadChannelManager {
  final IThreadInvoker thread;

  final _localChannelList = <LocalIsolateChannel>[];
  final _externalChannelList = <ExternIsolateChannel>[];

  int _lastID = 1;
  final _semaphore = Semaphore();

  IsolateThreadChannelManager({required this.thread});

  @override
  Future<void> searchLocalChannel({required int identifier, required FutureOr<void> Function(LocalIsolateChannel) function}) async {
    final item = _localChannelList.selectItem((x) => x.identifier == identifier);

    if (item == null) {
      log('[IsolateThreadChannelManager] ¡Local Isolate Channel N° $identifier does not exists!');
    } else {
      return await function(item);
    }
  }

  @override
  Future<void> searchExternalChannel({required int identifier, required FutureOr<void> Function(ExternIsolateChannel) function}) async {
    final item = _externalChannelList.selectItem((x) => x.identifier == identifier);

    if (item == null) {
      log('[IsolateThreadChannelManager] ¡Local Isolate Channel N° $identifier does not exists!');
    } else {
      return await function(item);
    }
  }

  @override
  Future<void> closeExternalChannel({required int identifier}) {
    return thread.callFunction(parameters: InvocationParameters.only(identifier), function: _closeExternalChannelOnThread);
  }

  static void _closeExternalChannelOnThread(InvocationContext context) {
    final id = context.firts<int>();
    final server = context.sender as IThreadIsolador;

    server.channelsManager.reactcloseExternalChannel(identifier: id);
  }

  @override
  Future<void> closeLocalChannel({required int identifier}) {
    return thread.callFunction(parameters: InvocationParameters.only(identifier), function: _closeLocalChannelOnThread);
  }

  static void _closeLocalChannelOnThread(InvocationContext context) {
    final id = context.firts<int>();
    final server = context.sender as IThreadIsolador;

    server.channelsManager.reactCloseLocalChannel(identifier: id);
  }

  @override
  Future<IChannel<S, R>> createExternalChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) async {
    parameters = InvocationParameters.clone(parameters)..namedParameters['_#FS()#_'] = function;

    final externalID = await thread.callFunction(parameters: parameters, function: _createLocalChannelOnThread<R, S>);
    final newExternChannel = ExternIsolateChannel<S, R>(identifier: externalID, channelManager: this);
    _externalChannelList.add(newExternChannel);

    newExternChannel.done.whenComplete(() => _externalChannelList.remove(newExternChannel));
    return newExternChannel;
  }

  static Future<int> _createLocalChannelOnThread<R, S>(InvocationContext context) {
    final function = context.named<FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel)>('_#FS()#_');
    final server = context.sender as IThreadIsolador;

    return server.channelsManager.createLocalChannel<R, S>(parameters: context, function: function);
  }

  @override
  Future<int> createLocalChannel<R, S>({required InvocationContext parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) {
    return _semaphore.execute(function: () async {
      int newId = _lastID;
      _lastID += 1;

      final newChannel = LocalIsolateChannel<R, S>(identifier: newId, channelManager: this);
      _localChannelList.add(newChannel);
      newChannel.done.whenComplete(() => _localChannelList.remove(newChannel));

      scheduleMicrotask(() async {
        try {
          await continueOtherFutures();
          await function(parameters, newChannel);
        } catch (ex, st) {
          newChannel.addErrorIfActive(ex, st);
          newChannel.close();
        }
      });
/*
      final completer = Completer();

      scheduleMicrotask(() async {
        try {
          await continueOtherFutures();
          await function(parameters, newChannel);
          completer.complete();
        } catch (ex, st) {
          newChannel.addErrorIfActive(ex, st);
          newChannel.close();
          completer.completeError(ex, st);
        }
      });

      await completer.future;*/

      return newId;
    });
  }

  @override
  void receiveExternalValue({required int identifier, value}) {
    searchExternalChannel(
      identifier: identifier,
      function: (x) => x.addFromMaste(value),
    );
  }

  @override
  void receiveLocalValue({required int identifier, value}) {
    searchLocalChannel(
      identifier: identifier,
      function: (x) => x.addFromMaste(value),
    );
  }

  @override
  Future<void> sendExternalValue({required int identifier, value}) {
    return thread.callFunction(parameters: InvocationParameters.list([identifier, value]), function: _sendExternalValueOnThread);
  }

  static FutureOr<void> _sendExternalValueOnThread(InvocationContext context) {
    final id = context.firts<int>();
    final value = context.second();

    final server = context.sender as IThreadIsolador;
    server.channelsManager.receiveExternalValue(identifier: id, value: value);
  }

  @override
  Future<void> sendLocalValue({required int identifier, value}) {
    return thread.callFunction(parameters: InvocationParameters.list([identifier, value]), function: _sendLocalValueOnThread);
  }

  static FutureOr<void> _sendLocalValueOnThread(InvocationContext context) {
    final id = context.firts<int>();
    final value = context.second();

    final server = context.sender as IThreadIsolador;
    server.channelsManager.receiveLocalValue(identifier: id, value: value);
  }

  @override
  Future<void> reactCloseLocalChannel({required int identifier}) async {
    final channel = _localChannelList.selectItem((x) => x.identifier == identifier);
    channel?.reactCloseFromOperator();
  }

  @override
  Future<void> reactcloseExternalChannel({required int identifier}) async {
    final channel = _externalChannelList.selectItem((x) => x.identifier == identifier);
    channel?.reactCloseFromOperator();
  }

  @override
  Future<void> sendExternalError({required int identifier, required Object error, required StackTrace? stackTrace}) {
    return thread.callFunction(parameters: InvocationParameters.list([identifier, error, stackTrace]), function: _sendExternalErrorOnThread);
  }

  static FutureOr<void> _sendExternalErrorOnThread(InvocationContext context) {
    final id = context.firts<int>();
    final error = context.second<Object>();
    final stack = context.third<StackTrace?>();

    final server = context.sender as IThreadIsolador;
    server.channelsManager.receiveExternalError(identifier: id, error: error, stackTrace: stack);
  }

  @override
  void receiveExternalError({required int identifier, required Object error, required StackTrace? stackTrace}) {
    searchExternalChannel(identifier: identifier, function: (x) => x.addErrorFromMaste(error, stackTrace));
  }

  @override
  Future<void> sendLocalError({required int identifier, required Object error, required StackTrace? stackTrace}) {
    return thread.callFunction(parameters: InvocationParameters.list([identifier, error, stackTrace]), function: _sendLocalErrorOnThread);
  }

  static FutureOr<void> _sendLocalErrorOnThread(InvocationContext context) {
    final id = context.firts<int>();
    final error = context.second<Object>();
    final stack = context.third<StackTrace?>();

    final server = context.sender as IThreadIsolador;
    server.channelsManager.receiveLocalError(identifier: id, error: error, stackTrace: stack);
  }

  @override
  void receiveLocalError({required int identifier, required Object error, required StackTrace? stackTrace}) {
    searchLocalChannel(identifier: identifier, function: (x) => x.addErrorFromMaste(error, stackTrace));
  }

  @override
  void closeAll() {
    _localChannelList.iterar((x) => x.reactCloseFromOperator());
    _externalChannelList.iterar((x) => x.reactCloseFromOperator());

    _localChannelList.clear();
    _externalChannelList.clear();
  }
}
