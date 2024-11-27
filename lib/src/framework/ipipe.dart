import 'dart:async';

mixin IPipe<R, S> implements StreamSink<S> {
  bool get isActive;

  Stream<R> get stream;

  void addIfActive(S item) {
    if (isActive) {
      add(item);
    }
  }

  void joinCrossPipe({
    required IPipe<S, R> pipe,
    bool closeThisPipeIfFinish = false,
    bool closeConnectedPipeIfFinished = false,
  }) {
    pipe.stream.listen(
      add,
      onError: addError,
      onDone: () {
        if (closeThisPipeIfFinish) {
          close();
        }
      },
    );

    stream.listen(
      pipe.add,
      onError: pipe.addError,
      onDone: () {
        if (closeConnectedPipeIfFinished) {
          pipe.close();
        }
      },
    );
  }
}
