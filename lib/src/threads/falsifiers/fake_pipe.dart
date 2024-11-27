import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/falsifiers/false_pipe_outlet.dart';

class FakePipe<R, S> with IPipe<R, S> {
  final _streamController = StreamController<R>.broadcast();
  final _onDone = Completer<FakePipe<R, S>>();

  bool _isActive = true;

  @override
  Future get done => _onDone.future;

  @override
  bool get isActive => _isActive;

  @override
  Stream<R> get stream => _streamController.stream;

  late final FalsePipeOutlet<S, R> outlet;

  FakePipe() {
    outlet = FalsePipeOutlet<S, R>(origin: this);
  }

  IPipe<S, R> callFunction({
    required InvocationContext parameters,
    required FutureOr<void> Function(InvocationContext, IPipe<R, S>) function,
  }) {
    scheduleMicrotask(() async {
      try {
        await function(parameters, this);
      } catch (ex, st) {
        addError(ex, st);
        close();
      }
    });

    return outlet;
  }

  void declareNewItem(R item) {
    _streamController.add(item);
  }

  void declareError(Object error, StackTrace? stackTrace) {
    _streamController.addError(error, stackTrace);
  }

  @override
  void add(S event) {
    outlet.declareNewItem(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    outlet.declareError(error, stackTrace);
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
    outlet.close();
  }
}
