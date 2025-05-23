import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/stream_state_internal.dart';
import 'package:meta/meta.dart';

class FunctionalityStreamManager<T> with IDisposable, PaternalFunctionality {
  final IStreamFunctionality<T> functionality;

  bool _wantsCanceled = false;
  bool _isActive = false;
  bool _itsWasGood = false;

  StreamController<StreamState<Oration, T>>? _clientController;

  T? _lastResult;
  dynamic _lastError;
  StackTrace? _lastStackTraceError;
  Completer? _waiter;
  StreamSubscription? _subscription;

  FunctionalityStreamManager({required this.functionality});

  Stream<Oration> get textStream => start().whereType<StreamStateItem<Oration, T>>().map((x) => x.item);

  void silentStart() {
    if (_clientController == null || !_clientController!.isClosed) {
      _clientController = createEventController<StreamState<Oration, T>>(isBroadcast: true)..onCancel = _onNoMoreClients;
    }

    if (!_isActive) {
      _isActive = true;
      _wantsCanceled = false;
      maxiScheduleMicrotask(_runFunctionality);
    }

    // ignore: invalid_use_of_protected_member
    maxiScheduleMicrotask(() => functionality.onThereIsNewListener(manager: this));
  }

  void sendText(Oration text) {
    if (_clientController != null && !_clientController!.isClosed) {
      _clientController!.add(streamTextStatus(text));
    }
  }

  Future<void> waitFinish({
    Function(Oration)? onText,
    Function(T)? then,
    Function(dynamic, StackTrace)? onError,
  }) async {
    _waiter ??= joinWaiter();
    silentStart();

    if (onText != null) {
      textStream.listen(onText);
    }

    await _waiter!.future;

    if (_itsWasGood) {
      if (_lastResult is T) {
        if (then != null) {
          then(_lastResult as T);
        }
      } else {
        if (onError != null) {
          onError(
            NegativeResult(
              identifier: NegativeResultCodes.implementationFailure,
              message: Oration(message: 'The functionality "%1" does not return a final result', textParts: [runtimeType.toString()]),
            ),
            StackTrace.current,
          );
        }
      }
    } else {
      if (onError != null) {
        onError(_lastError, _lastStackTraceError!);
      }
    }
  }

  Future<T> waitResult({void Function(Oration)? onText}) async {
    if (onText != null) {
      joinEvent(event: textStream, onData: (x) => onText(x));
    }

    await start().waitFinish();
    final completer = joinWaiter<T>(MaxiCompleter(waiterName: 'Functionality stream'));

    if (_itsWasGood) {
      if (_lastResult is! T) {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: Oration(message: 'The functionality "%1" does not return a final result', textParts: [runtimeType.toString()]),
        );
      }
      completer.completeIfIncomplete(_lastResult);
    } else {
      completer.completeErrorIfIncomplete(_lastError, _lastStackTraceError);
    }

    return await completer.future;
  }

  StreamStateTexts<T> startAndBePending({required void Function(T) then, void Function(dynamic, StackTrace)? onError}) async* {
    yield* start();
    final completer = joinWaiter(MaxiCompleter(waiterName: 'Functionality stream'));

    if (_itsWasGood) {
      if (_lastResult is! T) {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: Oration(message: 'The functionality "%1" does not return a final result', textParts: [runtimeType.toString()]),
        );
      }
      completer.completeIfIncomplete(_lastResult);
    } else {
      completer.completeErrorIfIncomplete(_lastError, _lastStackTraceError);
    }

    await completer.future;
  }

  StreamStateTexts<T> start() {
    silentStart();
    return _clientController!.stream;
  }

  void _onNoMoreClients() {
    // ignore: invalid_use_of_protected_member
    containErrorLog(detail: const Oration(message: 'Invoke no more clients on functionality'), function: () => functionality.onThereAreNoListeners(manager: this));

    // ignore: invalid_use_of_protected_member
    if (functionality.cancelIfItsInactive) {
      dispose();
    }
  }

  Future<void> _runFunctionality() async {
    _isActive = true;

    _wantsCanceled = false;
    _itsWasGood = false;
    _lastResult = null;
    _lastError = null;
    _lastStackTraceError = null;

    _waiter ??= joinWaiter<void>();

    _subscription = joinEvent(
      // ignore: invalid_use_of_protected_member
      event: functionality.runFunctionality(manager: this),
      onData: (x) {
        if (x is StreamStateResult<Oration, T>) {
          _lastResult = x.result;
          _itsWasGood = true;
          _subscription?.cancel();
          // ignore: invalid_use_of_protected_member
          containErrorLog(detail: const Oration(message: 'on result functionality'), function: () => functionality.onResult(manager: this, result: _lastResult as T));
        } else {
          _clientController?.addIfActive(x);
        }
      },
      onError: (x, y) {
        _clientController?.addErrorIfActive(x, y);
        _lastError = x;
        _lastStackTraceError = y;
        _itsWasGood = false;
        // ignore: invalid_use_of_protected_member
        containErrorLog(detail: const Oration(message: 'on error functionality'), function: () => functionality.onError(manager: this, error: _lastError, stackTrace: y));
      },
      onDone: () {
        _waiter?.completeIfIncomplete();
        _waiter = null;
      },
    );

    await _waiter!.future;

    containErrorLog(
      detail: const Oration(message: 'Finishing functionality'),
      // ignore: invalid_use_of_protected_member
      function: () => functionality.onFinish(
        manager: this,
        possibleResult: _itsWasGood ? _lastResult : null,
        possibleError: !_itsWasGood ? _lastError : null,
      ),
    );

    _isActive = false;
    _subscription = null;

    dispose();
  }

  void cancel() {
    if (_isActive && !_wantsCanceled) {
      _wantsCanceled = true;

      // ignore: invalid_use_of_protected_member
      containErrorLog(detail: const Oration(message: 'On cancel functionality'), function: () => functionality.onCancel(manager: this));

      _itsWasGood = false;
      _lastError = NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The task was canceled, its cancellation was requested'),
      );
      _lastStackTraceError = StackTrace.current;

      _subscription?.cancel();
    }
  }

  @override
  @protected
  void checkBeforeJoining() {
    if (_wantsCanceled) {
      throw NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The task was canceled, its cancellation was requested'),
      );
    }
  }

  StreamStateTexts<R> joinManager<R>({
    required FunctionalityStreamManager<R> otherManager,
    required void Function(T) then,
    void Function(dynamic, StackTrace)? onError,
    bool errorAreFatals = true,
  }) async* {
    otherManager.joinDisponsabeObject(item: this);

    yield* textStream.map((x) => streamTextStatus<R>(x));

    if (_itsWasGood) {
      then(_lastResult as T);
    } else {
      if (onError != null) {
        onError(_lastError, _lastStackTraceError!);
      }

      if (errorAreFatals) {
        final completer = joinWaiter<T>(MaxiCompleter(waiterName: 'Functionality stream'));
        completer.completeError(_lastError, _lastStackTraceError);
        await completer.future; //<<---- equivalent to throw but with stacktrace
      }
    }
  }

  StreamState<Oration, T> checkState() {
    checkBeforeJoining();

    return checkStreamState();
  }

  @override
  void performObjectDiscard() {
    cancel();
    super.performObjectDiscard();

    // ignore: invalid_use_of_protected_member
    functionality.onManagerDispose();
  }

/*
  void onThereIsNewListener() {
    functionality.onThereIsNewListener(manager: this);
  }

  void onThereAreNoListeners() {
    functionality.onThereAreNoListeners(manager: this);
  }
  */
}
