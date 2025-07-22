import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tasks/internal/task_invoker_in_stream_instance.dart';
import 'package:meta/meta.dart';

class TaskInvokerInStream with IDisposable, PaternalFunctionality {
  final StreamSink sender;
  final Stream receiver;
  final Duration confirmationDeadline;

  final _newTaskSynchronizer = Semaphore();

  @protected
  Stream<(int, Oration)> get orationStream => _orationController.stream;
  @protected
  Stream<(int, NegativeResult)> get errorStream => _errorController.stream;
  @protected
  Stream<(int, String, dynamic)> get resultStream => _resultController.stream;

  late final StreamController<(int, Oration)> _orationController;
  late final StreamController<(int, NegativeResult)> _errorController;
  late final StreamController<(int, String, dynamic)> _resultController;

  Completer<int>? _newTaskID;

  TaskInvokerInStream({
    required this.sender,
    required this.receiver,
    this.confirmationDeadline = const Duration(seconds: 7),
  }) {
    sender.done.whenComplete(dispose);
    receiver.listen(_processPackage, onDone: dispose);

    _orationController = createEventController<(int, Oration)>(isBroadcast: true);
    _errorController = createEventController<(int, NegativeResult)>(isBroadcast: true);
    _resultController = createEventController<(int, String, dynamic)>(isBroadcast: true);
  }

  static bool isInvokerEvent(String type) => const ['text', 'newTask', 'result', 'error'].contains(type);

  TextableFunctionality<T> makeTask<T>({
    required Object content,
    Duration? confirmationDeadline,
    Duration? resultDeadline,
  }) =>
      TaskInvokerInStreamInstance<T>(
        mainOperator: this,
        confirmationDeadline: confirmationDeadline ?? this.confirmationDeadline,
        resultDeadline: resultDeadline,
        content: content,
      );

  void _processPackage(event) {
    if (event is Map<String, dynamic>) {
      _processPackageMap(event);
    } else if (event is String && event.first == '{' && event.last == '}') {
      _processPackageMap(ConverterUtilities.interpretToObjectJson(text: event));
    } else {
      log('[TaskInvokerInStream] Unknown data received on the stream');
    }
  }

  void _processPackageMap(Map<String, dynamic> package) {
    final type = package.getRequiredValueWithSpecificType<String>('\$type');
    final id = package.getRequiredValueWithSpecificType<int>('id');

    if (type == 'newTask') {
      if (_newTaskID == null || _newTaskID!.isCompleted) {
        log('[TaskInvokerInStream] The confirmation of a task was not expected');
        return;
      } else {
        _newTaskID?.completeIfIncomplete(id);
        _newTaskID = null;
        return;
      }
    } else if (type == 'text') {
      final text = Oration.interpretFromJson(text: package.getRequiredValue('content'));
      _orationController.add((id, text));
    } else if (type == 'result') {
      final result = package.getRequiredValue('content');
      final contentType = package.getRequiredValueWithSpecificType<String>('contentType');
      _resultController.add((id, contentType, result));
    } else if (type == 'error') {
      final rawError = package.getRequiredValue('content');
      late final NegativeResult error;

      if (rawError is Map<String, dynamic>) {
        error = NegativeResult.interpret(values: rawError, checkTypeFlag: true);
      } else {
        error = NegativeResult.interpretJson(jsonText: rawError.toString());
      }

      _errorController.add((id, error));
    } else {
      log('[TaskInvokerInStream] Command $type Unknown');
    }
  }

  @protected
  Future<int> sendTask({
    required dynamic content,
    required Duration timeout,
  }) {
    checkIfDispose();
    return _newTaskSynchronizer.execute(function: () async {
      sender.add(content);

      _newTaskID = joinWaiter<int>();
      final timer = createTimer(
        duration: timeout,
        callback: () {
          _newTaskID?.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.timeout, message: const Oration(message: 'The server took too long to confirm the task')));
        },
      );

      try {
        return await _newTaskID!.future;
      } finally {
        timer.cancel();
      }
    });
  }
}
