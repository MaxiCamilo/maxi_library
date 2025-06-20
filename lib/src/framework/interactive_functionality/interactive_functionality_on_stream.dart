import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactive_functionality_operators/local_interactive_functionality_operator.dart';

class RunInteractiveFunctionalityOnStream<I, R> with InteractiveFunctionality<I, R> {
  final FutureOr<Stream> Function() streamGetter;

  StreamSubscription? _subscription;
  MaxiCompleter<R>? _resultWaiter;
  late InteractiveFunctionalityExecutor<I, R> _manager;

  RunInteractiveFunctionalityOnStream({required this.streamGetter});

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    _manager = manager;

    final stream = await streamGetter();
    _resultWaiter = MaxiCompleter<R>();

    _subscription = stream.listen(_processData, onError: _processError, onDone: _onDoneStream);
    return await _resultWaiter!.future;
  }

  void _processError(dynamic error, StackTrace stackTrace) {
    _resultWaiter?.completeErrorIfIncomplete(error, stackTrace);
  }

  void _onDoneStream() {
    _resultWaiter?.completeErrorIfIncomplete(
      NegativeResult(
        identifier: NegativeResultCodes.communicationInterrupted,
        message: const Oration(message: 'Communication with functionality was interrupted'),
      ),
      StackTrace.current,
    );
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    _subscription?.cancel();
    _onDoneStream();
  }

  @override
  void onFinish({required InteractiveFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {
    super.onFinish(manager: manager, possibleResult: possibleResult, possibleError: possibleError);
    _subscription?.cancel();
  }

  void _processData(dynamic event) {
    if (event is FunctionalityItem<I>) {
      _manager.sendItem(event.item);
    } else if (event is FunctionalityResult<R>) {
      _resultWaiter?.completeIfIncomplete(event.result);
    } else if (event is FunctionalityError) {
      _resultWaiter?.completeErrorIfIncomplete(event.error, event.stackTrace);
    } else if (event is Map<String, dynamic>) {
      _processMap(event);
    } else if (event is String) {
      final rawJson = ConverterUtilities.interpretToObjectJson(text: event);
      _processMap(rawJson);
    } else {
      log('[RunInteractiveFunctionalityOnStream] Unknown object received in the current (is of type ${event.runtimeType})');
    }
  }

  void _processMap(Map<String, dynamic> event) {
    final type = event.getRequiredValueWithSpecificType<String>('\$type');
    switch (type) {
      case 'item':
        _processData(FunctionalityItem.interpret<I>(event));
        break;
      case 'result':
        _processData(FunctionalityResult.interpret<R>(event));
        break;
      case 'failed':
        _processData(FunctionalityError.interpret(event));
        break;
      default:
        log('[RunInteractiveFunctionalityOnStream] Unknown Map object received in the current (is of type $type)');
        break;
    }
  }
}

class InteractiveFunctionalityStreamExecutor<I, R> with IDisposable, InteractiveFunctionalityOperator<I, R> {
  @override
  final int identifier;
  final InteractiveFunctionality<I, R> functionality;
  final StreamSink sender;
  final bool closeSenderIfDone;

  final dynamic Function(int, I)? itemConverted;
  final dynamic Function(int, R)? resultConverted;
  final dynamic Function(int, NegativeResult, StackTrace)? errorConverted;

  late final LocalInteractiveFunctionalityOperator<I, R> _executor;

  factory InteractiveFunctionalityStreamExecutor.onMapStream({
    required InteractiveFunctionality<I, R> functionality,
    required StreamSink<Map<String, dynamic>> sender,
    required bool closeSenderIfDone,
    int identifier = 0,
  }) {
    return InteractiveFunctionalityStreamExecutor<I, R>(
      functionality: functionality,
      sender: sender,
      identifier: identifier,
      closeSenderIfDone: closeSenderIfDone,
      itemConverted: _convertItemToMap<I>,
      resultConverted: _convertResultToMap<R>,
      errorConverted: _convertErrorToMap,
    );
  }

  factory InteractiveFunctionalityStreamExecutor.onJson({
    required InteractiveFunctionality<I, R> functionality,
    required StreamSink<String> sender,
    required bool closeSenderIfDone,
    int identifier = 0,
  }) {
    return InteractiveFunctionalityStreamExecutor<I, R>(
      functionality: functionality,
      sender: sender,
      identifier: identifier,
      closeSenderIfDone: closeSenderIfDone,
      itemConverted: (i, x) => ConverterUtilities.serializeToJson(_convertItemToMap<I>(i, x)),
      resultConverted: (i, x) => ConverterUtilities.serializeToJson(_convertResultToMap<R>(i, x)),
      errorConverted: (i, x, y) => ConverterUtilities.serializeToJson(_convertErrorToMap(i, x, y)),
    );
  }

  static _convertItemToMap<I>(int id, I item) {
    return FunctionalityItem<I>(idetifier: id, item: item).serialize();
  }

  static _convertResultToMap<R>(int id, R item) {
    if (item == null && (R == dynamic || R.toString() == 'void')) {
      return FunctionalityResult<R>(idetifier: id, result: '' as R).serialize();
    }
    return FunctionalityResult<R>(idetifier: id, result: item).serialize();
  }

  static _convertErrorToMap(int id, NegativeResult error, StackTrace stack) {
    return FunctionalityError(idetifier: id, error: error, stackTrace: stack).serialize();
  }

  InteractiveFunctionalityStreamExecutor({
    required this.functionality,
    required this.sender,
    required this.closeSenderIfDone,
    this.identifier = 0,
    this.itemConverted,
    this.resultConverted,
    this.errorConverted,
  }) {
    _executor = LocalInteractiveFunctionalityOperator(functionality: functionality, identifier: identifier);
    sender.done.whenComplete(_reactSinkDone);
    maxiScheduleMicrotask(_runFuntionality);
  }

  void _reactSinkDone() {
    cancel();
    //dispose();
  }

  Future<void> _runFuntionality() async {
    try {
      final result = await _executor.waitResult(
        onItem: (x) {
          if (itemConverted == null) {
            sender.add(FunctionalityItem<I>(idetifier: identifier, item: x));
          } else {
            sender.add(itemConverted!(identifier, x));
          }
        },
      );

      if (resultConverted == null) {
        sender.add(FunctionalityResult<R>(idetifier: identifier, result: result));
      } else {
        sender.add(resultConverted!(identifier, result));
      }
    } catch (ex, st) {
      if (errorConverted == null) {
        sender.add(
          FunctionalityError(
            idetifier: identifier,
            error: NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Execute functionality stream')),
            stackTrace: st,
          ),
        );
      } else {
        sender.add(errorConverted!(identifier, NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Execute functionality stream')), st));
      }
    }

    if (closeSenderIfDone) {
      sender.close();
    }
    _executor.dispose();
  }

  @override
  void cancel() {
    _executor.cancel();
  }

  @override
  Stream<I> get itemStream => _executor.itemStream;

  @override
  void performObjectDiscard() {
    _executor.dispose();
    if (closeSenderIfDone) {
      sender.close();
    }
  }

  @override
  void start() {}

  @override
  MaxiFuture<R> waitResult({void Function(I item)? onItem}) {
    return _executor.waitResult(onItem: onItem);
  }
}
