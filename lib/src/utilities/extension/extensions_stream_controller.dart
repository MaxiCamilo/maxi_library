import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

extension IteratorStreamController<T> on StreamController<T> {
  void addIfActive(T event) {
    if (!isClosed) {
      add(event);
    }
  }

  void addErrorIfActive(Object error, [StackTrace? stackTrace]) {
    if (!isClosed) {
      addError(error, stackTrace);
    }
  }

  StreamController<T> createReceiverChild({
    bool isBroadcats = false,
    bool closeIfParentCloses = true,
    bool closeParentIfChildClose = false,
    bool sendToParent = true,
  }) {
    checkProgrammingFailure(thatChecks: const Oration(message: 'StreamController is active'), result: () => !isClosed);
    final StreamController<T> child = isBroadcats ? StreamController<T>.broadcast() : StreamController<T>();

    stream.listen(
      (x) => child.add(x),
      onError: (x, y) => child.addError(x, y),
      onDone: () {
        if (closeIfParentCloses) {
          child.close();
        }
      },
    );

    if (closeParentIfChildClose) {
      child.done.whenComplete(() {
        close();
      });
    }

    return child;
  }
}
