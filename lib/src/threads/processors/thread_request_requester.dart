import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_message.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_function_in_thread.dart';
import 'package:maxi_library/src/threads/messages/message_execute_entity_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/message_execute_function_in_thread.dart';
import 'package:maxi_library/src/threads/messages/messege_execute_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/request_cancellation_stream_in_thread.dart';
import 'package:maxi_library/src/threads/messages/stream_message_sending_data.dart';
import 'package:maxi_library/src/threads/messages/task_finished_message.dart';
import 'package:maxi_library/src/threads/messages/task_running_message.dart';

class ThreadRequestRequester {
  final StreamSink messageOutput;

  final _senderSemaphore = Semaphore();

  int _lastId = 1;
  int _waitingId = 0;
  Completer? _waitingIdConfirmation;

  final _functionsWaitingForResponse = <int, Completer>{};
  final _activeStreams = <int, StreamController>{};

  ThreadRequestRequester({required this.messageOutput});

  int _getLastId() {
    final id = _lastId;
    _lastId += 1;
    return id;
  }

  Future<void> _waitingConfirmation({required int id, required IThreadMessage message}) => _senderSemaphore.execute(function: () async {
        _waitingId = id;

        messageOutput.add(message);
        _waitingIdConfirmation = Completer();
        await _waitingIdConfirmation!.future;
      });

  Future<R> callFunctionAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext) function}) async {
    final id = _getLastId();
    final message = MessageExecuteFunctionInThread<R>(function: function, parameters: parameters, taskId: id);
    await _waitingConfirmation(id: id, message: message);

    final completer = Completer<R>();
    _functionsWaitingForResponse[id] = completer;

    return completer.future;
  }

  Future<R> callEntityFunction<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(T, InvocationContext) function}) async {
    final id = _getLastId();
    final message = MessageExecuteEntityFunctionInThread<T, R>(function: function, parameters: parameters, taskId: id);
    await _waitingConfirmation(id: id, message: message);

    final completer = Completer<R>();
    _functionsWaitingForResponse[id] = completer;

    return completer.future;
  }

  Future<Stream<R>> callStreamAsAnonymous<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(InvocationContext) function, bool cancelOnError = false}) async {
    final id = _getLastId();
    final message = MessegeExecuteStreamInThread<R>(function: function, parameters: parameters, taskId: id, cancelOnError: cancelOnError);
    await _waitingConfirmation(id: id, message: message);

    final controller = StreamController<R>();

    controller.onCancel = () => _reactCancelStream(id: id, controller: controller);

    _activeStreams[id] = controller;

    return controller.stream;
  }

  FutureOr<void> _reactCancelStream({required int id, required StreamController controller}) async {
    if (!_activeStreams.containsKey(id)) {
      return;
    }

    messageOutput.add(RequestCancellationStreamInThread(streamId: id));

    controller.close();
    _functionsWaitingForResponse.remove(id);
  }

  Future<Stream<R>> callEntityStream<T, R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<Stream<R>> Function(T, InvocationContext) function, bool cancelOnError = false}) async {
    final id = _getLastId();
    final message = MessageExecuteEntityStreamInThread<T, R>(
      function: function,
      parameters: parameters,
      taskId: id,
      cancelOnError: cancelOnError,
    );
    await _waitingConfirmation(id: id, message: message);

    final controller = StreamController<R>();
    _activeStreams[id] = controller;

    controller.onCancel = () => _reactCancelStream(id: id, controller: controller);

    return controller.stream;
  }

  void reactConfirmation(TaskRunningMessage message) {
    if (_waitingIdConfirmation == null) {
      log('[ThreadRequestRequester] Task number ${message.taskId} was confirmed, but no confirmation was expectedd!');
      return;
    }

    if (message.taskId != _waitingId) {
      log('[ThreadRequestRequester] Task number ${message.taskId} was confirmed, but confirmation of $_waitingId was expected!');
      return;
    }

    _waitingIdConfirmation!.complete();
    _waitingIdConfirmation = null;
  }

  void reactFinishedMessage(TaskFinishedMessage message) {
    final function = _functionsWaitingForResponse.remove(message.taskId);
    if (function == null) {
      log('[ThreadRequestRequester] Completion of task number ${message.taskId} was not expected');
      return;
    }

    if (message.isFailed) {
      function.completeError(message.result, message.trace);
    } else {
      try {
        function.complete(message.result);
      } catch (ex) {
        log('[ThreadRequestRequester] Task number ${message.taskId} did not accept result of type ${message.result.runtimeType}');
        function.completeError(ex);
      }
    }
  }

  void reactStreamStatus(StreamMessageSendingData message) {
    final stream = _activeStreams[message.taskId];
    if (stream == null) {
      log('[ThreadRequestRequester] Stream number ${message.taskId} was not active');
      return;
    }

    switch (message.type) {
      case StreamMessageSendingDataType.newData:
        try {
          stream.add(message.content);
        } catch (ex) {
          log('Stream number ${message.taskId} did not accept item of type ${message.content.runtimeType}');
        }
        break;
      case StreamMessageSendingDataType.errorData:
        stream.addError(message.content, message.trace);
        break;
      case StreamMessageSendingDataType.finished:
        _activeStreams.remove(message.taskId);
        stream.close();

        break;
    }
  }

  void close() {
    _functionsWaitingForResponse.entries.iterar((x) {
      x.value.completeError(
        NegativeResult(
          identifier: NegativeResultCodes.functionalityCancelled,
          message: tr('The connection to the thread was closed'),
        ),
      );
    });
    _functionsWaitingForResponse.clear();

    _activeStreams.entries.iterar((x) {
      x.value.close();
    });
    _activeStreams.clear();
  }
}
