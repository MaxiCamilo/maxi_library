import 'package:maxi_library/maxi_library.dart';

class FunctionalTaskExpress<T> with IFunctionalTask<T> {
  final Future<T> Function(IFunctionalControllerForTask controller) function;

  const FunctionalTaskExpress._(this.function);

  factory FunctionalTaskExpress.withController(Future<T> Function(IFunctionalControllerForTask controller) function) => FunctionalTaskExpress._(function);
  factory FunctionalTaskExpress.withoutController(Future<T> Function() function) => FunctionalTaskExpress._((_) => function());

  @override
  Future<T> executeTask(IFunctionalControllerForTask controller) {
    return function(controller);
  }
}
