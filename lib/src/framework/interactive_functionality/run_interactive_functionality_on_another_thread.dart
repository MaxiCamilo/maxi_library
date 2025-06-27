import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class _RunInteractiveFunctionalityOnAnotherThreadOk {
  const _RunInteractiveFunctionalityOnAnotherThreadOk();
}

class _RunInteractiveFunctionalityOnAnotherThreadFunctionality<I, R> {
  final InteractiveFunctionality<I, R> anotherFunctionality;
  final int identifier;

  const _RunInteractiveFunctionalityOnAnotherThreadFunctionality({required this.anotherFunctionality, required this.identifier});
}

class _RunInteractiveFunctionalityOnAnotherThreadItem<I> {
  final I item;
  const _RunInteractiveFunctionalityOnAnotherThreadItem(this.item);
}

class _RunInteractiveFunctionalityOnAnotherThreadResult<R> {
  final R result;
  const _RunInteractiveFunctionalityOnAnotherThreadResult(this.result);
}

class _RunInteractiveFunctionalityOnAnotherThreadError {
  final dynamic error;
  final StackTrace stackTrace;
  const _RunInteractiveFunctionalityOnAnotherThreadError(this.error, this.stackTrace);
}

class _RunInteractiveFunctionalityOnAnotherThreadCancel {
  const _RunInteractiveFunctionalityOnAnotherThreadCancel();
}

class RunInteractiveFunctionalityOnAnotherThread<I, R> with InteractiveFunctionality<I, R> {
  final InteractiveFunctionality<I, R> anotherFunctionality;
  final IThreadInvoker thread;

  static const int _secondsWait = 70;

  IChannel? _actualChannel;
  final _synchronizer = Semaphore();
  final _waitResult = MaxiCompleter<R>();

  RunInteractiveFunctionalityOnAnotherThread({required this.anotherFunctionality, required this.thread});

  @override
  void onFinish({required InteractiveFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {
    super.onFinish(manager: manager, possibleResult: possibleResult, possibleError: possibleError);
    _actualChannel?.close();
    _actualChannel = null;
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);

    _actualChannel?.addIfActive(const _RunInteractiveFunctionalityOnAnotherThreadCancel());

    Future.delayed(const Duration(seconds: 10)).whenComplete(() async {
      _actualChannel?.close();
      _actualChannel = null;
    });
  }

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    if (_waitResult.isCompleted) {
      return await _waitResult.future;
    }

    await _synchronizer.execute(function: () async {
      if (_actualChannel == null) {
        _actualChannel = await thread.createChannel(function: _invokeViaChannel<I, R>);
        await _waitOk(); //1
        _actualChannel!.addIfActive(_RunInteractiveFunctionalityOnAnotherThreadFunctionality<I, R>(anotherFunctionality: anotherFunctionality, identifier: manager.identifier));
        await _waitOk(); //2
      }
    });

    _actualChannel!.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadItem<I>>().listen((x) => manager.sendItem(x.item));
    _actualChannel!.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadResult<R>>().listen((x) {
      _waitResult.completeIfIncomplete(x.result);
      _actualChannel?.addIfActive(const _RunInteractiveFunctionalityOnAnotherThreadOk());
    });
    _actualChannel!.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadError>().listen((x) {
      _waitResult.completeErrorIfIncomplete(x.error, x.stackTrace);
      _actualChannel?.addIfActive(const _RunInteractiveFunctionalityOnAnotherThreadOk());
    });

    _actualChannel!.done.whenComplete(() {
      if (!_waitResult.isCompleted) {
        _waitResult.completeErrorIfIncomplete(NegativeResult(identifier: NegativeResultCodes.functionalityCancelled, message: const Oration(message: 'The functionality communication channel was closed')));
      }
    });

    return _waitResult.future;
  }

  Future<void> _waitOk() {
    return _actualChannel!.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadOk>().waitItem(timeout: const Duration(seconds: _secondsWait));
  }

  static Future<void> _invokeViaChannel<I, R>(InvocationContext context, IChannel channel) async {
    await continueOtherFutures();
    scheduleMicrotask(() {
      channel.addIfActive(const _RunInteractiveFunctionalityOnAnotherThreadOk()); //1
    });

    final package = await channel.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadFunctionality<I, R>>().waitItem(timeout: const Duration(seconds: _secondsWait));
    channel.addIfActive(const _RunInteractiveFunctionalityOnAnotherThreadOk()); //2
    await continueOtherFutures();

    final id = package.identifier;
    final functionality = package.anotherFunctionality;

    final newOperator = functionality.createOperator(identifier: id);

    channel.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadCancel>().listen((_) => newOperator.cancel());

    if (functionality.cancelIfItsInactive) {
      channel.done.whenComplete(() {
        newOperator.cancel();
      });
    }

    try {
      final result = await newOperator.waitResult(onItem: (x) => channel.addIfActive(_RunInteractiveFunctionalityOnAnotherThreadItem<I>(x)));
      channel.addIfActive(_RunInteractiveFunctionalityOnAnotherThreadResult<R>(result));
      await continueOtherFutures();
    } catch (ex, st) {
      channel.addIfActive(_RunInteractiveFunctionalityOnAnotherThreadError(ex, st));
      await continueOtherFutures();
    } finally {
      await containErrorAsync(function: () => channel.receiver.whereType<_RunInteractiveFunctionalityOnAnotherThreadOk>().waitSomething(timeout: const Duration(seconds: 5)));
      channel.close();
    }
  }
}
