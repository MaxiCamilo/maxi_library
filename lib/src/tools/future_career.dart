import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

enum ClosedChannelDoes { nothing, interrupts, failure }

class FutureCareer<T> {
  final _futures = <Future>[];
  final _streams = <StreamSubscription>[];
  final _timers = <Timer>[];

  Completer<T>? _waitingItem;
  Completer<T?>? _waitingOptionalItem;

  final ClosedChannelDoes closedChannelDoes;

  FutureCareer({
    required this.closedChannelDoes,
  });

  void setTimeout({required Duration duration}) {
    final newTimer = Timer(duration, _declareTimeout);
    _timers.add(newTimer);
  }

  void linkFuture(Future<T> function) {
    final newFunction = function.then(_declareFinished, onError: _declareError);
    _futures.add(newFunction);
  }

  void linkStream(Stream<T> stream) {
    late final StreamSubscription<T> subcription;
    subcription = stream.listen(
      _declareFinished,
      onError: _declareError,
      onDone: () => _declareStreamDone(subcription),
    );
  }

  Future<T> waitItem() {
    _waitingItem ??= MaxiCompleter<T>();
    return _waitingItem!.future;
  }

  Future<T?> waitOptionalItem() {
    _waitingOptionalItem ??= MaxiCompleter<T>();
    return _waitingOptionalItem!.future;
  }

  void _declareFinished(T value) {
    _waitingItem?.completeIfIncomplete(value);
    _waitingOptionalItem?.completeIfIncomplete(value);
    _cancelAll();
  }

  void _declareError(Object error, [StackTrace? stackTrace]) {
    _waitingItem?.completeErrorIfIncomplete(error, stackTrace);
    _waitingOptionalItem?.completeErrorIfIncomplete(error, stackTrace);
    _cancelAll();
  }

  void _declareStreamDone(StreamSubscription subscription) {
    _streams.remove(subscription);

    final error = NegativeResult(
      identifier: NegativeResultCodes.statusFunctionalityInvalid,
      message: Oration(message: 'A response was expected, but a channel was closed'),
    );

    switch (closedChannelDoes) {
      case ClosedChannelDoes.interrupts:
        _waitingItem?.completeErrorIfIncomplete(error);
        _waitingOptionalItem?.complete(null);
        _cancelAll();
        break;
      case ClosedChannelDoes.failure:
        _declareError(error);
        break;
      case ClosedChannelDoes.nothing:
        break;
    }
  }

  void _cancelAll() {
    _waitingItem = null;
    _waitingOptionalItem = null;

    _futures.iterar((x) => x.ignore());
    _streams.iterar((x) => x.cancel());
    _timers.iterar((x) => x.cancel());

    _futures.clear();
    _streams.clear();
    _timers.clear();
  }

  void _declareTimeout() {
    final error = NegativeResult(
      identifier: NegativeResultCodes.timeout,
      message: Oration(message: 'Too long was waited for a reply'),
    );

    _waitingItem?.completeErrorIfIncomplete(error);
    _waitingOptionalItem?.complete(null);

    _cancelAll();
  }
}
