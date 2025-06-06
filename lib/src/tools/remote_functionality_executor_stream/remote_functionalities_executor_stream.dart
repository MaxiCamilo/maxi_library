import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/logic/create_external_unknown_waiter.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/logic/create_external_waiter.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/logic/create_new_external_task.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_waiter.dart';

class RemoteFunctionalitiesExecutorStream with IDisposable, PaternalFunctionality, RemoteFunctionalitiesExecutor {
  //final Stream<Map<String, dynamic>> input;
  final StreamSink<Map<String, dynamic>> output;
  late final StreamSubscription<Map<String, dynamic>> _inputSubscription;

  final _syncNewTask = Semaphore();

  final _externalTasks = <RemoteFunctionalitiesExecutorWaiter>[];
  final _internalTasks = <InteractableFunctionalityOperator<Oration, dynamic>>[];

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
  InteractableFunctionalityOperator<Oration, T> executeInteractableFunctionality<T, F extends TextableFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry}) {
    resurrectObject();
    return CreateExternalWaiter<T, F>(mainOperator: this, parameters: parameters).createOperator()..start();
  }

  Future<RemoteFunctionalitiesExecutorWaiter<T>> sendAndWait<T, F extends TextableFunctionality<T>>(InvocationParameters parameters) {
    return sendAndWaitUnknown(parameters: parameters, type: F.toString());
  }

  Future<RemoteFunctionalitiesExecutorWaiter<T>> sendAndWaitUnknown<T>({required String type, required InvocationParameters parameters}) {
    return _syncNewTask.execute(function: () async {
      _waitingNewTask ??= joinWaiter<int>();

      output.add({
        '\$type': 'newTask',
        'functionality': type,
        'parameters': parameters.serializeToJson(),
      });

      final id = await _waitingNewTask!.future;
      final newTask = RemoteFunctionalitiesExecutorWaiter<T>(identifier: id, mainOperator: this);

      _externalTasks.add(newTask);
      newTask.onDispose.whenComplete(() => _externalTasks.remove(newTask));

      return newTask;
    });
  }

  @override
  InteractableFunctionalityOperator<Oration, T> executeInteractableFunctionalityViaName<T>({required String functionalityName, InvocationParameters parameters = InvocationParameters.emptry}) {
    resurrectObject();
    return CreateExternalUnknownWaiter<T>(mainOperator: this, parameters: parameters, typeName: functionalityName).createOperator()..start();
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();
    _inputSubscription.cancel();
    output.close();

    _externalTasks.iterar((x) => x.dispose());
    _externalTasks.clear();
  }

  void _processData(Map<String, dynamic> event) {
    final type = event.getRequiredValueWithSpecificType<String>('\$type');
    if (const ['item', 'result', 'error'].contains(type)) {
      final id = event.getRequiredValueWithSpecificType<int>('id');
      final task = _externalTasks.selectItem((x) => x.identifier == id);
      if (task != null) {
        task.sendMessage(event);
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
      final task = _internalTasks.selectItem((x) => x.identifier == id);
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

  void _createInternalTask(Map<String, dynamic> event) {
    final id = _lastID;
    _lastID += 1;

    output.add({'\$type': 'confirmNewTask', 'id': id});

    final newOperator = CreateNewExternalTask(identifier: id, mainOperator: this, rawData: event).runInMapStream(sender: output, closeSenderIfDone: false, identifier: id);
    _internalTasks.add(newOperator);

    newOperator.onDispose.whenComplete(() => _internalTasks.remove(newOperator));
    newOperator.start();
  }
}
