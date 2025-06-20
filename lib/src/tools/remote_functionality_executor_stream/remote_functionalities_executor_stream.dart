import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/logic/remote_functionalities_request_task.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/logic/remote_functionalities_waiter_task.dart';

class RemoteFunctionalitiesExecutorStream with IDisposable, PaternalFunctionality, RemoteFunctionalitiesExecutor {
  //final Stream<Map<String, dynamic>> input;
  final StreamSink<Map<String, dynamic>> output;
  late final StreamSubscription<Map<String, dynamic>> _inputSubscription;

  final _syncNewTask = Semaphore();

  final _internalTasks = <int, InteractiveFunctionalityOperator>{};
  final _externalTask = <int, RemoteFunctionalitiesWaiterTask>{};

  int _lastID = 1;

  MaxiCompleter<int>? _waitingNewTask;
  MaxiCompleter<void>? _waitingPingResponse;

  RemoteFunctionalitiesExecutorStream({required Stream<Map<String, dynamic>> input, required this.output}) {
    _inputSubscription = input.listen(
      _processData,
      onDone: dispose,
    );

    output.done.whenComplete(dispose);
  }

  @override
  TextableFunctionality<T> executeInteractiveFunctionality<T, F extends TextableFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry}) {
    resurrectObject();
    return RemoteFunctionalitiesWaiterTask<T>(mainExecutor: this, parameters: parameters, type: F.toString());
  }

  @override
  TextableFunctionality<T> executeInteractiveFunctionalityViaName<T>({required String functionalityName, InvocationParameters parameters = InvocationParameters.emptry}) {
    resurrectObject();
    return RemoteFunctionalitiesWaiterTask<T>(mainExecutor: this, parameters: parameters, type: functionalityName);
  }

  void requestNewTask({
    required String type,
    required InvocationParameters parameters,
    required RemoteFunctionalitiesWaiterTask task,
  }) {
    _syncNewTask.execute(function: () async {
      try {
        _waitingNewTask ??= joinWaiter<int>();

        output.add({
          '\$type': 'newTask',
          'functionality': type,
          'parameters': parameters.serializeToJson(),
        });

        final newID = await _waitingNewTask!.future;

        _externalTask[newID] = task;
        task.setNewID(newID);
      } catch (ex, st) {
        task.defineErrorWhenRequestingIdentifier(NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Executing task')), st);
      }
    });
  }

  void removeExternalTask(int id) {
    _externalTask.remove(id);
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();
    _inputSubscription.cancel();
    output.close();

    _internalTasks.entries.iterar((x) => x.value.cancel());
    _internalTasks.clear();

    _externalTask.clear();
  }

  void _processData(Map<String, dynamic> event) {
    final type = event.getRequiredValueWithSpecificType<String>('\$type');
    if (const ['text', 'result', 'error'].contains(type)) {
      final id = event.getRequiredValueWithSpecificType<int>('id');
      final task = _externalTask[id];
      if (task != null) {
        task.processContent(event);
      } else {
        log('[RemoteFunctionalitiesExecutorStream] External task number $id was not found');
      }
      return;
    } else if (type == 'confirmNewTask') {
      final id = event.getRequiredValueWithSpecificType<int>('id');
      _waitingNewTask?.completeIfIncomplete(id);
      _waitingNewTask = null;
    } else if (type == 'cancel') {
      final id = event.getRequiredValueWithSpecificType<int>('id');
      final task = _internalTasks[id];
      task?.cancel();
    } else if (type == 'newTask') {
      _createInternalTask(event);
    } else if (type == 'ping') {
      output.add({'\$type': 'pong'});
    } else if (type == 'pong') {
      _waitingPingResponse?.completeIfIncomplete();
      _waitingPingResponse = null;
    }
  }

  Future<void> _createInternalTask(Map<String, dynamic> event) async {
    final id = _lastID;
    _lastID += 1;

    output.add({'\$type': 'confirmNewTask', 'id': id});

    final newOperator = RemoteFunctionalityRequestTask(identifier: id, mainOperator: this, rawData: event).createOperator(identifier: id);
    _internalTasks[id] = newOperator;

    try {
      final result = await newOperator.waitResult(
        onItem: (item) => output.add(
          {
            '\$type': 'text',
            'id': id,
            'content': item.serializeToJson(),
          },
        ),
      );
      output.add({
        '\$type': 'result',
        'id': id,
        'content': result == null ? '' : ConverterUtilities.serializeToJson(result),
        'contentType': result.runtimeType.toString(),
      });
    } catch (ex, st) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Executing external task'));
      output.add({
        '\$type': 'error',
        'id': id,
        'content': rn.serializeToJson(),
        'stack': st.toString(),
      });
    } finally {
      _internalTasks.remove(id);
    }
  }
}
