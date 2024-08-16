import 'package:maxi_library/src/tasks/interfaces/ifunctional_task.dart';

mixin IFunctionalTaskMixable {
  bool isCompatible(IFunctionalTask other);

  void mixTask(IFunctionalTask other);
}
