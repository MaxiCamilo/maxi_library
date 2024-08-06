import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_client.dart';

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
          message: trc('the thread handles the type %1, but the type %2 is requested', [process.typeManager, T]),
        );
      }
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: tr('The thread does not handle entities'),
    );
  }

  static T? checkGetItemFromProcess<T>(IThreadProcess process) {
    if (process is IThreadProcessEntity<T>) {
      return process.entity;
    }

    return null;
  }

  static dynamic getGenericItemFromProcess(IThreadProcess process) {
    if (process is IThreadProcessEntity) {
      return process.entity;
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: tr('The thread does not handle entities'),
    );
  }
}
