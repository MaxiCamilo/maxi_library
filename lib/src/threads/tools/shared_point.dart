import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/singletons/shared_pointer_manager.dart';

import 'package:maxi_library/src/threads/standars/execute_functionality_on_shared_point.dart';

class SharedPointer<T> with ISharedPointer<T> {
  final int threadID;
  final int identifier;

  const SharedPointer({required this.threadID, required this.identifier});

  static Future<IThreadInvokeInstance> _getInvokator({required int identifier}) async {
    final invokaror = await ThreadManager.instance.getIDInstance(id: identifier);

    if (invokaror == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(
          message: 'There is no thread number %1',
          textParts: [identifier],
        ),
      );
    }

    return invokaror;
  }

  @override
  Future<R> execute<R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<R> Function(T item, InvocationParameters para) function,
  }) async {
    if (threadID == -1 || threadID == ThreadManager.instance.threadID) {
      return await function(SharedPointerManager.singleton.getItem<T>(identifier: identifier), parameters);
    }

    final thread = await _getInvokator(identifier: threadID);
    return await thread.callFunction(
      parameters: InvocationParameters.clone(parameters)
        ..fixedParameters.add(function)
        ..fixedParameters.add(identifier),
      function: _executeInThread<T, R>,
    );
  }

  @override
  Stream<R> getStream<R>({required FutureOr<Stream<R>> Function(T item, InvocationParameters para) function, InvocationParameters parameters = InvocationParameters.emptry}) async* {
    if (threadID == -1 || threadID == ThreadManager.instance.threadID) {
      yield* await function(SharedPointerManager.singleton.getItem<T>(identifier: identifier), parameters);
      return;
    }

    final thread = await _getInvokator(identifier: threadID);

    final stream = await thread.callStream<R>(
      parameters: InvocationParameters.clone(parameters)
        ..fixedParameters.add(function)
        ..fixedParameters.add(identifier),
      function: _executeStreamInThread<T, R>,
    );
    yield* stream;
  }

  @override
  InteractiveFunctionality<I, R> executeFunctionality<I, R>({
    required InteractiveFunctionality<I, R> Function(T item, InvocationParameters para) function,
    InvocationParameters parameters = InvocationParameters.emptry,
  }) {
    if (threadID == -1 || threadID == ThreadManager.instance.threadID) {
      return function(SharedPointerManager.singleton.getItem<T>(identifier: identifier), parameters);
    }

    return ExecuteFunctionalityOnSharedPoint<T, I, R>(
      function: function,
      identifier: identifier,
      parameters: parameters,
      threadID: threadID,
    );
  }

  static Future<Stream<R>> _executeStreamInThread<T, R>(InvocationParameters para) async {
    final id = para.last<int>();
    final function = para.penultimate<FutureOr<Stream<R>> Function(T, InvocationParameters)>();
    final value = SharedPointerManager.singleton.getItem<T>(identifier: id);
    return await function(value, para);
  }

  static Future<R> _executeInThread<T, R>(InvocationParameters para) async {
    final id = para.last<int>();
    final function = para.penultimate<FutureOr<R> Function(T, InvocationParameters)>();

    final value = SharedPointerManager.singleton.getItem<T>(identifier: id);
    return await function(value, para);
  }

  @override
  Future<T> getItem() {
    return execute(function: (x, _) => x);
  }
}
