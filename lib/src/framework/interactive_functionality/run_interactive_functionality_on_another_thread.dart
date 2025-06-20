import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class RunInteractiveFunctionalityOnAnotherThread<I, R> with InteractiveFunctionality<I, R> {
  final InteractiveFunctionality<I, R> anotherFunctionality;
  final IThreadInvoker thread;

  static final _internalStreams = <int, StreamController>{};
  static final _internalWaitResult = <int, MaxiCompleter>{};

  static final _externalOperators = <int, InteractiveFunctionalityOperator>{};
  static int _lastID = 1;

  late int _threadID;

  RunInteractiveFunctionalityOnAnotherThread({required this.anotherFunctionality, required this.thread});

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    _threadID = await thread.callFunction(parameters: InvocationParameters.list([anotherFunctionality, manager.identifier]), function: _runFunctionalityInThread<I, R>);
    final completer = MaxiCompleter<R>();
    final stream = StreamController<I>();

    _internalWaitResult[_threadID] = completer;
    _internalStreams[_threadID] = stream;

    stream.stream.listen((x) => manager.sendItem(x));

    return await completer.future;
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    thread.callFunction(parameters: InvocationParameters.only(_threadID), function: _cancelFunctionality);
  }

  static Future<int> _runFunctionalityInThread<I, R>(InvocationContext parameter) async {
    final id = _lastID;
    _lastID += 1;

    final functionality = parameter.firts<InteractiveFunctionality<I, R>>();
    maxiScheduleMicrotask(() => _aftherRunFunctionalityInThread<I, R>(
          functionality: functionality,
          sender: parameter.sender,
          id: id,
          operatorID: parameter.second<int>(),
        ));
    return id;
  }

  static Future<void> _aftherRunFunctionalityInThread<I, R>({
    required InteractiveFunctionality<I, R> functionality,
    required IThreadInvoker sender,
    required int id,
    required int operatorID,
  }) async {
    final functionalityOperator = functionality.createOperator(identifier: operatorID);

    _externalOperators[id] = functionalityOperator;

    try {
      final result = await functionalityOperator.waitResult(
        onItem: (x) => sender.callFunction(parameters: InvocationParameters.list([id, x]), function: _reactNewItem),
      );
      sender.callFunction(parameters: InvocationParameters.list([id, result]), function: _reactResult);
    } catch (ex, st) {
      sender.callFunction(parameters: InvocationParameters.list([id, ex, st]), function: _reactError);
    } finally {
      _externalOperators.remove(id);
    }
  }

  static void _reactNewItem(InvocationContext context) {
    final id = context.firts<int>();
    final content = context.second();

    final functionalityStream = _internalStreams[id];
    if (functionalityStream != null) {
      functionalityStream.addIfActive(content);
    }
  }

  static void _reactError(InvocationContext context) {
    print('EL SISTEMA ESTPÁ MAL');
    final id = context.firts<int>();
    final exception = context.second();
    final stackTrace = context.third();

    final functionalityStream = _internalStreams.remove(id);
    final functionalityWaiter = _internalWaitResult.remove(id);

    if (functionalityWaiter != null) {
      functionalityWaiter.completeErrorIfIncomplete(exception, stackTrace);
    }

    if (functionalityStream != null) {
      functionalityStream.close();
    }
  }

  static void _reactResult(InvocationContext context) {
    print('EL SISTEMA ESTPÁ MAL');
    final id = context.firts<int>();
    final result = context.second();

    final functionalityStream = _internalStreams.remove(id);
    final functionalityWaiter = _internalWaitResult.remove(id);

    if (functionalityWaiter != null) {
      functionalityWaiter.completeIfIncomplete(result);
    }

    if (functionalityStream != null) {
      functionalityStream.close();
    }
  }

  static void _cancelFunctionality(InvocationContext context) {
    final id = context.firts<int>();
    final functionalityManager = _externalOperators.remove(id);

    functionalityManager?.cancel();
  }
}
