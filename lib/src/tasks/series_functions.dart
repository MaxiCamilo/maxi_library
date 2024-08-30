import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

class SeriesFunctions with IFunctionalControllerForTask {
  final List<IFunctionalTask> functions;

  SeriesFunctions({required this.functions});

  final _results = [];

  int _position = 0;
  bool _isCanceled = false;
  Completer? _waiter;
  Timer? _timer;

  void restart() {
    _position = 0;
    _results.clear();
  }

  Future<List> execute() async {
    _isCanceled = false;

    while (_position >= _results.length) {
      final function = functions[_position];

      try {
        if (function is IFunctionalTaskSerie) {
          function.setSeriesOperator(seriesOperator: this, previousResult: _position == 0 ? null : _results.last);
        }

        final result = await function.executeTask(this);
        _results.add(result);
        _position += 1;
      } catch (ex) {
        final nr = NegativeResult.searchNegativity(item: ex, actionDescription: trc('Module number %1', [_position + 1]));
        throw nr;
      }
    }

    return _results;
  }

  void cancel() {
    _isCanceled = true;
    interruptWait();
  }

  @override
  void interruptWait() {
    _timer?.cancel();
    _waiter?.complete();

    _timer = null;
    _waiter = null;
  }

  @override
  @protected
  void checkState() {
    if (_isCanceled) {
      throw NegativeResult(
        identifier: NegativeResultCodes.functionalityCancelled,
        message: tr('The functionality was canceled'),
      );
    }
  }

  @override
  @protected
  Future<void> wait(Duration duration) async {
    checkState();

    _waiter = Completer();
    _timer = Timer(duration, interruptWait);

    await _waiter!.future;
    checkState();
  }
}
