import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/falsifiers/fake_pipe.dart';

class FalsePipeOutlet<R, S> with IPipe<R, S> {
  final FakePipe<S, R> origin;

  final _streamController = StreamController<R>.broadcast();
  final _onDone = Completer<FalsePipeOutlet<R, S>>();

  bool _isActive = true;

  @override
  Future get done => _onDone.future;

  @override
  bool get isActive => _isActive;

  @override
  Stream<R> get stream => _streamController.stream;

  FalsePipeOutlet({required this.origin});

  void declareNewItem(R item) {
    _streamController.add(item);
  }

  void declareError(Object error, StackTrace? stackTrace) {
    _streamController.addError(error, stackTrace);
  }

  @override
  void add(S event) {
    origin.declareNewItem(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    origin.declareError(error, stackTrace);
  }

  @override
  Future addStream(Stream<S> stream) async {
    if (!_isActive) {
      log('[FakePipe] The pipe is closed');
      return;
    }

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
  Future close() async {
    if (!isActive) {
      return;
    }

    _isActive = false;
    _streamController.close();
    _onDone.completeIfIncomplete(this);
    origin.close();
  }
}
