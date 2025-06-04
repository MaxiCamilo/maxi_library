import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class ChannelInteractableFunctionality<I, R> with IDisposable, PaternalFunctionality, InteractableFunctionalityExecutor<I, R> {
  @override
  int identifier;

  final InteractableFunctionality<I, R> functionality;
  final IChannel channel;
  final bool closeIfItEnd;

  bool _isActive = false;

  Completer? _onCanceled;

  ChannelInteractableFunctionality({
    required this.channel,
    required this.functionality,
    this.closeIfItEnd = true,
    this.identifier = 0,
  });

  void start() {
    if (_isActive) {
      return;
    }
    checkProgrammingFailure(thatChecks: const Oration(message: 'Channel is active'), result: () => channel.isActive);
    _isActive = true;

    channel.done.whenComplete(_whenChannelDone);
    maxiScheduleMicrotask(_startFunctionality);
  }

  Future<void> _startFunctionality() async {
    _isActive = true;
    await continueOtherFutures();

    R? result;
    NegativeResult? error;

    try {
      // ignore: invalid_use_of_protected_member
      result = await functionality.runFunctionality(manager: this);
      channel.addIfActive(FunctionalityResult<R>(result: result as R, idetifier: identifier));
    } catch (ex, st) {
      // ignore: invalid_use_of_protected_member
      error = functionality.castError(manager: this, rawError: ex, stackTrace: st);
      // ignore: invalid_use_of_protected_member
      containErrorLog(detail: const Oration(message: 'On Error functionality'), function: () => functionality.onError(error: error!, manager: this, stackTrace: st));
      channel.addIfActive(FunctionalityError(error: error, idetifier: identifier, stackTrace: st));
    }

    // ignore: invalid_use_of_protected_member
    containErrorLog(detail: const Oration(message: 'On Finish functionality'), function: () => functionality.onFinish(manager: this, possibleError: error, possibleResult: result));

    await continueOtherFutures();
    if (closeIfItEnd) {
      containErrorLog(detail: const Oration(message: 'On close channel'), function: () => channel.close());
    }

    _isActive = false;
  }

  void _whenChannelDone() {
    if (!_isActive) {
      return;
    }

    // ignore: invalid_use_of_protected_member
    containErrorLog(detail: const Oration(message: 'On cancel functionality'), function: () => functionality.onThereAreNoListeners(manager: this));
    _onCanceled?.completeIfIncomplete();
    _onCanceled = null;
  }

  @override
  void performObjectDiscard() {
    super.performObjectDiscard();

    // ignore: invalid_use_of_protected_member
    containErrorLog(detail: const Oration(message: 'On cancel functionality'), function: () => functionality.onManagerDispose());
  }

  @override
  void checkActivity() {
    // ignore: invalid_use_of_protected_member
    if (!channel.isActive && functionality.cancelIfItsInactive) {
      throw NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: const Oration(message: ''),
      );
    }
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
  void sendItem(I item) {
    checkActivity();
    channel.addIfActive(FunctionalityItem<I>(item: item, idetifier: identifier));
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
}
