import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/error_handling/cancel.dart';

class ExecutionController with IFunctionalControllerForTask, IFunctionalControllerForOperator,IFunctionalController {
  Completer? _condenser;
  Timer? _timer;

  bool _wantCancel = false;
  bool _wantReset = false;

  @override
  void prepareInit() {
    _wantCancel = false;
    _wantReset = false;
  }

  @override
  void checkState() {
    if (_wantCancel || _wantReset) {
      throw Cancel(wantReset: _wantReset);
    }
  }

  @override
  Future<void> wait(Duration duration) async {
    checkState();

    _condenser = MaxiCompleter();
    _timer = Timer(duration, _reactTimeout);

    await _condenser!.future;
    _condenser = null;
    _timer = null;

    checkState();
  }

  @override
  void cancel() {
    _wantCancel = true;
    interruptWait();
  }

  @override
  void reset() {
    _wantReset = true;
    interruptWait();
  }

  @override
  void interruptWait() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void _reactTimeout() {
    if (_condenser != null && !_condenser!.isCompleted) {
      _condenser?.complete();
    }
  }
}
