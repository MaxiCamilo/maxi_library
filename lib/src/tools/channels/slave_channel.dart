import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class SlaveChannel<R, S> with IChannel<R, S>, ISlaveChannel<R, S> {
  final IMasterChannel<S, R> _master;
  final _waiter = MaxiCompleter();
  final _masterStreamController = StreamController<R>.broadcast();

  bool _isActive = true;

  SlaveChannel({required IMasterChannel<S, R> master}) : _master = master {
    _master.checkActivityBefore(() {});
  }

  @override
  void add(S event) {
    checkActivityBefore(() {});
    _master.addFromSlave(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkActivityBefore(() {});
    _master.addErrorFromSlave(error, stackTrace);
  }

  @override
  Future close() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    _masterStreamController.close();
    _waiter.completeIfIncomplete();
  }

  @override
  Future get done => _waiter.future;

  @override
  bool get isActive => _isActive;

  @override
  Stream<R> get receiver => _masterStreamController.stream;

  @override
  void addErrorFromMaste(Object error, [StackTrace? stackTrace]) {
    _masterStreamController.addErrorIfActive(error, stackTrace);
  }

  @override
  void addFromMaste(R item) {
    _masterStreamController.addIfActive(item);
  }

  @override
  void closeMasterChannel() {
    _master.close();
  }
}
