import 'dart:async';

import 'package:maxi_library/src/threads/ithead_connection.dart';
import 'package:maxi_library/src/threads/ithread_manager.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/connection_closed_message.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_function_in_thread.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/message_execute_function_in_thread.dart';
import 'package:maxi_library/src/threads/messages/messege_execute_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/request_cancellation_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/request_thread_closure.dart';
import 'package:maxi_library/src/threads/messages/stream_message_sending_data.dart';
import 'package:maxi_library/src/threads/messages/task_finished_message.dart';
import 'package:maxi_library/src/threads/messages/task_running_message.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';
import 'package:maxi_library/src/threads/processors/thread_request_requester.dart';

class ThreadMessageProcessors {
  final ThreadRequestExecutor requestExecutor;
  final ThreadRequestRequester requestRequester;
  final ITheadConnection connection;
  final IThreadManager manager;

  late final StreamSubscription<IThreadMessage> _subscription;

  ThreadMessageProcessors({required this.connection, required this.requestExecutor, required this.requestRequester, required this.manager}) {
    _subscription = connection.messageReceiver.listen(_dataReceive);
  }

  void close() {
    _subscription.cancel();
  }

  void _dataReceive(IThreadMessage event) {
    if (event is TaskFinishedMessage) {
      requestRequester.reactFinishedMessage(event);
    } else if (event is StreamMessageSendingData) {
      requestRequester.reactStreamStatus(event);
    } else if (event is TaskRunningMessage) {
      requestRequester.reactConfirmation(event);
    } else if (event is MessageExecuteEntityFunctionInThread) {
      requestExecutor.executeEntityFunction(event);
    } else if (event is MessageExecuteEntityStreamInThread) {
      requestExecutor.executeEntityStream(event);
    } else if (event is MessageExecuteFunctionInThread) {
      requestExecutor.executeFunction(event);
    } else if (event is MessegeExecuteStreamInThread) {
      requestExecutor.executeStream(event);
    } else if (event is RequestCancellationStreamInThread) {
      requestExecutor.cancelStream(event);
    } else if (event is ConnectionClosedMessage) {
      connection.defineConnectionClosed();
    } else if (event is RequestThreadClosure) {
      manager.closeThread();
    }
  }
}
