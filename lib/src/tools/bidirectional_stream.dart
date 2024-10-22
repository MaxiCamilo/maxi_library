import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class BidirectionalStream<R, S> with IPipe<R, S> {
  final _inputController = StreamController<R>.broadcast();
  final _outputController = StreamController<S>.broadcast();

  bool _isActive = true;

  @override
  Stream<R> get stream => _inputController.stream;
  Stream<S> get streamExternal => _outputController.stream;

  @override
  bool get isActive => _isActive;

  @override
  void add(S event) {
    _outputController.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputController.addError(error, stackTrace);
  }

  void addToExternal(R event) {
    _inputController.add(event);
  }

  void addErrorToExternal(Object error, [StackTrace? stackTrace]) {
    _inputController.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<S> stream) async {
    final waiter = Completer();

    final subscription = stream.listen(
      add,
      onError: addError,
      onDone: () => waiter.complete(),
    );

    final future = done.whenComplete(() {
      subscription.cancel();
    });
    await waiter.future;
    future.ignore();
  }

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    _inputController.close();
    _outputController.close();
  }

  @override
  Future get done => _outputController.done;
}
