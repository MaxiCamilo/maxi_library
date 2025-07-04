import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class MaxiTimer with IDisposable implements Timer {
  Timer? _original;
  final void Function() callback;
  Duration duration;

  DateTime? _whenActivated;

  @override
  bool get isActive => _original != null && _original!.isActive;

  @override
  int get tick => _original?.tick ?? 0;

  MaxiTimer({required this.duration, required this.callback, required bool activate}) {
    if (activate) {
      reset();
    }
  }

  void reset({Duration? newDuration}) {
    resurrectObject();

    _original?.cancel();

    if (newDuration != null) {
      duration = newDuration;
    }

    _original = Timer(duration, () {
      containErrorLog(detail: const Oration(message: 'Timeout'), function: () => callback());
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
    _original?.cancel();
    _original = null;
  }
}
