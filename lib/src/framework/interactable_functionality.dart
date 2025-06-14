import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/interactable_functionality_on_stream.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/isolated_interactable_functionality_operator.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/local_interactable_functionality_operator.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/run_interactable_functionality_on_backgroud.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/run_interactable_functionality_on_main_thread.dart';
import 'package:meta/meta.dart';

typedef TextableFunctionality<R> = InteractableFunctionality<Oration, R>;
typedef TextableFunctionalityVoid = TextableFunctionality<void>;
typedef TextableFunctionalityOperator<R> = InteractableFunctionalityOperator<Oration, R>;
typedef TextableFunctionalityExecutor<R> = InteractableFunctionalityExecutor<Oration, R>;
typedef TextableFunctionalityExecutorVoid = TextableFunctionalityExecutor<void>;

mixin InteractableFunctionality<I, R> {
  @protected
  bool get cancelIfItsInactive => true;

  String get functionalityName => runtimeType.toString();

  Type get resultType => R;
  Type get itemType => I;

  @protected
  FutureOr<R> runFunctionality({required InteractableFunctionalityExecutor<I, R> manager});

  @protected
  void onError({required InteractableFunctionalityExecutor<I, R> manager, required NegativeResult error, required StackTrace stackTrace}) {}

  //@protected
  //void onResult({required InteractableFunctionalityExecutor<I, R> manager, required R result}) {}

  @protected
  void onCancel({required InteractableFunctionalityExecutor<I, R> manager}) {}

  @protected
  void onManagerDispose() {}

  @protected
  void onFinish({required InteractableFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {}

  @protected
  void onThereAreNoListeners({required InteractableFunctionalityExecutor<I, R> manager}) {}

  @protected
  NegativeResult castError({required InteractableFunctionalityExecutor<I, R> manager, required dynamic rawError, required StackTrace stackTrace}) {
    return NegativeResult.searchNegativity(
      item: rawError,
      actionDescription: Oration(message: 'Executing the functionality %1', textParts: [functionalityName]),
      stackTrace: stackTrace,
    );
  }

  static InteractableFunctionality<I, R> express<I, R>(FutureOr<R> Function(InteractableFunctionalityExecutor<I, R>) function) => _InteractableFunctionalityExpress<I, R>(function: function);

  static InteractableFunctionalityOperator<I, R> listenAsyncStream<I, R>(FutureOr<Stream> Function() streamGetter) => RunInteractableFunctionalityOnStream<I, R>(streamGetter: streamGetter).createOperator()..start();
  static InteractableFunctionalityOperator<I, R> listenStream<I, R>(Stream stream) => RunInteractableFunctionalityOnStream<I, R>(streamGetter: () => stream).createOperator()..start();

  InteractableFunctionalityOperator<I, R> createOperator({int identifier = 0}) => LocalInteractableFunctionalityOperator<I, R>(functionality: this, identifier: identifier);

  MaxiFuture<R> executeAndWait({int identifier = 0, void Function(I)? onItem}) => LocalInteractableFunctionalityOperator<I, R>(functionality: this, identifier: identifier).waitResult(onItem: onItem);

  InteractableFunctionality<I, R> inThreadServer() => RunInteractableFunctionalityOnMainThread<I, R>(anotherFunctionality: this);
  InteractableFunctionality<I, R> inBackground() => RunInteractableFunctionalityOnBackgroud<I, R>(anotherFunctionality: this);

  InteractableFunctionalityOperator<I, R> runInAnotherThread({required IThreadInvoker invoker}) => IsolatedInteractableFunctionalityOperator<I, R>(invokerGetter: () => invoker, functionality: this);
  InteractableFunctionalityOperator<I, R> runInService<S extends Object>() => IsolatedInteractableFunctionalityOperator<I, R>(invokerGetter: ThreadManager.getEntityInstance<S>, functionality: this);
  //InteractableFunctionalityOperator<I, R> runInThreadServer({int identifier = 0}) => inThreadServer().createOperator(identifier: identifier);

  /*{
    if (ApplicationManager.instance.isWeb || ThreadManager.instance.isServer) {
      return createOperator();
    }

    return IsolatedInteractableFunctionalityOperator<I, R>(
      functionality: RunInteractableFunctionalityOnBackgroud(anotherFunctionality: this),
      invokerGetter: () => (ThreadManager.instance as ThreadIsolatorClient).serverConnection,
    );
  }*/

  InteractableFunctionalityOperator<I, R> runInBackground({int identifier = 0}) => RunInteractableFunctionalityOnBackgroud<I, R>(anotherFunctionality: this).createOperator(identifier: identifier);

  InteractableFunctionalityOperator<I, R> runInStream({required StreamSink sender, required bool closeSenderIfDone, int identifier = 0}) =>
      InteractableFunctionalityStreamExecutor<I, R>(functionality: this, sender: sender, closeSenderIfDone: closeSenderIfDone, identifier: identifier);
  InteractableFunctionalityOperator<I, R> runInMapStream({required StreamSink<Map<String, dynamic>> sender, required bool closeSenderIfDone, int identifier = 0}) =>
      InteractableFunctionalityStreamExecutor<I, R>.onMapStream(functionality: this, sender: sender, identifier: identifier, closeSenderIfDone: closeSenderIfDone);

  InteractableFunctionalityOperator<I, R> runInJsonStream({required StreamSink<String> sender, required bool closeSenderIfDone, int identifier = 0}) =>
      InteractableFunctionalityStreamExecutor<I, R>.onJson(functionality: this, sender: sender, identifier: identifier, closeSenderIfDone: closeSenderIfDone);

  Future<R> joinExecutor<T>(InteractableFunctionalityExecutor<I, T> unitedOperator, {void Function(I)? onItem}) {
    unitedOperator.checkActivity();
    final newOperator = createOperator(identifier: unitedOperator.identifier);

    unitedOperator.joinDisponsabeObject(item: newOperator);

    return newOperator.waitResult(onItem: (x) {
      unitedOperator.sendItem(x);
      if (onItem != null) {
        onItem(x);
      }
    });
  }

  IChannel makeChannel({bool closeIfItEnd = true, int identifier = 0}) {
    final channel = MasterChannel(closeIfEveryoneClosed: true);
    ChannelInteractableFunctionality<I, R>(
      channel: channel,
      functionality: this,
      closeIfItEnd: closeIfItEnd,
      identifier: identifier,
    ).start();

    return channel;
  }

  IChannel makeBackgroundChannel({bool closeIfItEnd = true, int identifier = 0}) {
    final channel = MasterChannel(closeIfEveryoneClosed: true);

    ThreadManager.callBackgroundChannel(
        parameters: InvocationParameters.list([closeIfItEnd, identifier, this]),
        function: (parameters, otherChannel) {
          final closeIfItEnd = parameters.firts<bool>();
          final identifier = parameters.second<int>();
          final interacable = parameters.third<InteractableFunctionality<I, R>>();
          ChannelInteractableFunctionality<I, R>(
            channel: otherChannel,
            functionality: interacable,
            closeIfItEnd: closeIfItEnd,
            identifier: identifier,
          ).start();
          //final channel = interacable.makeChannel(closeIfItEnd: closeIfItEnd, identifier: identifier);
          //otherChannel.joinWithOtherChannel(channel: channel, closeOtherChannelIfFinished: true, closeThisChannelIfFinish: true);
        }).then((newChannel) {
      channel.joinWithOtherChannel(channel: newChannel, closeOtherChannelIfFinished: true, closeThisChannelIfFinish: true);
    }).onError((x, y) {
      channel.close();
    });

    return channel.createSlave();
  }
}

class _InteractableFunctionalityExpress<I, R> with InteractableFunctionality<I, R> {
  final FutureOr<R> Function(InteractableFunctionalityExecutor<I, R>) function;

  _InteractableFunctionalityExpress({required this.function});

  @override
  FutureOr<R> runFunctionality({required InteractableFunctionalityExecutor<I, R> manager}) => function(manager);
}
