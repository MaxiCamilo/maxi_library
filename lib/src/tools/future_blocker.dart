import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class FutureBlocker {
  int _passing = 0;
  int _blocking = 0;

  final _lockSynchronizer = Semaphore();

  bool _isLocked = false;

  Completer? _waitingPassFinish;

  late Completer _waitingUnlocked;

  Future<T> pass<T>({required Future<T> Function() function}) async {
    if (_isLocked) {
      await _waitingUnlocked.future;
    }

    _passing += 1;

    try {
      return await function();
    } finally {
      _passing -= 1;

      if (_passing <= 0 && _waitingPassFinish != null) {
        _waitingPassFinish!.complete();
        _waitingPassFinish = null;
      }
    }
  }

  Stream<T> passStream<T>({required Future<Stream<T>> Function() function}) async* {
    if (_isLocked) {
      await _waitingUnlocked.future;
    }

    _passing += 1;

    try {
      final stream = await function();
      yield* stream;
    } finally {
      _passing -= 1;

      if (_passing <= 0 && _waitingPassFinish != null) {
        _waitingPassFinish!.complete();
        _waitingPassFinish = null;
      }
    }
  }

  Future<T> block<T>({required Future<T> Function() function}) async {
    if (!_isLocked) {
      _isLocked = true;
      _waitingUnlocked = Completer();
    }

    if (_passing > 0) {
      _waitingPassFinish ??= Completer();
      await _waitingPassFinish!.future;
    }

    _blocking += 1;

    try {
      return await _lockSynchronizer.execute(function: function);
    } finally {
      _blocking -= 1;

      if (_blocking <= 0) {
        _isLocked = false;
        _waitingUnlocked.complete();
      }
    }
  }

  Stream<T> blockStream<T>({required Future<Stream<T>> Function() function}) async* {
    if (!_isLocked) {
      _isLocked = true;
      _waitingUnlocked = Completer();
    }

    if (_passing > 0) {
      _waitingPassFinish ??= Completer();
      await _waitingPassFinish!.future;
    }

    _blocking += 1;

    try {
      yield* _lockSynchronizer.executeFutureStream(function: function);
    } finally {
      _blocking -= 1;

      if (_blocking <= 0) {
        _isLocked = false;
        _waitingUnlocked.complete();
      }
    }
  }
}
