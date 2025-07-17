import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

class MaxiSocket with StartableFunctionality, PaternalFunctionality, FunctionalityWithLifeCycle, IChannel<List<int>, List<int>> {
  final String address;
  final int port;
  final Duration timeout;
  final Duration activeConnectionTime;

  late StreamController<List<int>> _receiverController;

  late Semaphore _shippingSynchronizer;
  late Semaphore _waiterSynchronizer;

  Socket? _socket;
  Completer<List<int>>? _waitingData;
  MaxiTimer? _activeConnection;

  @override
  bool get isActive => isInitialized;

  @override
  Stream<List<int>> get receiver async* {
    await initialize();
    yield* _receiverController.stream;
  }

  MaxiSocket({required this.address, required this.port, required this.timeout, required this.activeConnectionTime});

  @override
  Future<void> afterInitializingFunctionality() async {
    _receiverController = createEventController<List<int>>(isBroadcast: true);

    _shippingSynchronizer = Semaphore();
    _waiterSynchronizer = Semaphore();
    _activeConnection = createTimer(
        duration: activeConnectionTime,
        callback: () {
          _socket?.close();
        });

    _socket = await Socket.connect(address, port, timeout: timeout);
    _socket!.done.whenComplete(() => dispose());
    _socket!.listen(
      _onSocketReceivedData,
      onDone: () => close(),
      onError: (x, y) {
        log(x.toString());
        close();
      },
    );
  }

  @protected
  @mustCallSuper
  void _onSocketReceivedData(Uint8List event) {
    _receiverController.addIfActive(event);
    _waitingData?.completeIfIncomplete(event);
    _waitingData = null;
  }

  @override
  void afterDiscard() {
    super.afterDiscard();

    _shippingSynchronizer.cancel();
    _waiterSynchronizer.cancel();

    _socket?.close();
    _socket?.destroy();
    _socket = null;
  }

  @mustCallSuper
  Future<void> addAsync(List<int> event) async {
    await initialize();
    await _shippingSynchronizer.execute(function: () async {
      _activeConnection?.reset();
      _socket!.add(Uint8List.fromList(event));
      await _socket!.flush();
    });
  }

  @override
  void add(List<int> event) {
    addAsync(event);
  }

  Future<List<int>> addAndWaitData({required List<int> data, bool disconnectIfItFails = true, Duration? timeout}) async {
    await initialize();

    return await _waiterSynchronizer.execute(function: () async {
      _waitingData = joinWaiter<List<int>>();

      try {
        await addAsync(data);
        _activeConnection?.resetIfCurrentDurationIsLower(newDuration: timeout ?? this.timeout);
        return await _waitingData!.future.timeout(
          timeout ?? this.timeout,
          onTimeout: () {
            throw NegativeResult(
              identifier: NegativeResultCodes.timeout,
              message: const Oration(message: 'The device took too long to return a response'),
            );
          },
        );
      } catch (_) {
        if (disconnectIfItFails) {
          dispose();
        }
        rethrow;
      } finally {
        _waitingData = null;
      }
    });
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future close() async {
    dispose();
  }
}
