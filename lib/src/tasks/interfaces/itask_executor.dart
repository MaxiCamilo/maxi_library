import 'package:maxi_library/src/tasks/interfaces/ifunctional_task.dart';
import 'package:maxi_library/src/tasks/interfaces/ioperator_functional_task.dart';

mixin ITaskExecutor {
  IOperatorFunctionalTask? get activeTask;
  List<IOperatorFunctionalTask> get pendingTasks;
  List<IOperatorFunctionalTask> get persistentTasks;

  void cancelAll();

  IOperatorFunctionalTask<T> generateTask<T>({
    required IFunctionalTask<T> functionality,
    required bool isPersistent,
    required Duration waitUntilRetry,
    required bool isMixable,
  });

  
}
