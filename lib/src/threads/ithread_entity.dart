import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_process.dart';

mixin IThreadEntity<T> on IThreadProcess {
  T get entity;
  Type get typeManager;

  set entity(T newItem);

  static T getItemFromProcess<T>(IThreadProcess process) {
    if (process is IThreadEntity) {
      if (process is IThreadEntity<T>) {
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
