import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class SerialExecutor with IDisposable, TextableFunctionalityOperator<List> {
  final List<TextableFunctionality> functionalities;

  @override
  int identifier;

  bool _isActive = false;
  bool _wantCancel = false;
  int _lastPosition = 0;

  final List _resultList = [];

  StreamController<Oration>? _textController;
  MaxiCompleter<List>? _waiterResult;

  InteractiveFunctionalityOperator? _currentOperator;

  SerialExecutor({required this.functionalities, this.identifier = 0});

  @override
  Stream<Oration> get itemStream async* {
    start();
    yield* _textController!.stream;
  }

  @override
  void start() {
    if (_isActive) {
      return;
    }

    resurrectObject();
    _textController ??= StreamController<Oration>();
    _wantCancel = false;

    maxiScheduleMicrotask(_runSerialExecutor);

    _isActive = true;
  }

  void reset() {
    _lastPosition = 0;
    _resultList.clear();
    start();
  }

  @override
  void cancel() {
    _lastPosition = 0;
    _wantCancel = true;
    if (!_isActive) {
      dispose();
    }
  }

  @override
  void performObjectDiscard() {
    _lastPosition = 0;

    _waiterResult?.completeErrorIfIncomplete(
        NegativeResult(
          identifier: NegativeResultCodes.functionalityCancelled,
          message: const Oration(message: 'The task was canceled'),
        ),
        StackTrace.current);
    _waiterResult = null;

    _currentOperator?.dispose();
    _currentOperator = null;

    _textController?.close();
    _textController = null;

    _resultList.clear();
  }

  @override
  MaxiFuture<List> waitResult({void Function(Oration item)? onItem}) {
    start();

    if (onItem != null) {
      _textController!.stream.listen(onItem);
    }

    _waiterResult ??= MaxiCompleter<List>();
    return _waiterResult!.future;
  }

  Future<void> _runSerialExecutor() async {
    bool itsComplete = true;

    while (_lastPosition < functionalities.length) {
      try {
        if (_wantCancel) {
          throw NegativeResult(
            identifier: NegativeResultCodes.functionalityCancelled,
            message: const Oration(message: 'The task was canceled'),
          );
        }

        final function = functionalities[_lastPosition];

        final functionOperator = function.createOperator(identifier: identifier);
        _currentOperator = functionOperator;
        final result = await functionOperator.waitResult(onItem: (item) => _textController?.addIfActive(item));
        _resultList.add(result);
        _lastPosition += 1;
      } catch (ex, st) {
        itsComplete = false;
        _waiterResult?.completeErrorIfIncomplete(ex, st);
        break;
      } finally {
        _currentOperator = null;
      }
    }

    if (itsComplete) {
      _waiterResult?.completeIfIncomplete(_resultList);
      dispose();
    } else {
      _textController?.close();
      _textController = null;
    }
  }
}
