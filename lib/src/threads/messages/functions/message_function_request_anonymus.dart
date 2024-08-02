import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_server.dart';

class MessageFunctionRequestAnonymus<R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<R> Function(InvocationParameters) function;

  const MessageFunctionRequestAnonymus({required this.parameters, required this.function});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) {
    if (context.managerThisThread is IThreadProcessServer) {
      return context.communicator.executorRequestFunction.executeRequestedFunction(parameters: parameters, function: _executeWithServer);
    } else {
      return context.communicator.executorRequestFunction.executeRequestedFunction(parameters: parameters, function: function);
    }
  }

  Future<R> _executeWithServer(InvocationParameters parameters) {
    return ThreadManager.callFunctionAsAnonymous(function: function, parameters: parameters);
  }
}
