import 'package:maxi_library/maxi_library.dart';

class QueueExecutorWithEntity<T, F extends TextableFunctionality> extends QueueExecutor<F> {
  final T entity;

  QueueExecutorWithEntity({required this.entity, super.identifier = 0});

  F addFunctionalityWithEntity({required F Function(T) taskCreator, bool mixTask = true}) {
    final task = taskCreator(entity);

    return addFunctionality(newTask: task, mixTask: mixTask);
  }

  @override
  void dispose() {
    super.dispose();

    if (entity is IDisposable) {
      (entity as IDisposable).dispose();
    }
  }
}
