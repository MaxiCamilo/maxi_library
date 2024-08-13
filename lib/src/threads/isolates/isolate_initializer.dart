import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/channel_isolates.dart';
import 'package:maxi_library/src/threads/isolates/thread_communication_method_isolator.dart';

class _IsolateInitializerFinalized {
  final bool isCorrect;
  final dynamic error;

  const _IsolateInitializerFinalized({required this.isCorrect, required this.error});
}

class _IsolateInitializerContext {
  final SendPort sender;
  final List<IThreadInitializer> initializers;

  const _IsolateInitializerContext({required this.sender, required this.initializers});
}

class IsolateInitializer {
  final List<IThreadInitializer> initializers;

  const IsolateInitializer({required this.initializers});

  Future<ChannelIsolates> mountIsolate(String name) async {
    final channel = ChannelIsolates.createInitialChannelManually();
    final completer = Completer<_IsolateInitializerFinalized>();

    Isolate.spawn(_prepareThread, _IsolateInitializerContext(initializers: initializers, sender: channel.serder), debugName: name, errorsAreFatal: false);

    final subscription = channel.dataReceivedNotifier.whereType<_IsolateInitializerFinalized>().listen((x) => completer.complete(x));
    final result = await completer.future;
    subscription.cancel();

    if (!result.isCorrect) {
      throw result.error;
    }

    return channel;
  }

  static Future<void> _prepareThread(_IsolateInitializerContext context) async {
    late final ChannelIsolates channel;

    try {
      channel = ChannelIsolates.createDestinationChannel(sender: context.sender, sendSender: true);
    } catch (_) {
      log('FATAL FAILURE! The thread connector could not be generated');
      _autoCloseIsolate();
      return;
    }

    final port = ThreadCommunicationMethodIsolator(channel: channel);

    try {
      for (final init in context.initializers.toList()) {
        await init.performInitializationInThread(port);
      }

      channel.sendObject(
        _IsolateInitializerFinalized(error: null, isCorrect: true),
      );
    } catch (ex) {
      containErrorLog(
        detail: '[IsolateInitializer] FAILED!: The negative result could not be sent to the other isolator.',
        function: () => channel.sendObject(
          _IsolateInitializerFinalized(error: ex, isCorrect: false),
        ),
      );
      _autoCloseIsolate();
      return;
    }
  }

  static void _autoCloseIsolate() {
    Future.delayed(Duration(milliseconds: 20)).whenComplete(() {
      containErrorLog(
        detail: '[IsolateInitializer] FAILED!: The negative result cannot be sent to the other isolator.',
        function: () => Isolate.exit(),
      );
    });
  }
}
