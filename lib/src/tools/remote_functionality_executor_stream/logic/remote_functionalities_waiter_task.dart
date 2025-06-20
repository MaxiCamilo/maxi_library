import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';

class RemoteFunctionalitiesWaiterTask<T> with TextableFunctionality<T> {
  int _taskID = 0;
  final RemoteFunctionalitiesExecutorStream mainExecutor;
  final InvocationParameters parameters;

  final String type;

  MaxiCompleter<T>? _waiter;
  MaxiCompleter<int>? _waiterID;
  StreamController<Oration>? _streamTextController;

  RemoteFunctionalitiesWaiterTask({required this.mainExecutor, required this.type, required this.parameters});

  @override
  Future<T> runFunctionality({required InteractiveFunctionalityExecutor<Oration, T> manager}) async {
    mainExecutor.checkIfDispose();
    if (_waiter != null) {
      if (_streamTextController != null) {
        _streamTextController!.stream.listen((x) => manager.sendItem(x));
      }
      return await _waiter!.future;
    }

    _waiter = manager.joinWaiter<T>();
    _waiterID ??= manager.joinWaiter<int>();

    _streamTextController = manager.createEventController<Oration>(isBroadcast: true);
    _streamTextController!.stream.listen((x) => manager.sendItem(x));

    mainExecutor.requestNewTask(type: type, parameters: parameters, task: this);

    await _waiterID!.future;

    return await _waiter!.future;
    
  }

  void setNewID(int id) {
    _taskID = id;
    _waiterID?.completeIfIncomplete(id);
    _waiterID = null;
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<Oration, T> manager}) {
    super.onCancel(manager: manager);

    if (_taskID > 0 && !mainExecutor.wasDiscarded) {
      mainExecutor.output.add({'\$type': 'cancel', 'id': _taskID});
    }
  }

  @override
  void onFinish({required InteractiveFunctionalityExecutor<Oration, T> manager, T? possibleResult, NegativeResult? possibleError}) {
    super.onFinish(manager: manager, possibleResult: possibleResult, possibleError: possibleError);

    mainExecutor.removeExternalTask(_taskID);

    _streamTextController?.close();
    _streamTextController = null;
  }

  void defineErrorWhenRequestingIdentifier(NegativeResult nr, StackTrace st) {
    _waiterID?.completeErrorIfIncomplete(nr, st);
  }

  void processContent(Map<String, dynamic> event) {
    final type = event.getRequiredValueWithSpecificType<String>('\$type');

    if (type == 'text') {
      final rawContent = event.getRequiredValueWithSpecificType<String>('content');
      final oration = Oration.interpretFromJson(text: rawContent);
      _streamTextController?.addIfActive(oration);
      return;
    }

    _waiter ??= MaxiCompleter<T>();

    if (type == 'result') {
      final rawContent = event.getRequiredValueWithSpecificType<String>('content');

      if (T.toString() == 'void') {
        _waiter?.completeIfIncomplete();
      } else if (T == dynamic) {
        _waiter?.completeIfIncomplete(rawContent as dynamic);
      } else {
        try {
          final result = ConverterUtilities.castDynamicJson(text: rawContent, type: T);
          _waiter?.completeIfIncomplete(result as T);
        } catch (ex, st) {
          _waiter?.completeErrorIfIncomplete(ex, st);
        }
      }

      return;
    }

    if (type == 'error') {
      try {
        final rawContent = event.getRequiredValueWithSpecificType<String>('content');
        final stackStrace = StackTrace.fromString(event.getRequiredValueWithSpecificType<String>('stack'));

        _waiter?.completeErrorIfIncomplete(NegativeResult.interpretJson(jsonText: rawContent), stackStrace);
      } catch (ex, st) {
        _waiter?.completeErrorIfIncomplete(ex, st);
      }
      return;
    }
  }
}
