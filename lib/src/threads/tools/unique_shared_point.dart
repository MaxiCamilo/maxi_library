import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class UniqueSharedPoint<T> with ISharedPointer<T>, StartableFunctionality, PaternalFunctionality {
  final String name;

  late IsolatedValue<SharedPointer<T>> _isolator;

  bool _thereIsMainPointer = false;

  SharedPointerInstance<T>? _masterInstance;

  bool get isMaster => _thereIsMainPointer;

  UniqueSharedPoint({required this.name});

  final _semaphore = Semaphore();

  @override
  Future<void> initializeFunctionality() async {
    _masterInstance = null;
    _thereIsMainPointer = false;
    _isolator = joinObject(item: IsolatedValue<SharedPointer<T>>(name: 'MxLib.pointers.$name'));
    await _isolator.initialize();
  }

  Future<void> defineAsSourcePointer({required T value, bool errorIfDefined = true}) {
    return _semaphore.execute(function: () => _defineAsSourcePointerInsecure(value: value, errorIfDefined: errorIfDefined));
  }

  Future<void> _defineAsSourcePointerInsecure({required T value, required bool errorIfDefined}) async {
    await initialize();
    if (!_thereIsMainPointer && errorIfDefined && _isolator.isDefined) {
      throw NegativeResult(
        identifier: NegativeResultCodes.contextInvalidFunctionality,
        message: Oration(
          message: 'The %1 pointer was already defined by another thread',
          textParts: [name],
        ),
      );
    }

    final newMaster = joinObject(item: SharedPointerInstance<T>(item: value));
    _thereIsMainPointer = false;
    _masterInstance?.dispose();
    _masterInstance = null;

    try {
      await _isolator.changeValue(newMaster.createPointer());
      await continueOtherFutures();
    } catch (_) {
      newMaster.dispose();
      rethrow;
    }

    newMaster.joinEvent(
      event: _isolator.receiver,
      onData: (x) {
        if (x.threadID != ThreadManager.instance.threadID) {
          _thereIsMainPointer = false;
          _masterInstance?.dispose();
          _masterInstance = null;
        }
      },
    );

    _masterInstance = newMaster;
    _thereIsMainPointer = true;
  }

  @override
  Future<R> execute<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(T item, InvocationParameters para) function}) async {
    await initialize();

    await _semaphore.execute(function: () {});
    return await _isolator.syncValue.execute<R>(function: function, parameters: parameters);
  }

  @override
  Future<T> getItem() async {
    await initialize();

    await _semaphore.execute(function: () {});
    return await _isolator.syncValue.getItem();
  }

  @override
  Stream<R> getStream<R>({required FutureOr<Stream<R>> Function(T item, InvocationParameters para) function, InvocationParameters parameters = InvocationParameters.emptry}) async* {
    await initialize();

    await _semaphore.execute(function: () {});
    yield* _isolator.syncValue.getStream<R>(function: function, parameters: parameters);
  }

  Future<StreamSubscription<R>> getStreamSync<R>({
    required FutureOr<Stream<R>> Function(T item, InvocationParameters para) function,
    required void Function(R) onData,
    InvocationParameters parameters = InvocationParameters.emptry,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) async {
    await initialize();

    await _semaphore.execute(function: () {});
    return _isolator.syncValue.getStream<R>(function: function, parameters: parameters).listen(
          onData,
          onError: onError,
          cancelOnError: cancelOnError,
          onDone: onDone,
        );
  }

  @override
  InteractiveFunctionality<I, R> executeFunctionality<I, R>({required InteractiveFunctionality<I, R> Function(T item, InvocationParameters para) function, InvocationParameters parameters = InvocationParameters.emptry}) {
    checkInitialize();
    return _isolator.syncValue.executeFunctionality<I, R>(function: function, parameters: parameters);
  }
}
