import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/messege_execute_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/stream_message_sending_data.dart';
import 'package:maxi_library/src/threads/messages/task_running_message.dart';
import 'package:maxi_library/src/threads/processors/thread_request_executor.dart';

class ThreadStreamInstance<T> {
  final ThreadRequestExecutor executor;
  final InvocationParameters parameters;
  final Future<Stream<T>> Function(InvocationContext) function;
  final int taskId;
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  ThreadStreamInstance._({
    required this.executor,
    required this.parameters,
    required this.function,
    required this.taskId,
    required this.cancelOnError,
  });

  factory ThreadStreamInstance.fromAnonymous({required ThreadRequestExecutor executor, required MessegeExecuteStreamInThread<T> message}) {
    return ThreadStreamInstance._(
      executor: executor,
      parameters: message.parameters,
      function: message.function,
      taskId: message.taskId,
      cancelOnError: message.cancelOnError,
    );
  }

  static ThreadStreamInstance<R> fromEntity<E, R>({required ThreadRequestExecutor executor, required MessageExecuteEntityStreamInThread<E, R> message}) {
    return ThreadStreamInstance._(
      executor: executor,
      parameters: message.parameters,
      function: (_) => _getEntityFirst(executor: executor, message: message),
      taskId: message.taskId,
      cancelOnError: message.cancelOnError,
    );
  }

  static Future<Stream<R>> _getEntityFirst<E, R>({required ThreadRequestExecutor executor, required MessageExecuteEntityStreamInThread<E, R> message}) {
    final entity = executor.manager.entity;
    if (entity == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The function requires that the thread be assigned an entity of type %1, but there is no entity assigned', [E]),
      );
    }

    if (entity is E) {
      return message.function(entity, InvocationContext.fromParametes(thread: executor.manager, parametres: message.parameters));
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: tr('The function requires that the thread be assigned an entity of type %1, but the thread entity is of type %2', [E, entity.runtimeType]),
      );
    }
  }

  void execute() {
    executor.activeStreams.add(this);
    executor.messageOutput.add(TaskRunningMessage(taskId: taskId));
    scheduleMicrotask(() {
      _mountStream().onError((x, trace) {
        _errorReceived(x, trace);
        _streamFinished();
      });
    });
  }

  void cancel() {
    _subscription?.cancel();
    _streamFinished();
  }

  Future<void> _mountStream() async {
    final stream = await function(InvocationContext.fromParametes(thread: executor.manager, parametres: parameters));
    _subscription = stream.listen(
      _dataReceived,
      cancelOnError: cancelOnError,
      onError: _errorReceived,
      onDone: _streamFinished,
    );
  }

  void _dataReceived(T event) {
    executor.messageOutput.add(StreamMessageSendingData(
      taskId: taskId,
      content: event,
      type: StreamMessageSendingDataType.newData,
    ));
  }

  void _errorReceived(dynamic error, StackTrace trace) {
    executor.messageOutput.add(StreamMessageSendingData(
      taskId: taskId,
      content: error,
      type: StreamMessageSendingDataType.errorData,
      trace: trace,
    ));
  }

  void _streamFinished() {
    executor.messageOutput.add(StreamMessageSendingData(
      taskId: taskId,
      content: null,
      type: StreamMessageSendingDataType.finished,
    ));
    executor.activeStreams.remove(this);
  }
}
