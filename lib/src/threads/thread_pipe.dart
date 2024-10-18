import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin ThreadPipe<R, S> on StartableFunctionality implements StreamSink<S> {
  bool get isActive;

  Stream<R> get stream;

  ThreadPipe<R, S> cloner();

  void addIfActive(S item) {
    if (isActive) {
      add(item);
    }
  }

  Future<void> join({
    Stream<S>? input,
    StreamSink<R>? output,
    required bool closeExternalIfClose,
    required bool selfCloseIfStreamClosed,
    bool performInitialized = true,
  }) async {
    checkProgrammingFailure(thatChecks: tr('At least one input or output was placed'), result: () => input != null || output != null);

    if (performInitialized) {
      await initialize();
    } else {
      checkInitialize();
    }

    if (input != null) {
      late final StreamSubscription<S> outputSubscription;
      outputSubscription = input.listen(
        add,
        onError: addError,
        onDone: () {
          if (selfCloseIfStreamClosed) {
            close();
          }
        },
      );

      done.whenComplete(() {
        outputSubscription.cancel();
      });
    }

    if (output != null) {
      stream.listen(
        output.add,
        onError: output.addError,
        onDone: () {
          if (closeExternalIfClose) {
            output.close();
          }
        },
      );

      output.done.whenComplete(() {
        if (selfCloseIfStreamClosed) {
          close();
        }
      });
    }
  }
}
