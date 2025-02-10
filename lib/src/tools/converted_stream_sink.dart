import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

extension ExtensionConvertedStreamSink<O> on StreamSink<O> {
  ConvertedStreamSink<I, O> createConverter<I>() => ConvertedStreamSink<I, O>(origin: this);
}

class ConvertedStreamSink<I, O> implements StreamSink<I> {
  final StreamSink<O> origin;

  ConvertedStreamSink({required this.origin});

  @override
  Future get done => origin.done;

  @override
  void add(I event) {
    if (event is O) {
      origin.add(event);
    } else {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'item of type %1 is not compatible with type %2',textParts: [I, O]));
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    origin.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<I> stream) async {
    final compelteter = Completer();

    final subscription = stream.listen(
      (x) => add(x),
      onError: (x, y) => addError(x, y),
      onDone: () => compelteter.completeIfIncomplete(),
    );

    final future = done.whenComplete(() => compelteter.completeIfIncomplete());

    await compelteter.future;

    subscription.cancel();
    future.ignore();
  }

  @override
  Future close() {
    return origin.close();
  }
}
