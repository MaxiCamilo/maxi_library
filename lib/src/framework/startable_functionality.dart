import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin StartableFunctionality {
  @protected
  Future<void> initializeFunctionality();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

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
      await initializeFunctionality();
      _isInitialized = true;
      _semaphore = null;
    });
  }

  void declareDeinitialized() {
    _isInitialized = false;
  }
}
