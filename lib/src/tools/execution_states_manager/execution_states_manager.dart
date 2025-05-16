import 'package:maxi_library/maxi_library.dart';

class ExecutionStatesManager<T> {
  final List<IExecutionStatesManagerPoint<T>> _statesList;

  final _semaphore = Semaphore();

  late T _status;

  T get status => _status;

  set status(T newStatus) => changeStatus(newStatus);

  List<IExecutionStatesManagerPoint<T>> _activeStates = [];
  List<IExecutionStatesManagerPoint<T>> _progressStates = [];
  bool _isProgress = false;

  ExecutionStatesManager({required T defaultState, List<IExecutionStatesManagerPoint<T>> statesList = const []})
      : _status = defaultState,
        _statesList = statesList.cast<IExecutionStatesManagerPoint<T>>().toList();

  bool thereAreStates(T value) => _statesList.any((x) => x.isThisPoint(value));

  Future<void> changeStatus(T newStatus) async {
    if (newStatus == _status) {
      return;
    }
    await _cancelChange();
    return await _semaphore.execute(function: () => _changeStatusAsegurated(newStatus));
  }

  Future<bool> addState({required IExecutionStatesManagerPoint<T> point, bool activateIfItsStatus = true, bool desactivateIfNotItsStatus = true, bool joinIfItsDisponsable = true}) async {
    if (joinIfItsDisponsable && point is IDisposable) {
      (point as IDisposable).onDispose.whenComplete(() => removeStatus(point: point, desactivate: false));
    }

    if (point.isThisPoint(_status)) {
      if (activateIfItsStatus) {
        await point.declareActive(_status);
      }
      _statesList.add(point);
      return true;
    } else {
      if (desactivateIfNotItsStatus) {
        await point.declareInactive();
      }
      _statesList.add(point);
      return false;
    }
  }

  Future<void> removeStatus({
    required IExecutionStatesManagerPoint<T> point,
    bool desactivate = true,
  }) async {
    if (desactivate) {
      await containErrorLogAsync(detail: const Oration(message: 'Desactive states'), function: () => point.declareInactive());
    }
    _statesList.remove(point);
    _activeStates.remove(point);
  }

  Future<bool> removeAllStatusByValue({
    required T value,
    bool desactivate = true,
  }) async {
    final status = _statesList.where((x) => x.isThisPoint(value)).toList();
    status.iterar((x) {
      _statesList.remove(x);
      _activeStates.remove(x);
      _progressStates.remove(x);
    });

    if (desactivate && status.isNotEmpty) {
      await Future.wait(status.map((x) => containErrorLogAsync(detail: const Oration(message: 'Desactive states'), function: () => x.declareInactive())).toList());
    }

    return status.isNotEmpty;
  }

  Future<void> removeAllStatus({bool desactivate = true}) async {
    _statesList.clear();

    if (desactivate) {
      await Future.wait(_progressStates.map((x) => containErrorLogAsync(detail: const Oration(message: 'Desactive states'), function: () => x.declareInactive())).toList());
      _progressStates = [];
      await Future.wait(_activeStates.map((x) => containErrorLogAsync(detail: const Oration(message: 'Desactive states'), function: () => x.declareInactive())).toList());
      _activeStates.clear();
    } else {
      _progressStates = [];
      _activeStates.clear();
    }
  }

  Future<void> _cancelChange() async {
    if (_isProgress) {
      _isProgress = false;
      _progressStates.iterar((x) => x.declareInactive());
    }
  }

  Future<void> _changeStatusAsegurated(T newStatus) async {
    if (newStatus == _status) {
      return;
    }

    _isProgress = true;
    _status = newStatus;
    await Future.wait(_activeStates.where((x) => !x.isThisPoint(newStatus)).map((x) => containErrorLogAsync(detail: const Oration(message: 'Desactive states'), function: () => x.declareInactive())).toList());
    _activeStates = [];
    _progressStates = [];

    final newActiveStates = _statesList.where((x) => x.isThisPoint(newStatus)).toList();
    if (newActiveStates.isEmpty || !_isProgress) {
      _isProgress = false;
      return;
    }

    _progressStates = newActiveStates;
    await Future.wait(_progressStates.map((x) => containErrorLogAsync(detail: const Oration(message: 'Activate states'), function: () => x.declareActive(newStatus))).toList());

    if (!_isProgress) {
      _progressStates = [];
      return;
    }

    _activeStates = _progressStates;
    _progressStates = [];
    _isProgress = false;
  }
}
