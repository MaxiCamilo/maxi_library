import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactive_functionality/interactive_functionality_on_stream.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_another_thread.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_backgroud.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_main_thread.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_service_thread.dart';
import 'package:maxi_library/src/framework/interactive_functionality_operators/local_interactive_functionality_operator.dart';
import 'package:meta/meta.dart';

typedef TextableFunctionality<R> = InteractiveFunctionality<Oration, R>;
typedef TextableFunctionalityVoid = TextableFunctionality<void>;
typedef TextableFunctionalityOperator<R> = InteractiveFunctionalityOperator<Oration, R>;
typedef TextableFunctionalityExecutor<R> = InteractiveFunctionalityExecutor<Oration, R>;
typedef TextableFunctionalityExecutorVoid = TextableFunctionalityExecutor<void>;

mixin InteractiveFunctionality<I, R> {
  @protected
  bool get cancelIfItsInactive => true;

  String get functionalityName => runtimeType.toString();

  Type get resultType => R;
  Type get itemType => I;

  @protected
  FutureOr<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager});

  @protected
  void onError({required InteractiveFunctionalityExecutor<I, R> manager, required NegativeResult error, required StackTrace stackTrace}) {}

  //@protected
  //void onResult({required InteractiveFunctionalityExecutor<I, R> manager, required R result}) {}

  @protected
  void onCancel({required InteractiveFunctionalityExecutor<I, R> manager}) {}

  @protected
  void onManagerDispose() {}

  @protected
  void onFinish({required InteractiveFunctionalityExecutor<I, R> manager, R? possibleResult, NegativeResult? possibleError}) {}

  @protected
  void onThereAreNoListeners({required InteractiveFunctionalityExecutor<I, R> manager}) {}

  @protected
  NegativeResult castError({required InteractiveFunctionalityExecutor<I, R> manager, required dynamic rawError, required StackTrace stackTrace}) {
    return NegativeResult.searchNegativity(
      item: rawError,
      actionDescription: Oration(message: 'Executing the functionality %1', textParts: [functionalityName]),
      stackTrace: stackTrace,
    );
  }

  static InteractiveFunctionality<I, R> express<I, R>(FutureOr<R> Function(InteractiveFunctionalityExecutor<I, R>) function) => _InteractiveFunctionalityExpress<I, R>(function: function);

  static InteractiveFunctionalityOperator<I, R> listenAsyncStream<I, R>(FutureOr<Stream> Function() streamGetter) => RunInteractiveFunctionalityOnStream<I, R>(streamGetter: streamGetter).createOperator()..start();
  static InteractiveFunctionalityOperator<I, R> listenStream<I, R>(Stream stream) => RunInteractiveFunctionalityOnStream<I, R>(streamGetter: () => stream).createOperator()..start();

  InteractiveFunctionalityOperator<I, R> createOperator({int identifier = 0}) => LocalInteractiveFunctionalityOperator<I, R>(functionality: this, identifier: identifier);

  MaxiFuture<R> executeAndWait({int identifier = 0, void Function(I)? onItem}) => LocalInteractiveFunctionalityOperator<I, R>(functionality: this, identifier: identifier).waitResult(onItem: onItem);

  InteractiveFunctionality<I, R> inThreadServer() => RunInteractiveFunctionalityOnMainThread<I, R>(anotherFunctionality: this);
  InteractiveFunctionality<I, R> inBackground() => RunInteractiveFunctionalityOnBackgroud<I, R>(anotherFunctionality: this);

  InteractiveFunctionality<I, R> inAnotherThread({required IThreadInvoker invoker}) => RunInteractiveFunctionalityOnAnotherThread<I, R>(thread: invoker, anotherFunctionality: this);
  InteractiveFunctionality<I, R> inService<S extends Object>() => RunInteractiveFunctionalityOnServiceThread<S, I, R>(anotherFunctionality: this);
  //InteractiveFunctionalityOperator<I, R> runInThreadServer({int identifier = 0}) => inThreadServer().createOperator(identifier: identifier);

  /*{
    if (ApplicationManager.instance.isWeb || ThreadManager.instance.isServer) {
      return createOperator();
    }

    return IsolatedInteractiveFunctionalityOperator<I, R>(
      functionality: RunInteractiveFunctionalityOnBackgroud(anotherFunctionality: this),
      invokerGetter: () => (ThreadManager.instance as ThreadIsolatorClient).serverConnection,
    );
  }*/

 

 // InteractiveFunctionalityOperator<I, R> runInStream({required StreamSink sender, required bool closeSenderIfDone, int identifier = 0}) =>
 //     InteractiveFunctionalityStreamExecutor<I, R>(functionality: this, sender: sender, closeSenderIfDone: closeSenderIfDone, identifier: identifier);
//  InteractiveFunctionalityOperator<I, R> runInMapStream({required StreamSink<Map<String, dynamic>> sender, required bool closeSenderIfDone, int identifier = 0}) =>
 //     InteractiveFunctionalityStreamExecutor<I, R>.onMapStream(functionality: this, sender: sender, identifier: identifier, closeSenderIfDone: closeSenderIfDone);

 // InteractiveFunctionalityOperator<I, R> runInJsonStream({required StreamSink<String> sender, required bool closeSenderIfDone, int identifier = 0}) =>
 //     InteractiveFunctionalityStreamExecutor<I, R>.onJson(functionality: this, sender: sender, identifier: identifier, closeSenderIfDone: closeSenderIfDone);

  Future<R> joinExecutor<T>(InteractiveFunctionalityExecutor<I, T> unitedOperator, {void Function(I)? onItem}) {
    unitedOperator.checkActivity();
    final newOperator = createOperator(identifier: unitedOperator.identifier);

    unitedOperator.onDispose.whenComplete(() {
      newOperator.cancel();
    });

    //unitedOperator.joinDisponsabeObject(item: newOperator);

    return newOperator.waitResult(onItem: (x) {
      unitedOperator.sendItem(x);
      if (onItem != null) {
        onItem(x);
      }
    });
  }

  IChannel makeChannel({bool closeIfItEnd = true, int identifier = 0}) {
    final channel = MasterChannel(closeIfEveryoneClosed: true);
    ChannelInteractiveFunctionality<I, R>(
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
          final interacable = parameters.third<InteractiveFunctionality<I, R>>();
          ChannelInteractiveFunctionality<I, R>(
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

class _InteractiveFunctionalityExpress<I, R> with InteractiveFunctionality<I, R> {
  final FutureOr<R> Function(InteractiveFunctionalityExecutor<I, R>) function;

  _InteractiveFunctionalityExpress({required this.function});

  @override
  FutureOr<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) => function(manager);
}
