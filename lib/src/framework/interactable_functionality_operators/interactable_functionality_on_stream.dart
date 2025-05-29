import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/local_interactable_functionality_operator.dart';

class RunInteractableFunctionalityOnStream<I, R> with InteractableFunctionality<I, R> {
  final FutureOr<Stream> Function() streamGetter;

  StreamSubscription? _subscription;
  MaxiCompleter<R>? _resultWaiter;
  late InteractableFunctionalityExecutor<I, R> _manager;

  RunInteractableFunctionalityOnStream({required this.streamGetter});

  @override
  Future<R> runFunctionality({required InteractableFunctionalityExecutor<I, R> manager}) async {
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
  void onCancel({required InteractableFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);
    _subscription?.cancel();
    _onDoneStream();
  }

  @override
  void onFinish({required InteractableFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {
    super.onFinish(manager: manager, possibleResult: possibleResult, possibleError: possibleError);
    _subscription?.cancel();
  }

  void _processData(dynamic event) {
    if (event is _FunctionalityItem<I>) {
      _manager.sendItem(event.item);
    } else if (event is _FunctionalityResult<R>) {
      _resultWaiter?.completeIfIncomplete(event.result);
    } else if (event is _FunctionalityError) {
      _resultWaiter?.completeErrorIfIncomplete(event.error, event.stackTrace);
    } else if (event is Map<String, dynamic>) {
      _processMap(event);
    } else if (event is String) {
      final rawJson = ConverterUtilities.interpretToObjectJson(text: event);
      _processMap(rawJson);
    } else {
      log('[RunInteractableFunctionalityOnStream] Unknown object received in the current (is of type ${event.runtimeType})');
    }
  }

  void _processMap(Map<String, dynamic> event) {
    final type = event.getRequiredValueWithSpecificType<String>('\$type');
    switch (type) {
      case 'item':
        _processData(_FunctionalityItem.interpret<I>(event));
        break;
      case 'result':
        _processData(_FunctionalityResult.interpret<R>(event));
        break;
      case 'error':
        _processData(_FunctionalityError.interpret(event));
        break;
      default:
        log('[RunInteractableFunctionalityOnStream] Unknown Map object received in the current (is of type $type)');
        break;
    }
  }
}

class InteractableFunctionalityStreamExecutor<I, R> with IDisposable, InteractableFunctionalityOperator<I, R> {
  @override
  final int identifier;
  final InteractableFunctionality<I, R> functionality;
  final StreamSink sender;
  final bool closeSenderIfDone;

  final dynamic Function(int, I)? itemConverted;
  final dynamic Function(int, R)? resultConverted;
  final dynamic Function(int, NegativeResult, StackTrace)? errorConverted;

  late final LocalInteractableFunctionalityOperator<I, R> _executor;

  factory InteractableFunctionalityStreamExecutor.onMapStream({
    required InteractableFunctionality<I, R> functionality,
    required StreamSink<Map<String, dynamic>> sender,
    required bool closeSenderIfDone,
    int identifier = 0,
  }) {
    return InteractableFunctionalityStreamExecutor<I, R>(
      functionality: functionality,
      sender: sender,
      identifier: identifier,
      closeSenderIfDone: closeSenderIfDone,
      itemConverted: _convertItemToMap<I>,
      resultConverted: _convertResultToMap<R>,
      errorConverted: _convertErrorToMap,
    );
  }

  factory InteractableFunctionalityStreamExecutor.onJson({
    required InteractableFunctionality<I, R> functionality,
    required StreamSink<String> sender,
    required bool closeSenderIfDone,
    int identifier = 0,
  }) {
    return InteractableFunctionalityStreamExecutor<I, R>(
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
    return _FunctionalityItem<I>(idetifier: id, item: item).serialize();
  }

  static _convertResultToMap<R>(int id, R item) {
    return _FunctionalityResult<R>(idetifier: id, result: item).serialize();
  }

  static _convertErrorToMap(int id, NegativeResult error, StackTrace stack) {
    return _FunctionalityError(idetifier: id, error: error, stackTrace: stack).serialize();
  }

  InteractableFunctionalityStreamExecutor({
    required this.functionality,
    required this.sender,
    required this.closeSenderIfDone,
    this.identifier = 0,
    this.itemConverted,
    this.resultConverted,
    this.errorConverted,
  }) {
    _executor = LocalInteractableFunctionalityOperator(functionality: functionality, identifier: identifier);
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
            sender.add(_FunctionalityItem<I>(idetifier: identifier, item: x));
          } else {
            sender.add(itemConverted!(identifier, x));
          }
        },
      );

      if (resultConverted == null) {
        sender.add(_FunctionalityResult<R>(idetifier: identifier, result: result));
      } else {
        sender.add(resultConverted!(identifier, result));
      }
    } catch (ex, st) {
      if (errorConverted == null) {
        sender.add(
          _FunctionalityError(
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

class _FunctionalityItem<I> with ICustomSerialization {
  final I item;
  final int idetifier;

  const _FunctionalityItem({required this.item, required this.idetifier});

  static _FunctionalityItem<I> interpret<I>(Map<String, dynamic> map) {
    final id = map.getRequiredValueWithSpecificType<int>('id');
    final item = ConverterUtilities.castJson<I>(text: map.getRequiredValueWithSpecificType<String>('item'));

    return _FunctionalityItem<I>(idetifier: id, item: item);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'id': idetifier,
      '\$type': 'item',
      'item': ConverterUtilities.serializeToJson(item),
    };
  }
}

class _FunctionalityResult<R> with ICustomSerialization {
  final R result;
  final int idetifier;

  const _FunctionalityResult({required this.result, required this.idetifier});

  static _FunctionalityResult<R> interpret<R>(Map<String, dynamic> map) {
    final id = map.getRequiredValueWithSpecificType<int>('id');
    final result = ConverterUtilities.castJson<R>(text: map.getRequiredValueWithSpecificType<String>('result'));

    return _FunctionalityResult<R>(idetifier: id, result: result);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'id': idetifier,
      '\$type': 'result',
      'result': ConverterUtilities.serializeToJson(result),
    };
  }
}

class _FunctionalityError with ICustomSerialization {
  final NegativeResult error;
  final StackTrace stackTrace;
  final int idetifier;

  const _FunctionalityError({required this.error, required this.stackTrace, required this.idetifier});

  factory _FunctionalityError.interpret(Map<String, dynamic> map) {
    final id = map.getRequiredValueWithSpecificType<int>('id');
    final error = NegativeResult.interpretJson(jsonText: map.getRequiredValueWithSpecificType<String>('error'));
    final stackTrace = StackTrace.fromString(map.getRequiredValueWithSpecificType<String>('stackTrace'));

    return _FunctionalityError(idetifier: id, error: error, stackTrace: stackTrace);
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      'id': idetifier,
      '\$type': 'error',
      'error': error.serializeToJson(),
      'stackTrace': stackTrace.toString(),
    };
  }
}
