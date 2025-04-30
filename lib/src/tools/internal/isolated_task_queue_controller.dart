import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class IsolatedTaskQueueController {
  final String nameQueue;

  IsolatedTaskQueueController({required this.nameQueue});

  final _taskQueue = <(int, Duration)>[];
  final _notifyNextTaskController = StreamController<int>.broadcast();
  final _semaphore = Semaphore();

  int _lastID = 1;
  int _actualTask = 0;

  Completer<int>? _waitingConfirmation;
  Completer<int>? _waitingFinish;

  Stream<int> get notifyNextTask => _notifyNextTaskController.stream;
  bool get isActive => _semaphore.isActive;

  Future<void> _execute() async {
    while (_taskQueue.isNotEmpty) {
      final actualTask = _taskQueue.removeAt(0);
      _waitingConfirmation = MaxiCompleter<int>();

      _actualTask = actualTask.$1;
      _notifyNextTaskController.add(actualTask.$1);

      final id = await _waitingConfirmation!.future.timeout(const Duration(seconds: 3), onTimeout: () => -1);

      if (id == -1) {
        log('[IsolatedTaskQueueController] Task $_actualTask did not confirm its execution in time, another task is being executed!');
        continue;
      } else if (id != _actualTask) {
        log('[IsolatedTaskQueueController] Confirmation of task $_actualTask was expected, but $id was confirmed in operator!');
        continue;
      }

      _waitingFinish = MaxiCompleter<int>();
      final finishID = await _waitingFinish!.future.timeout(actualTask.$2, onTimeout: () => -1);

      if (finishID == -1) {
        log('[IsolatedTaskQueueController] Task $_actualTask took too long!, proceeding with other tasks');
        continue;
      } else if (finishID != _actualTask) {
        log('[IsolatedTaskQueueController] The completion of $_actualTask was expected, not $finishID!');
        continue;
      }
    }

    _actualTask = 0;
  }

  int addReservationTask(Duration timeout) {
    final id = _lastID;
    _lastID += 1;

    _taskQueue.add((id, timeout));

    scheduleMicrotask(() => _semaphore.executeIfStopped(function: _execute));

    return id;
  }

  void confirmTaskExecution(int id) {
    if (_waitingConfirmation == null || _waitingConfirmation!.isCompleted) {
      log('[IsolatedTaskQueueController] Execution confirmation was not expected!');
      return;
    }

    if (id != _actualTask) {
      log('[IsolatedTaskQueueController] Confirmation of task $_actualTask was expected, not $id!');
      return;
    }

    _waitingConfirmation?.completeIfIncomplete(id);
  }

  void finishTask(int id) {
    if (id == _actualTask) {
      if (_waitingFinish == null || _waitingFinish!.isCompleted) {
        log('[IsolatedTaskQueueController] The finishing of an execution was not expected!');
        return;
      }

      _waitingFinish!.completeIfIncomplete(id);
    } else {
      final exists = _taskQueue.selectItem((x) => x.$1 == id);
      if (exists == null) {
        log('[IsolatedTaskQueueController] The finishing of an execution was not expected and it was not listed!');
      } else {
        _taskQueue.remove(exists);
      }
    }
  }
}
