import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class MasterChannel<R, S> with IDisposable, IChannel<R, S>, IMasterChannel<R, S> {
  final bool closeIfEveryoneClosed;

  final _receiverController = StreamController<R>.broadcast();
  final _childrenChannels = <ISlaveChannel<S, R>>[];

  Completer? _waiterNewConnection;

  @override
  bool get isActive => !wasDiscarded;

  @override
  Stream<R> get receiver => _receiverController.stream;

  MasterChannel({required this.closeIfEveryoneClosed});

  @override
  ISlaveChannel<S, R> createSlave() {
    checkIfDispose();
    final slave = SlaveChannel<S, R>(master: this);

    _childrenChannels.add(slave);
    slave.done.whenComplete(() => _reactChannelClose(slave));

    _waiterNewConnection?.completeIfIncomplete();
    _waiterNewConnection = null;

    return slave;
  }

  @override
  ISlaveChannel<S, R> createSlaveFromBuilder(ISlaveChannel<S, R> Function(IMasterChannel<R, S>) function) {
    checkIfDispose();
    final slave = function(this);
    _childrenChannels.add(slave);
    slave.done.whenComplete(() => _reactChannelClose(slave));
    return slave;
  }

  @override
  void add(S event) {
    checkActivityBefore(() {});
    if (_childrenChannels.isEmpty) {
      log('[BidirectionalChannelMaster] ¡There are no children channels!');
      return;
    }

    _childrenChannels.iterar((x) => x.addFromMaste(event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    checkActivityBefore(() {});
    if (_childrenChannels.isEmpty) {
      log('[BidirectionalChannelMaster] ¡There are no children channels!');
      return;
    }

    _childrenChannels.iterar((x) => x.addErrorFromMaste(error, stackTrace));
  }

  @override
  Future close() async {
    dispose();
  }

  @override
  void performObjectDiscard() {
    _receiverController.close();
    _childrenChannels.iterar((x) => x.close());
    _childrenChannels.clear();

    _waiterNewConnection?.completeErrorIfIncomplete(NegativeResult(
      identifier: NegativeResultCodes.functionalityCancelled,
      message: const Oration(message: 'The Master channel is being closed'),
    ));
    _waiterNewConnection = null;
  }

  @override
  Future get done => onDispose;

  void _reactChannelClose(ISlaveChannel<S, R> channel) {
    _childrenChannels.remove(channel);
    if (closeIfEveryoneClosed && _childrenChannels.isEmpty) {
      close();
    }
  }

  @override
  void addErrorFromSlave(Object error, [StackTrace? stackTrace]) {
    _receiverController.addErrorIfActive(error, stackTrace);
  }

  @override
  void addFromSlave(R item) {
    _receiverController.addIfActive(item);
  }

  @override
  Future<void> waitForNewConnection({required bool omitIfAlreadyConnection}) async {
    checkActivityBefore(() {});

    if (omitIfAlreadyConnection && _childrenChannels.isNotEmpty) {
      return;
    }

    if (_waiterNewConnection == null || _waiterNewConnection!.isCompleted) {
      _waiterNewConnection = MaxiCompleter();
    }

    return await _waiterNewConnection!.future;
  }
}
