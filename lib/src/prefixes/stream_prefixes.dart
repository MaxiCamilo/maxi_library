import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/stream_state_internal.dart';

StreamState<S, R> streamStatus<S, R>(S item) => StreamStateItem(item: item);
StreamState<S, R> checkStreamState<S, R>() => const StreamCheckActive();
StreamState<S, R> streamPartialError<S, R>(ex) => StreamStatePartialError(partialError: ex);
StreamState<S, R> streamResult<S, R>(R result) => StreamStateResult(result: result);
StreamState<Oration, R> streamTextStatus<R>(Oration oration) => StreamStateItem<Oration, R>(item: oration);

Stream<StreamState<S, R>> connectFunctionalStream<S, R, SR>(Stream<StreamState<S, SR>> other, [void Function(SR x)? sendResult]) async* {
  late final SR result;
  bool returnResult = false;

  await for (final item in other) {
    if (item is StreamStateItem<S, SR>) {
      yield StreamStateItem<S, R>(item: item.item);
    } else if (item is StreamStateResult<S, SR>) {
      result = item.result;
      returnResult = true;
      break;
    } else if (item is StreamStatePartialError<S, SR>) {
      yield StreamStatePartialError<S, R>(partialError: item.partialError);
    } else if (item is StreamCheckActive<S, SR>) {
      yield StreamCheckActive<S, R>();
    } else {
      log('[connectFunctionalStream] Unkown item steam');
    }
  }

  if (returnResult && sendResult != null) {
    sendResult(result);
  } else if (!returnResult && sendResult != null) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: Oration(message: 'The stateful process failed to produce the final output'),
    );
  }
}

Stream<S> getOnlyStreamItems<S, R>(Stream<StreamState<S, R>> stream) {
  return stream.whereType<StreamStateItem<S, R>>().map((x) => x.item);
}

Stream<StreamState<S, R>> connectOptionalFunctionalStream<S, R, SR>(
  Stream<StreamState<S, SR>> other, {
  void Function(SR x)? onResult,
  void Function(dynamic, StackTrace?)? onError,
}) async* {
  late final SR result;
  bool returnResult = false;
  try {
    await for (final item in other) {
      if (item is StreamStateItem<S, SR>) {
        yield StreamStateItem<S, R>(item: item.item);
      } else if (item is StreamStateResult<S, SR>) {
        result = item.result;
        returnResult = true;
        break;
      } else if (item is StreamStatePartialError<S, SR>) {
        yield StreamStatePartialError<S, R>(partialError: item.partialError);
      } else if (item is StreamCheckActive<S, SR>) {
        yield StreamCheckActive<S, R>();
      } else {
        log('[connectFunctionalStream] Unkown item steam');
      }
    }

    if (returnResult && onResult != null) {
      onResult(result);
    } else if (!returnResult && onResult != null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(message: 'The stateful process failed to produce the final output'),
      );
    }
  } catch (x, y) {
    if (onError != null) {
      onError(x, y);
    }
  }
}

Future<R> waitFunctionalStream<S, R>({
  required Stream<StreamState<S, R>> stream,
  void Function(S x)? onData,
  void Function(R?)? onDoneOrCanceled,
  void Function(dynamic ex)? onError,
  void Function(StreamSubscription<StreamState<S, R>>)? onSubscription,
}) async {
  final completer = Completer<R>();

  final subscription = stream.doOnCancel(() {
    if (!completer.isCompleted) {
      if (onDoneOrCanceled != null) {
        onDoneOrCanceled(null);
      }

      if (R == dynamic || R.toString() == 'void' || R.toString() == 'Null') {
        completer.complete();
      } else {
        completer.completeError(NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: Oration(message: 'Functional stream has not returned a result'),
        ));
      }
    }
  }).listen(
    (item) {
      if (item is StreamStateItem<S, R>) {
        onData?.call(item.item);
      } else if (item is StreamStateResult<S, R>) {
        completer.completeIfIncomplete(item.result);
        if (onDoneOrCanceled != null) {
          onDoneOrCanceled(item.result);
        }
      } else if (item is StreamStatePartialError<S, R>) {
        onError?.call(item.partialError);
      }
    },
    onError: (x, y) {
      completer.completeErrorIfIncomplete(x, y);
    },
    onDone: () {
      if (!completer.isCompleted && onDoneOrCanceled != null) {
        onDoneOrCanceled(null);
      }

      if (!completer.isCompleted) {
        if (R == dynamic || R.toString() == 'void' || R.toString() == 'Null') {
          completer.complete();
        } else {
          completer.completeError(NegativeResult(
            identifier: NegativeResultCodes.implementationFailure,
            message: Oration(message: 'Functional stream has not returned a result'),
          ));
        }
      }
    },
  );

  if (onSubscription != null) {
    onSubscription(subscription);
  }

  try {
    return await completer.future;
  } finally {
    subscription.cancel();
  }
}
