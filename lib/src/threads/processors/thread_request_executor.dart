import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_function_in_thread.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/message_execute_function_in_thread.dart';
import 'package:maxi_library/src/threads/messages/messege_execute_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/request_cancellation_stream_in_thread.dart';
import 'package:maxi_library/src/threads/processors/thread_stream_instance.dart';

class ThreadRequestExecutor {
  final StreamSink messageOutput;
  final IThreadManager manager;

  final List<IThreadMessage> activeTasks = [];
  final List<ThreadStreamInstance> activeStreams = [];

  ThreadRequestExecutor({required this.messageOutput, required this.manager});

  void executeFunction(MessageExecuteFunctionInThread message) {
    message.execute(executor: this);
  }

  void executeEntityFunction(MessageExecuteEntityFunctionInThread message) {
    message.execute(executor: this);
  }

  void executeStream(MessegeExecuteStreamInThread message) {
    message.createInstance(executor: this).execute();
  }

  void executeEntityStream(MessageExecuteEntityStreamInThread message) {
    message.createInstance(executor: this).execute();
  }

  void cancelStream(RequestCancellationStreamInThread message) {
    final stream = activeStreams.selectItem((x) => x.taskId == message.streamId);
    if (stream == null) {
      log('[ThreadRequestExecutor] A stream with identifier ${message.streamId} does not exist');
      return;
    }
    activeStreams.remove(stream);
    stream.cancel();
  }

  void close() {
    activeStreams.iterar((x) => x.cancel());
  }
}
