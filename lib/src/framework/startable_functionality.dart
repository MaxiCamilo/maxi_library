import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin StartableFunctionality implements IDisposable {
  @protected
  Future<void> initializeFunctionality();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool get itIsInitializing => _semaphore != null && _semaphore!.isActive;

  @override
  bool get wasDiscarded => !_isInitialized;

  Semaphore? _semaphore;
  Completer? _onDisposeCompleter;
  Completer? _onInitializedCompleter;

  Future<dynamic> get onDispose {
    _onDisposeCompleter ??= MaxiCompleter();
    return _onDisposeCompleter!.future;
  }

  Future<dynamic> get onInitialized async {
    if (isInitialized) {
      return this;
    }
    _onInitializedCompleter ??= MaxiCompleter();
    return await _onInitializedCompleter!.future;
  }

  void checkInitialize() {
    if (!_isInitialized) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: Oration(message: 'The functionality is uninitialized and cannot be used'),
      );
    }
  }

  T checkFirstIfInitialized<T>(T Function() function) {
    checkInitialize();
    return function();
  }

  Future<T> executeWhenInitialized<T>(FutureOr<T> Function() function) async {
    if (isInitialized) {
      return await function();
    }

    await initialize();
    return await function();
  }

  Future<void> initializeIfInactive() async {
    if (!isInitialized && _semaphore == null) {
      await initialize();
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _semaphore ??= Semaphore();

    await _semaphore!.execute(function: () async {
      if (_isInitialized) {
        return;
      }
      try {
        await initializeFunctionality();
        reactWhenInitializedFinishes();
        _semaphore = null;
        _onInitializedCompleter?.completeIfIncomplete(this);
        _onInitializedCompleter = null;
      } catch (ex, st) {
        reactWhenItFails(ex, st);
        reactWhenInitializedFinishes();
        _semaphore = null;
        rethrow;
      }
      _isInitialized = true;
      _semaphore = null;
    });
  }

  @override
  void dispose() {
    if (_isInitialized) {
      containErrorLog(detail: const Oration(message: 'Dispose object'), function: performObjectDiscard);
      _onDisposeCompleter?.completeIfIncomplete();
      _onDisposeCompleter = null;
      _isInitialized = false;
    }
  }

  @override
  void performObjectDiscard() {}

  void reactWhenItFails(dynamic error, StackTrace trace) {}
  void reactWhenInitializedFinishes() {}
}
