import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class ExecuteFunctionalityWithinToChannel<I, R> with IFunctionality<Future<ChannelExecutionResult<R>>>, IDisposable {
  final int idenfifier;
  final IChannel channel;
  final bool closeChannelIfFinish;
  final bool cancelIfChannelCloses;
  final FutureOr<InteractiveFunctionality<I, R>> Function(Stream) functionalityBuilder;

  ExecuteFunctionalityWithinToChannel({
    required this.idenfifier,
    required this.channel,
    required this.closeChannelIfFinish,
    required this.cancelIfChannelCloses,
    required this.functionalityBuilder,
  });

  InteractiveFunctionalityOperator<I, R>? _actualManager;
  StreamController? _itemReceived;
  ChannelExecutionResult<R>? _lastResult;

  @override
  Future<ChannelExecutionResult<R>> runFunctionality() async {
    if (_lastResult != null) {
      return _lastResult!;
    }

    resurrectObject();

    try {
      if (_actualManager != null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.implementationFailure,
          message: const Oration(message: 'There can only be an active operator'),
        );
      }

      _itemReceived = StreamController();
      _actualManager = (await functionalityBuilder(_itemReceived!.stream)).createOperator(identifier: idenfifier);

      channel.receiver.listen(_reactItemOnChannel);

      if (cancelIfChannelCloses) {
        channel.done.whenComplete(() => dispose());
      }

      final result = await _actualManager!.waitResult(
        onItem: (item) {
          channel.addIfActive(FunctionalityItem<I>(item: item).serialize());
        },
      );

      channel.addIfActive(FunctionalityResult<R>(result: result).serialize());
      _lastResult = ChannelExecutionResult<R>(isCorrect: true, error: null, result: result, stackTrace: null);
    } catch (ex, st) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Running channel functionality'));
      channel.addIfActive(FunctionalityError(error: rn, stackTrace: st).serialize());
      _lastResult = ChannelExecutionResult<R>(isCorrect: false, error: rn, result: null, stackTrace: st);
    } finally {
      await continueOtherFutures();
      dispose();
    }

    return _lastResult!;
  }

  @override
  void performObjectDiscard() {
    _actualManager?.cancel();
    _actualManager = null;
    _itemReceived?.close();
    _itemReceived = null;

    if (closeChannelIfFinish) {
      maxiScheduleMicrotask(() {
        channel.close();
      });
    }
  }

  void _reactItemOnChannel(event) {
    if (event is String) {
      if (event.length > 2 && event.length < 20 && event.first == '{' && event.last == '}') {
        try {
          final rawJson = ConverterUtilities.interpretToObjectJson(text: event);
          if (rawJson['\$type'] == 'cancel') {
            _actualManager?.cancel();
            return;
          }
        } catch (_) {}
      }
    } else if (event is Map<String, dynamic>) {
      if (event['\$type'] == 'cancel') {
        _actualManager?.cancel();
        return;
      }
    } else if (event is FunctionalityCancel) {
      _actualManager?.cancel();
      return;
    }

    _itemReceived?.addIfActive(event);
  }
}
