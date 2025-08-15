import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class MaxiTimer with IDisposable implements Timer {
  Timer? _original;
  final void Function()? callback;
  final void Function()? onCancel;
  Duration duration;
  bool _finished = false;

  DateTime? _whenActivated;

  MaxiCompleter<bool>? _waiter;

  @override
  bool get isActive => _original != null && _original!.isActive;

  @override
  int get tick => _original?.tick ?? 0;

  MaxiTimer({required bool activate, required this.duration, this.callback, this.onCancel}) {
    if (activate) {
      reset();
    }
  }

  void reset({Duration? newDuration}) {
    resurrectObject();

    _original?.cancel();

    _finished = false;
    if (newDuration != null) {
      duration = newDuration;
    }

    _original = Timer(duration, () {
      _finished = true;
      _waiter?.completeIfIncomplete(true);
      _waiter = null;
      if (callback != null) {
        containErrorLog(detail: const Oration(message: 'Timeout'), function: () => callback!());
      }
      dispose();
    });
    _whenActivated = DateTime.now();
  }

  void resetIfCurrentDurationIsLower({required Duration newDuration}) {
    if (!isActive || duration < newDuration || _whenActivated == null || DateTime.now().millisecondsSinceEpoch - _whenActivated!.millisecondsSinceEpoch < newDuration.inMilliseconds) {
      reset(newDuration: newDuration);
    }
  }

  @override
  void cancel() {
    dispose();
  }

  @override
  void performObjectDiscard() {
    if (!_finished && _original != null) {
      _waiter?.completeIfIncomplete(false);
      _waiter = null;
      if (onCancel != null) {
        onCancel!();
      }
    }

    _original?.cancel();
    _original = null;
  }

  MaxiFuture<bool> waitTimeout({Duration? newDuration}) {
    reset(newDuration: newDuration);

    _waiter ??= MaxiCompleter<bool>();
    return _waiter!.future;
  }
}
