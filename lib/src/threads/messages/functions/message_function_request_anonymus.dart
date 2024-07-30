import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class MessageFunctionRequestAnonymus<R> with IThreadMessage {
  final InvocationParameters parameters;
  final Future<R> Function(InvocationParameters) function;

  const MessageFunctionRequestAnonymus({required this.parameters, required this.function});

  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) {
    return context.communicator.executorRequestFunction.executeRequestedFunction(parameters: parameters, function: function);
  }
}
