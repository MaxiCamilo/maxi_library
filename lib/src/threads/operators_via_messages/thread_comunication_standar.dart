import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/abilitys/iability_process_messages.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/iexecutor_requested_thread_functions.dart';
import 'package:maxi_library/src/threads/interfaces/iexecutor_requested_thread_stream.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_request_manager.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_stream_manager.dart';
import 'package:maxi_library/src/threads/operators_via_messages/executor_request_thread_function_standar.dart';
import 'package:maxi_library/src/threads/operators_via_messages/executor_request_thread_stream_standar.dart';
import 'package:maxi_library/src/threads/operators_via_messages/thread_request_manager_standar.dart';
import 'package:maxi_library/src/threads/operators_via_messages/thread_stream_manager_standar.dart';

class ThreadComunicationStandar with IThreadCommunication, IAbilityProcessMessages {
  @override
  final IThreadProcess managerThisTread;

  @override
  final IThreadCommunicationMethod port;

  @override
  late final IExecutorRequestedThreadFunctions executorRequestFunction;

  @override
  late final IExecutorRequestedThreadStream executorRequestStream;

  @override
  late final IThreadRequestManager requestManager;

  @override
  late final IThreadStreamManager streamManager;

  ThreadComunicationStandar({required this.managerThisTread, required this.port}) {
    checkProgrammingFailure(thatChecks: () => '[ThreadComunicationStandar] ${tr('The communication port is active')}', result: () => port.isActive);

    executorRequestFunction = ExecutorRequestThreadFunctionMessages(manager: managerThisTread, sender: port.sender);
    executorRequestStream = ExecutorRequestThreadStreamStandar(manager: managerThisTread, sender: port.sender);
    requestManager = ThreadRequestManagerStandar(manager: managerThisTread, sender: port.sender);
    streamManager = ThreadStreamManagerStandar(manager: managerThisTread, sender: port.sender);

    port.receiver.receivedMessage.listen(processMessage);
  }

  @override
  void reactClosingThread() {
    executorRequestFunction.reactClosingThread();
    executorRequestStream.reactClosingThread();
    requestManager.reactClosingThread();
    streamManager.reactClosingThread();
  }

  @override
  Future<void> processMessage(IThreadMessage message) async {
    containErrorLog(
      detail: '[ThreadComunicationStandar] The opening of the "${message.runtimeType}" message did not end correctly',
      function: () async => await message.openMessage(context: ContextProcessThreadMessages(managerThisThread: managerThisTread, communicator: this)),
    );
  }

  @override
  Future<void> closerConnection() async {
    executorRequestFunction.reactClosingThread();
    executorRequestStream.reactClosingThread();
    requestManager.reactClosingThread();
    streamManager.reactClosingThread();

    managerThisTread.reactConnectionClose(this);
    await port.closeCommunication();
  }
}
