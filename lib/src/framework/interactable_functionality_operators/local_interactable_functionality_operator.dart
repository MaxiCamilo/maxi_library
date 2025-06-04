import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class LocalInteractableFunctionalityOperator<I, R> with IDisposable, PaternalFunctionality, InteractableFunctionalityOperator<I, R>, InteractableFunctionalityExecutor<I, R> {
  final InteractableFunctionality<I, R> functionality;

  StreamController<I>? _textStreamController;
  MaxiCompleter<R>? _waiter;

  bool _isActive = false;
  bool _itEndedFunction = false;
  bool _itsWasGood = false;
  bool _itsWantCancel = false;
  bool _callThereAreNoListeners = false;

  R? _result;
  NegativeResult? _error;
  StackTrace? _stackTrace;

  Completer? _onCanceled;

  final MaxiCompleter _executionConfirmationWaiter = MaxiCompleter();

  @override
  int identifier;

  LocalInteractableFunctionalityOperator({required this.functionality, this.identifier = 0});

  @override
  Stream<I> get itemStream async* {
    if (_itEndedFunction) {
      return;
    }
    start();

    _textStreamController ??= createEventController<I>(isBroadcast: true);
    yield* _textStreamController!.stream;
  }

  @override
  void start() {
    if (_isActive || _itEndedFunction) {
      return;
    }

    _isActive = true;
    maxiScheduleMicrotask(_startFunctionality);
  }

  Future<void> _startFunctionality() async {
    _isActive = true;
    _itsWasGood = false;
    _itEndedFunction = false;
    _itsWantCancel = false;
    _callThereAreNoListeners = false;

    await continueOtherFutures();

    try {
      _executionConfirmationWaiter.completeIfIncomplete();
      // ignore: invalid_use_of_protected_member
      _result = await functionality.runFunctionality(manager: this);
      _itsWasGood = true;
    } catch (ex, st) {
      _stackTrace = st;

      // ignore: invalid_use_of_protected_member
      _error = functionality.castError(manager: this, rawError: ex, stackTrace: st);
      _itsWasGood = false;
      containErrorLog(
        detail: Oration(message: 'On error textable functionality "%1"', textParts: [functionality.functionalityName]),
        // ignore: invalid_use_of_protected_member
        function: () => functionality.onError(stackTrace: st, error: _error!, manager: this),
      );
    }

    containErrorLog(
      detail: Oration(message: 'On Finish textable functionality "%1"', textParts: [functionality.functionalityName]),
      // ignore: invalid_use_of_protected_member
      function: () => functionality.onFinish(manager: this, possibleError: _error, possibleResult: _result),
    );

    _isActive = false;
    _itEndedFunction = false;

    if (_waiter != null) {
      if (_itsWasGood) {
        _waiter!.complete(_result as R);
      } else {
        _waiter!.completeError(_error!, _stackTrace!);
      }

      _waiter = null;
    }

    dispose();
  }

  @override
  void cancel() {
    if (!_itsWantCancel) {
      _itsWantCancel = true;

      _executionConfirmationWaiter.future.whenComplete(() {
        if (!_isActive) {
          return;
        }
        _onCanceled?.completeIfIncomplete();
        _onCanceled = null;

        containErrorLog(
          detail: Oration(message: 'On Finish textable functionality "%1"', textParts: [functionality.functionalityName]),
          // ignore: invalid_use_of_protected_member
          function: () => functionality.onCancel(manager: this),
        );
      });
    }
  }

  @override
  void checkActivity() {
    if (_itsWantCancel) {
      throw NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'Functionality was canceled'),
      );
    }

    _checkIfListen(false);
  }

  @override
  void sendItem(I text) {
    checkActivity();
    if (_textStreamController != null) {
      _textStreamController?.addIfActive(text);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _onCanceled?.completeIfIncomplete();
    _onCanceled = null;

    _waiter?.completeErrorIfIncomplete(
      NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'Functionality was canceled'),
      ),
    );
    _waiter = null;

    containErrorLog(
      detail: Oration(message: 'On dispose textable functionality "%1"', textParts: [functionality.functionalityName]),
      // ignore: invalid_use_of_protected_member
      function: () => functionality.onManagerDispose(),
    );
  }

  @override
  MaxiFuture<R> waitResult({void Function(I)? onItem}) {
    _waiter ??= MaxiCompleter<R>(onNoOneListen: () => _checkIfListen(true));

    if (_itEndedFunction) {
      if (_itsWasGood) {
        _waiter!.complete(_result as R);
      } else {
        _waiter!.completeError(_error!, _stackTrace);
      }
    } else {
      start();
      if (onItem != null) {
        joinSubscription(itemStream.listen(onItem));
      }
    }

    return _waiter!.future;
  }

  @override
  Future<void> delayed(Duration time) async {
    checkActivity();
    _onCanceled ??= Completer();
    final timeout = Completer();
    final timerWaiter = Timer(time, () {
      timeout.completeIfIncomplete();
    });

    await Future.any([_onCanceled!.future, timeout.future]);
    timerWaiter.cancel();
    timeout.completeIfIncomplete();

    checkActivity();
  }

  @override
  Future<T> waitFuture<T>({required Future<T> future, Duration? timeout, FutureOr<T> Function()? onTimeout}) async {
    checkActivity();

    if (timeout == null) {
      _onCanceled ??= Completer();
      final result = await Future.any([_onCanceled!.future, future]);
      future.ignore();
      checkActivity();
      return result;
    } else {
      bool isTimeout = false;
      _onCanceled ??= Completer();
      final timeoutWaiter = Completer();
      final timerWaiter = Timer(timeout, () {
        isTimeout = true;
        timeoutWaiter.completeIfIncomplete();
      });

      final result = await Future.any([_onCanceled!.future, timeoutWaiter.future, future]);
      timerWaiter.cancel();
      timeoutWaiter.completeIfIncomplete();
      future.ignore();
      checkActivity();

      if (isTimeout) {
        if (onTimeout == null) {
          throw NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'A feature took an excessive amount of time to complete'),
          );
        } else {
          return await onTimeout();
        }
      } else {
        return result;
      }
    }
  }

  void _checkIfListen(bool containtError) {
    if (_waiter != null && !_waiter!.hasListener && !_callThereAreNoListeners) {
      _callThereAreNoListeners = true;
      if (containtError) {
        containErrorLog(
          detail: Oration(message: 'On There Are No Listeners textable functionality "%1"', textParts: [functionality.functionalityName]),
          // ignore: invalid_use_of_protected_member
          function: () => functionality.onThereAreNoListeners(manager: this),
        );
      } else {
        // ignore: invalid_use_of_protected_member
        functionality.onThereAreNoListeners(manager: this);
      }

      // ignore: invalid_use_of_protected_member
      if (functionality.cancelIfItsInactive) {
        cancel();
      } else {
        checkActivity();
      }
    }
  }
}
