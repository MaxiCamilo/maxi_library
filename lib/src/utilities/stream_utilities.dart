import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';


mixin StreamUtilities {
  static Future<T> waitForSomethingInSeveralStream<T>({
    required Iterable<Stream<T>> streams,
    bool cancelIfError = true,
    Duration? timeout,
    T? timeoutValue,
    Oration timeoutError = const Oration(message: 'Waited too long for a value in one of the selected streams'),
  }) async {
    final completer = MaxiCompleter<T>();
    final subscriptionsList = <StreamSubscription>[];
    Timer? timer;

    if (timeout != null) {
      timer = Timer(timeout, () {
        if (timeoutValue == null) {
          completer.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.timeout, message: timeoutError));
        } else {
          completer.completeIfIncomplete(timeoutValue);
        }
      });
    }

    for (final stream in streams) {
      stream.listen(
        (x) {
          completer.completeIfIncomplete(x);
        },
        onError: (x, y) {
          if (cancelIfError) {
            completer.completeErrorIfIncomplete(x, y);
          }
        },
      );
    }

    try {
      return await completer.future;
    } finally {
      timer?.cancel();
      subscriptionsList.iterar((x) => x.cancel());
    }
  }
}
