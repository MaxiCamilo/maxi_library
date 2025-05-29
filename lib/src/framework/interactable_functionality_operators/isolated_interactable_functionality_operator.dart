import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/singletons/isolated_interacting_functionalities_manager.dart';

class IsolatedInteractableFunctionalityOperator<I, R> with IDisposable, InteractableFunctionalityOperator<I, R> {
  final FutureOr<IThreadInvoker> Function() _invokerGetter;
  final InteractableFunctionality<I, R> _functionality;

  final _waiter = MaxiCompleter<R>();

  int _identifier = 0;

  bool _ended = false;

  IThreadInvoker? _invoker;

  final _executionWaiter = MaxiCompleter();

  //bool _itsWasGood = false;
  //bool _itsWantCancel = false;

  //late R _lastResult;
  //late NegativeResult _lastError;
  //late StackTrace _stackTrace;

  StreamController<I>? _itemStreanController;

  @override
  int get identifier => _identifier;

  IsolatedInteractableFunctionalityOperator({required FutureOr<IThreadInvoker> Function() invokerGetter, required InteractableFunctionality<I, R> functionality})
      : _invokerGetter = invokerGetter,
        _functionality = functionality {
    maxiScheduleMicrotask(_createInInvoker);
  }

  Future<void> _createInInvoker() async {
    try {
      _invoker = await _invokerGetter();
      _identifier = await _invoker!.callFunction(parameters: InvocationParameters.only(_functionality), function: _createOnThread<I, R>);
      IsolatedInteractingFunctionalitiesManager.singleton.asignExternal(this);
      _executionWaiter.complete();
    } catch (ex, st) {
      _executionWaiter.completeErrorIfIncomplete(ex, st);
      receiveError(
        error: NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Execute functionality in ohter thread')),
        stackTrace: st,
      );
    }
  }

  static int _createOnThread<I, R>(InvocationContext context) {
    return IsolatedInteractingFunctionalitiesManager.singleton.mounthFunctionality<I, R>(
      functionality: context.firts<InteractableFunctionality<I, R>>(),
      invoker: context.sender,
    );
  }

  @override
  void cancel() {
    if (_ended) {
      return;
    }

    _executionWaiter.future.whenComplete(() {
      if (identifier == 0) {
        return;
      }

      //_ended = true;
      _invoker?.callFunction(parameters: InvocationParameters.only(_identifier), function: _cancelOnThread);
    });
  }

  static void _cancelOnThread(InvocationContext parameters) {
    IsolatedInteractingFunctionalitiesManager.singleton.cancelFunctionality(parameters.firts<int>());
  }

  @override
  Stream<I> get itemStream async* {
    if (_ended) {
      return;
    }

    _itemStreanController ??= StreamController<I>.broadcast();
    yield* _itemStreanController!.stream;
  }

  @override
  void start() {}

  @override
  MaxiFuture<R> waitResult({void Function(I)? onItem}) {
    if (_ended) {
      return _waiter.future;
    }

    if (onItem != null) {
      itemStream.listen(onItem);
    }

    return _waiter.future;
  }

  void receiveItem(dynamic item) {
    if (_ended) {
      return;
    }

    if (item is I) {
      _itemStreanController?.addIfActive(item);
    } else {
      log('[IsolatedInteractableFunctionalityOperator N° $identifier] item is ${item.runtimeType}, but $I only accept');
    }
  }

  void receiveResult(dynamic result) {
    if (_ended) {
      log('[IsolatedInteractableFunctionalityOperator N° $identifier] The operator has already finished!');
      return;
    }

    if (result is R) {
      // _lastResult = result;
      // _itsWasGood = true;
      _ended = true;
      _waiter.completeIfIncomplete(result);

      dispose();
    } else {
      receiveError(
        error: NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: Oration(
            message: 'The functionality expected a result of type %1, but a result of type %2 was received',
            textParts: [R, result.runtimeType],
          ),
        ),
        stackTrace: StackTrace.current,
      );
    }
  }

  void receiveError({required NegativeResult error, required StackTrace stackTrace}) {
    if (_ended) {
      log('[IsolatedInteractableFunctionalityOperator N° $identifier] The operator has already finished!');
      return;
    }
    _ended = true;
    //_itsWasGood = false;
    //_lastError = error;
    //_stackTrace = stackTrace;

    _waiter.completeErrorIfIncomplete(error, stackTrace);

    dispose();
  }

  @override
  void performObjectDiscard() {
    _ended = true;

    _itemStreanController?.close();
    _itemStreanController = null;

    _waiter.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.discontinuedFunctionality, message: const Oration(message: 'The operator was discarded')));
  }
}
