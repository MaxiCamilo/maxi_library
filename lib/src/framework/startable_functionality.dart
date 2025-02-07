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

  void checkInitialize() {
    if (!_isInitialized) {
      throw NegativeResult(
        identifier: NegativeResultCodes.uninitializedFunctionality,
        message: tr('The functionality is uninitialized and cannot be used'),
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
      performObjectDiscard();
      _isInitialized = false;
    }
  }

  @override
  void performObjectDiscard() {}

  void reactWhenItFails(dynamic error, StackTrace trace) {}
  void reactWhenInitializedFinishes() {}
}
