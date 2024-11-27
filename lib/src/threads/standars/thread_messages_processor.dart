import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/thread_execute_function.dart';
import 'package:maxi_library/src/threads/messages/thread_execution_confirmation.dart';
import 'package:maxi_library/src/threads/messages/thread_execution_finished.dart';
import 'package:maxi_library/src/threads/standars/thread_function_requester.dart';
import 'package:maxi_library/src/threads/standars/thread_message_executor.dart';

class ThreadMessagesProcessor {
  final IThreadManager thread;
  final IThreadInvoker sender;

  final Stream<IThreadMessage> streamMessage;

  final ThreadFunctionRequester requester;
  final ThreadMessageExecutor executor;

  late final StreamSubscription<IThreadMessage> subscription;

  ThreadMessagesProcessor({
    required this.thread,
    required this.sender,
    required this.streamMessage,
    required this.executor,
    required this.requester,
  }) {
    subscription = streamMessage.listen(_reactNewMessage, onDone: close);
  }

  void close() {
    subscription.cancel();
    executor.close();
    requester.close();
  }

  void _reactNewMessage(IThreadMessage event) {
    if (event is ThreadExecuteFunction) {
      executor.executeExternalFunction(event);
    } else if (event is ThreadExecutionConfirmation) {
      requester.confirmExecution(id: event.newId);
    } else if (event is ThreadExecutionFinished) {
      requester.processFinished(event);
    } else {
      log('[ThreadMessagesProcessor] An unknown object was received (message must be run)');
    }
  }
}
