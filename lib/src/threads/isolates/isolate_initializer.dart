import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_client.dart';

class _IsolateInitializerFinalized {
  final bool isCorrect;
  final dynamic error;

  const _IsolateInitializerFinalized({required this.isCorrect, required this.error});
}

class _IsolateInitializerContext {
  final int threadID;
  final SendPort sender;
  final List<IThreadInitializer> initializers;

  const _IsolateInitializerContext({required this.sender, required this.initializers, required this.threadID});
}

class IsolateInitializer {
  final List<IThreadInitializer> initializers;

  const IsolateInitializer({required this.initializers});

  Future<ChannelIsolates> mountIsolate({required String name, required int threadID}) async {
    final channel = ChannelIsolates.createInitialChannelManually();
    final completer = Completer<_IsolateInitializerFinalized>();
    scheduleMicrotask(() => Isolate.spawn(_prepareThread, _IsolateInitializerContext(initializers: initializers, sender: channel.serder, threadID: threadID), debugName: name, errorsAreFatal: false));

    final subscription = channel.stream.whereType<_IsolateInitializerFinalized>().listen((x) {
      completer.complete(x);
    });
    final result = await completer.future;
    subscription.cancel();

    if (!result.isCorrect) {
      throw result.error;
    }

    return channel;
  }

  static Future<void> _prepareThread(_IsolateInitializerContext context) async {
    try {
      late final ChannelIsolates channel;

      try {
        channel = ChannelIsolates.createDestinationChannel(sender: context.sender, sendSender: true);
      } catch (_) {
        log('FATAL FAILURE! The thread connector could not be generated');
        _autoCloseIsolate();
        return;
      }

      final newThread = ThreadIsolatorClient(serverChannel: channel, threadID: context.threadID);

      ThreadManager.instance = newThread;

      try {
        for (final init in context.initializers.toList()) {
          await init.performInitializationInThread(newThread);
        }

        channel.add(
          _IsolateInitializerFinalized(error: null, isCorrect: true),
        );
      } catch (ex) {
        containErrorLog(
          detail: tr('[IsolateInitializer] FAILED!: The negative result could not be sent to the other isolator.'),
          function: () => channel.add(
            _IsolateInitializerFinalized(error: ex, isCorrect: false),
          ),
        );
        newThread.closeThread();
        return;
      }
    } catch (ex) {
      log('[IsolateInitializer] Fatal error starting thread: $ex');
      _autoCloseIsolate();
    }
  }

  static void _autoCloseIsolate() {
    Future.delayed(Duration(milliseconds: 20)).whenComplete(() {
      containErrorLog(
        detail: tr('[IsolateInitializer] FAILED!: The negative result cannot be sent to the other isolator.'),
        function: () => Isolate.exit(),
      );
    });
  }
}
