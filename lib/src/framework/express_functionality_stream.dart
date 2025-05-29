import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

class ExpressFunctionalityStream<T> with IDisposable, PaternalFunctionality implements IStreamFunctionality<T> {
  final StreamStateTexts<T> stream;
  @override
  final bool cancelIfItsInactive;

  late final FunctionalityStreamManager<T> _manager;

  final void Function(Oration)? _onExText;
  final void Function(dynamic, StackTrace)? _onExError;
  final void Function()? _onExDoneOrCanceled;
  final void Function(T)? _onExResult;
  final void Function()? _onExCancel;

  Completer<T>? _waiter;

  ExpressFunctionalityStream({
    required this.stream,
    this.cancelIfItsInactive = true,
    void Function(Oration)? onText,
    void Function(dynamic, StackTrace)? onError,
    void Function()? onDoneOrCanceled,
    void Function(T)? onResult,
    void Function()? onCancel,
  })  : _onExText = onText,
        _onExError = onError,
        _onExDoneOrCanceled = onDoneOrCanceled,
        _onExResult = onResult,
        _onExCancel = onCancel {
    _manager = joinObject(item: FunctionalityStreamManager<T>(functionality: this));
  }

  @override
  FunctionalityStreamManager<T> createManager() {
    return _manager;
  }

  StreamStateTexts<T> start() => _manager.start();

  @override
  @protected
  StreamStateTexts<T> runFunctionality({required FunctionalityStreamManager<T> manager}) {
    if (_onExText != null) {
      manager.textStream.listen(_onExText);
    }

    return stream;
  }

  @override
  StreamStateTexts<R> joinManager<R>(
      {FunctionalityStreamManager<T>? manager, required FunctionalityStreamManager<R> otherManager, required void Function(T p1) then, void Function(dynamic p1, StackTrace p2)? onError, bool errorAreFatals = true}) {
    return _manager.joinManager<R>(otherManager: otherManager, then: then, errorAreFatals: errorAreFatals, onError: onError);
  }

  @override
  StreamStateTexts<T> runWithoutManager({required void Function(T p1) then, void Function(dynamic p1, StackTrace p2)? onError}) {
    return _manager.startAndBePending(then: then, onError: onError);
  }

  @override
  Future<T> waitResult({void Function(Oration p1)? onText, PaternalFunctionality? parent}) {
    _waiter ??= joinWaiter<T>();
    _manager.silentStart();

    return _waiter!.future;
  }

  Future<void> waitFinish({
    Function(Oration)? onText,
    Function(T)? then,
    Function(dynamic, StackTrace)? onError,
  }) {
    _manager.silentStart();
    return _manager.waitFinish(onError: onError, onText: onText, then: then);
  }

  @override
  @protected
  void onError({required FunctionalityStreamManager<T> manager, required error, required StackTrace stackTrace}) {
    _waiter?.completeErrorIfIncomplete(error);
    _waiter = null;

    if (_onExError != null) {
      _onExError(error, stackTrace);
    }
  }

  @override
  @protected
  void onFinish({required FunctionalityStreamManager<T> manager, T? possibleResult, NegativeResult? possibleError}) {
    if (_onExDoneOrCanceled != null) {
      _onExDoneOrCanceled();
    }
  }

  @override
  @protected
  void onThereAreNoListeners({required FunctionalityStreamManager<T> manager}) {}

  @override
  @protected
  void onThereIsNewListener({required FunctionalityStreamManager<T> manager}) {}

  @override
  void onResult({required FunctionalityStreamManager<T> manager, required T result}) {
    _waiter?.completeIfIncomplete(result);
    _waiter = null;

    if (_onExResult != null) {
      _onExResult(result);
    }
  }

  @override
  @protected
  void onManagerDispose() {}

  @override
  void onCancel({required FunctionalityStreamManager<T> manager}) {
    if (_onExCancel != null) {
      _onExCancel();
    }
  }
}
