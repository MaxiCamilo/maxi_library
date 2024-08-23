import 'package:maxi_library/maxi_library.dart';

enum FunctionalTaskStates { awaiting, running, finalized, failed, canceled }

mixin IOperatorFunctionalTask<T> {
  int get identifier;
  bool get isPersistent;
  Duration get waitUntilRetry;
  IFunctionalTask<T> get task;

  FunctionalTaskStates get state;

  bool get canRetry;
  Duration get howLongWaitRetry;

  T get lastResult;
  NegativeResult get lastError;
  DateTime get whenFailed;

  Stream<IOperatorFunctionalTask> get notifyStartTask;
  Stream<IOperatorFunctionalTask> get notifyFinishedTask;
  Stream<IOperatorFunctionalTask> get notifyCanceledTask;
  Stream<T> get notifyCompletedTask;
  Stream<NegativeResult> get notifyFailedTask;

  Future<bool> execute();
  Future<T> waitResult();
  void cancel();
}
