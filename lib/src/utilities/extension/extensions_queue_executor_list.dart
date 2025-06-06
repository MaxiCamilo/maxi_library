import 'package:maxi_library/maxi_library.dart';

extension ExtensionQueueExecutorIterable<F extends InteractableFunctionality<Oration, dynamic>> on Iterable<QueueExecutor<F>> {
  QueueExecutor? searchQueue({required int identifier}) => selectItem((x) => x.identifier == identifier);

  (QueueExecutor, F)? selectTaskAndQueue({required int identifier}) {
    for (final queue in this) {
      final taskFound = queue.searchTask(identifier);
      if (taskFound != null) {
        return (queue, taskFound);
      }
    }

    return null;
  }

  F? selectTask({required int identifier}) {
    final result = selectTaskAndQueue(identifier: identifier);

    return result?.$2;
  }

  bool cancelTask({required int identifier}) {
    return any((x) => x.cancelTask(identifier));
  }

  void cancellAll() {
    iterar((x) => x.cancelAll());
  }

  bool startTask(int identifier) {
    return any((x) => x.startTask(identifier));
  }
}

extension ExtensionQueueExecutorList<F extends InteractableFunctionality<Oration, dynamic>> on List<QueueExecutor<F>> {
  bool removeQueue({required int identifier}) {
    final result = searchQueue(identifier: identifier);
    if (result == null) {
      return false;
    }

    remove(result);
    result.dispose();

    return true;
  }
}
