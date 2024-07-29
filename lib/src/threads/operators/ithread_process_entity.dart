import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/operators/ithread_process.dart';
import 'package:maxi_library/src/threads/operators/ithread_process_client.dart';

mixin IThreadProcessEntity<T> on IThreadInvoker, IThreadProcess, IThreadProcessClient {
  T get entity;
  Type get typeManager;

  set entity(T newItem);

  static T getItemFromProcess<T>(IThreadProcess process) {
    if (process is IThreadProcessEntity) {
      if (process is IThreadProcessEntity<T>) {
        return process.entity;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: '${tr('the thread handles the type ')} ${process.typeManager} ${tr(', but the type ')} $T ${tr(' is requested')}',
        );
      }
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: tr('The thread does not handle entities'),
    );
  }
}
