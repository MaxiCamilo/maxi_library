import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/thread_execute_function.dart';
import 'package:maxi_library/src/threads/messages/thread_execution_finished.dart';

class ThreadFunctionRequester {
  final IThreadManager thread;
  final IThreadInvoker sender;

  final StreamSink<IThreadMessage> senderMessage;

  final _sincronizer = Semaphore();
  final _mapFunctions = <int, (Completer, StackTrace)>{};

  Completer<int>? _waitingId;

  ThreadFunctionRequester({required this.thread, required this.sender, required this.senderMessage});

  Future<R> executeFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext) function}) async {
    final expectant = await _sincronizer.execute(function: () => _executeFunction<R>(function: function, parameters: parameters, stackTrace: StackTrace.current));
    return await expectant.future;
  }

  Future<Completer<R>> _executeFunction<R>({required InvocationParameters parameters, required FutureOr<R> Function(InvocationContext) function, required StackTrace stackTrace}) async {
    _waitingId = MaxiCompleter<int>();
    senderMessage.add(ThreadExecuteFunction<R>(parameters: parameters, function: function));

    final newId = await _waitingId!
            .future /*.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message:'The thread took too long to confirm a feature')),
    )*/
        ;

    final resultExpectant = Completer<R>();
    _mapFunctions[newId] = (resultExpectant, stackTrace);

    return resultExpectant;
  }

  void confirmExecution({required int id}) {
    if (_waitingId == null) {
      log('[ThreadFunctionRequester] Feature confirmation not expected');
      return;
    }

    _waitingId!.complete(id);
    _waitingId = null;
  }

  void processFinished(ThreadExecutionFinished message) {
    final completer = _mapFunctions.remove(message.identifier);
    if (completer == null) {
      log('[ThreadFunctionRequester] Function ${message.identifier} not exists');
      return;
    }

    if (message.isCorrect) {
      try {
        completer.$1.complete(message.result);
      } catch (ex) {
        final newSt = StackTrace.fromString(
            '${message.stackTrace.toString()}\n-------------------------------------- Jump from thread No. ${thread.threadID} ${thread.entityType == null ? '' : '(${thread.entityType.toString()})'} to thread No. ${sender.threadID} ${sender.entityType == null ? '' : '(${sender.entityType.toString()})'} --------------------------------------\n${completer.$2.toString()}');

        log('[ThreadFunctionRequester] Function ${message.identifier} did not accept the result: "$ex"');
        completer.$1.completeErrorIfIncomplete(ex, newSt);
      }
    } else {
      final newSt = StackTrace.fromString(
          '${message.stackTrace.toString()}\n-------------------------------------- Jump from thread No. ${thread.threadID} ${thread.entityType == null ? '' : '(${thread.entityType.toString()})'} to thread No. ${sender.threadID} ${sender.entityType == null ? '' : '(${sender.entityType.toString()})'} --------------------------------------\n${completer.$2.toString()}');
      
      completer.$1.completeErrorIfIncomplete(message.result, newSt);
    }
  }

  void close() {
    for (final item in _mapFunctions.values) {
      item.$1.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: Oration(message: 'The function was cancelled')), item.$2);
    }

    _mapFunctions.clear();
  }
}
