import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class ConnectInteractiveFunctionalityOnChannel<I, R> with InteractiveFunctionality<I, R> {
  final int idenfifier;
  final IChannel channel;
  final bool closeChannelIfFinish;

  ConnectInteractiveFunctionalityOnChannel({
    required this.channel,
    required this.idenfifier,
    required this.closeChannelIfFinish,
  });

  MaxiCompleter<R>? _resultWaiter;
  Semaphore? _synchronizer;
  StreamController<I>? _itemStremController;

  bool _itWasInitialized = false;

  @override
  Future<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) async {
    _resultWaiter ??= MaxiCompleter<R>();

    if (_resultWaiter!.isCompleted) {
      return _resultWaiter!.future;
    }

    _synchronizer ??= Semaphore();

    await _synchronizer!.execute(function: _initialize);

    _itemStremController!.stream.listen((x) => manager.sendItem(x));

    return _resultWaiter!.future;
  }

  Future<void> _initialize() async {
    if (_itWasInitialized) {
      return;
    }

    channel.receiver.listen(_processData);
    _itemStremController ??= StreamController<I>.broadcast();

    _itWasInitialized = true;
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

  void _processData(dynamic event) {
    if (event is FunctionalityItem<I>) {
      _itemStremController?.addIfActive(event.item);
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

  @override
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {
    super.onCancel(manager: manager);

    if (channel.isActive) {
      containErrorLogAsync(
        detail: const Oration(message: 'Sending cancel message in channel'),
        function: () => channel.addIfActive(const FunctionalityCancel().serializeToJson()),
      );
    }
  }

  @override
  void onFinish({required InteractiveFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {
    super.onFinish(manager: manager, possibleResult: possibleResult, possibleError: possibleError);

    _itemStremController?.close();
    _itemStremController = null;
    _synchronizer = null;
    if (closeChannelIfFinish) {
      channel.close();
    }
  }
}
