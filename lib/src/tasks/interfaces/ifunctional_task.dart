import 'package:maxi_library/src/tasks/execution_controller.dart';
import 'package:maxi_library/src/tasks/interfaces/ifunctional_controller_for_operator.dart';
import 'package:maxi_library/src/tasks/interfaces/ifunctional_controller_for_task.dart';

mixin IFunctionalTask<T> {
  Future<T> executeTask(IFunctionalControllerForTask controller);

  Future<void> reactFailure() async {}

  Future<void> reactCancellation() async {}
  Future<void> reactDisponse() async {}

  IFunctionalControllerForOperator generateCommunicationOperator() => ExecutionController();
}
