import 'package:maxi_library/src/threads/operators/iexecutor_requested_thread_functions.dart';
import 'package:maxi_library/src/threads/operators/iexecutor_requested_thread_stream.dart';
import 'package:maxi_library/src/threads/operators/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';
import 'package:maxi_library/src/threads/operators/ithread_request_manager.dart';
import 'package:maxi_library/src/threads/operators/ithread_stream_manager.dart';

mixin IThreadCommunication {
  IThreadCommunicationMethod get port;
  IThreadProcess get managerThisTread;

  IExecutorRequestedThreadFunctions get executorRequestFunction;
  IExecutorRequestedThreadStream get executorRequestStream;

  IThreadRequestManager get requestManager;
  IThreadStreamManager get streamManager;

  void reactClosingThread();

  Future<void> closerConnection();
}
