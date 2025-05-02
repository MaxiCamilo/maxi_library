import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin IStreamFunctionality<T> {
  @protected
  StreamStateTexts<T> runFunctionality({required FunctionalityStreamManager<T> manager});

  @protected
  void onThereIsNewListener({required FunctionalityStreamManager<T> manager}) {}

  @protected
  void onThereAreNoListeners({required FunctionalityStreamManager<T> manager}) {}

  @protected
  void onError({required FunctionalityStreamManager<T> manager, required NegativeResult error}) {}

  @protected
  void onDispose({required FunctionalityStreamManager<T> manager}) {}

  FunctionalityStreamManager<T> createManager() => FunctionalityStreamManager<T>(functionality: this);
  StreamStateTexts<T> runWithoutManager() => createManager().start();
  StreamStateTexts<T> runWithoutManagerInBackground() async* {
    final stream = await createManager().runInBackgrond();
    yield* stream;
  }

  Future<T> runWithoutManagerAsFuture({void Function(Oration)? onTextReceived}) {
    return waitFunctionalStream(
      stream: createManager().start(),
      onData: onTextReceived,
    );
  }

  StreamStateTexts<T> runOtherManager({required FunctionalityStreamManager manager}) async* {
    final streamController = StreamController<StreamState<Oration, T>>();
    final instance = createManager();

    maxiScheduleMicrotask(() async {
      instance.start();

      final otherDone = manager.done.whenComplete(() => instance.cancelStream());

      try {
        instance.textStream.listen((x) {
          streamController.addIfActive(streamTextStatus(x));
          manager.sendText(x);
        });
        final result = await instance.waitStreamResult();
        streamController.addIfActive(streamResult(result));
      } catch (ex, st) {
        streamController.addErrorIfActive(ex, st);
      } finally {
        otherDone.ignore();
        streamController.close();
      }
    });

    yield* streamController.stream;
  }

  Future<T> runOtherManagerAsFuture({required FunctionalityStreamManager manager, void Function(Oration)? onTextReceived}) {
    return waitFunctionalStream(
      stream: runOtherManager(manager: manager),
      onData: onTextReceived,
    );
  }
}

class FunctionalityStreamManager<T> {
  final IStreamFunctionality<T> functionality;

  bool get isActive => _streamController != null && !_streamController!.isClosed;
  bool get thereIsResult => _lastResult != null;
  bool get isCompleted => _lastError != null || _lastResult != null;
  bool get thereIsFailure => _lastError != null;

  final _completersList = <Completer>[];

  bool wasDispose = false;

  StreamController<StreamState<Oration, T>>? _streamController;
  StreamController<Oration>? _textStreamController;

  bool _wantsCanceled = false;

  T? _lastResult;
  NegativeResult? _lastError;
  Completer? _doneCompleter;

  T get result {
    if (_lastResult == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: const Oration(message: 'There is still no result'),
      );
    }
    return _lastResult!;
  }

  Stream<Oration> get textStream {
    if (wasDispose) {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: const Oration(message: 'Functionality administrator was dispose'));
    }

    _textStreamController ??= StreamController<Oration>.broadcast();
    return _textStreamController!.stream;
  }

  FunctionalityStreamManager({required this.functionality});

  Future<StreamStateTexts<T>> runInBackgrond() {
    checkProgrammingFailure(thatChecks: const Oration(message: 'The functionality is inactive'), result: () => !isActive);

    return ThreadManager.callBackgroundStream(
      parameters: InvocationParameters.only(this),
      function: _runInBackgrond<T>,
    );
  }

  Future get done {
    _doneCompleter ??= MaxiCompleter();
    return _doneCompleter!.future;
  }

  static FutureOr<Stream<StreamState<Oration, T>>> _runInBackgrond<T>(InvocationContext context) {
    final functionality = context.firts<FunctionalityStreamManager<T>>();
    return functionality.start();
  }

  void cancelStream() {
    if (isActive) {
      final error = NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The task was canceled, its cancellation was requested'),
      );
      _streamController?.addErrorIfActive(error);
      _streamController?.close();

      for (final item in _completersList) {
        item.completeErrorIfIncomplete(error);
      }
      _completersList.clear();
    }
  }

  void dispose() {
    if (wasDispose) {
      return;
    }
    cancelStream();

    _streamController?.close();
    _streamController = null;

    _textStreamController?.close();
    _textStreamController = null;

    functionality.onDispose(manager: this);

    wasDispose = true;
  }

  void sendText(Oration text) {
    _streamController?.addIfActive(streamTextStatus<T>(text));
    _textStreamController?.addIfActive(text);
  }

  Stream<StreamState<Oration, T>> continueOtherFutures() async* {
    yield checkStreamState();
    await Future.delayed(Duration.zero);
    yield checkStreamState();
  }

  Stream<StreamState<Oration, T>> start() {
    if (isActive) {
      return _streamController!.stream;
    }

    _streamController = StreamController<StreamState<Oration, T>>.broadcast(
      onListen: onThereIsNewListener,
      onCancel: onThereAreNoListeners,
    );

    maxiScheduleMicrotask(_runStream);
    return _streamController!.stream;
  }

  Future<T> waitStreamResult() {
    final stream = start();
    return waitFunctionalStream(stream: stream);
  }

  Future<R> waitFuture<R>({
    required Future<R> Function() function,
    Duration? timeout,
    FutureOr<void> Function()? onCanceled,
  }) {
    final futureWaiter = MaxiCompleter<R>();
    _completersList.add(futureWaiter);

    if (timeout == null) {
      function().then((x) {
        futureWaiter.completeIfIncomplete(x);
      }).onError((x, y) {
        futureWaiter.completeErrorIfIncomplete(x as Object, y);
        if (onCanceled != null && (x is NegativeResult && x.identifier == NegativeResultCodes.functionalityCancelled)) {
          containErrorLogAsync(detail: Oration(message: 'Canceling task'), function: onCanceled);
        }
      }).whenComplete(() => _completersList.remove(futureWaiter));
    } else {
      function()
          .then((x) {
            futureWaiter.completeIfIncomplete(x);
          })
          .timeout(timeout)
          .onError((x, y) {
            futureWaiter.completeErrorIfIncomplete(x as Object, y);
            if (onCanceled != null && (x is NegativeResult && x.identifier == NegativeResultCodes.functionalityCancelled)) {
              containErrorLogAsync(detail: Oration(message: 'Canceling task'), function: onCanceled);
            }

            containErrorLog(
              detail: Oration(message: 'Canceling task'),
              function: () => functionality.onError(
                manager: this,
                error: NegativeResult.searchNegativity(
                  item: x,
                  actionDescription: const Oration(message: 'Executing functionality'),
                  stackTrace: y,
                ),
              ),
            );
          })
          .whenComplete(() => _completersList.remove(futureWaiter));
    }

    return futureWaiter.future;
  }

  Future<void> _runStream() async {
    _wantsCanceled = false;
    try {
      _lastError = null;
      _lastResult = await waitFunctionalStream(
        stream: functionality.runFunctionality(manager: this),
        onData: (x) {
          _streamController?.addIfActive(streamTextStatus<T>(x));
          _textStreamController?.addIfActive(x);
        },
        onError: (ex) {
          _streamController?.addErrorIfActive(ex);
          _lastError = NegativeResult.searchNegativity(
            item: ex,
            actionDescription: Oration(
              message: 'An error occurred when executing the functionality "%1", the error was: "%2"',
              textParts: [runtimeType.toString(), ex.toString()],
            ),
          );
          _textStreamController?.addIfActive(_lastError!.message);
        },
        onDoneOrCanceled: (x) {
          _doneCompleter?.completeIfIncomplete(x);
          _doneCompleter = null;
        },
      );
      if (_lastResult != null) {
        _streamController?.addIfActive(streamResult(_lastResult as T));
      }
    } catch (ex) {
      _streamController?.addErrorIfActive(ex);
      _lastError = NegativeResult.searchNegativity(
        item: ex,
        actionDescription: Oration(
          message: 'An error occurred when executing the functionality "%1", the error was: "%2"',
          textParts: [runtimeType.toString(), ex.toString()],
        ),
      );
      _textStreamController?.addIfActive(_lastError!.message);
    } finally {
      _streamController?.close();
      _streamController = null;

      _doneCompleter?.completeIfIncomplete();
      _doneCompleter = null;

      dispose();
    }
  }

  StreamState<Oration, T> checkState() {
    if (_wantsCanceled) {
      throw NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: 'The task was canceled, its cancellation was requested'),
      );
    }

    return checkStreamState();
  }

  void onThereIsNewListener() {
    functionality.onThereIsNewListener(manager: this);
  }

  void onThereAreNoListeners() {
    functionality.onThereAreNoListeners(manager: this);
  }
}
