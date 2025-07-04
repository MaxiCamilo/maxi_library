import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactive_functionality/connect_interactive_functionality_on_channel.dart';
import 'package:maxi_library/src/framework/interactive_functionality/connect_service_functionality.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_another_thread.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_backgroud.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_main_thread.dart';
import 'package:maxi_library/src/framework/interactive_functionality/run_interactive_functionality_on_service_thread.dart';
import 'package:maxi_library/src/framework/interactive_functionality_operators/execute_functionality_within_to_channel.dart';
import 'package:maxi_library/src/framework/interactive_functionality_operators/local_interactive_functionality_operator.dart';
import 'package:meta/meta.dart';

typedef TextableFunctionality<R> = InteractiveFunctionality<Oration, R>;
typedef TextableFunctionalityVoid = TextableFunctionality<void>;
typedef TextableFunctionalityOperator<R> = InteractiveFunctionalityOperator<Oration, R>;
typedef TextableFunctionalityExecutor<R> = InteractiveFunctionalityExecutor<Oration, R>;
typedef TextableFunctionalityExecutorVoid = TextableFunctionalityExecutor<void>;

mixin InteractiveFunctionality<I, R> {
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

  static InteractiveFunctionality<I, R> fromService<S extends Object, I, R>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<InteractiveFunctionality<I, R>> Function(S serv, InvocationParameters para) functionalityGetter,
  }) =>
      ConnectServiceFunctionality<S, I, R>(parameters: parameters, functionalityGetter: functionalityGetter);

  static InteractiveFunctionality<I, R> express<I, R>(FutureOr<R> Function(InteractiveFunctionalityExecutor<I, R>) function) => _InteractiveFunctionalityExpress<I, R>(function: function);
  static InteractiveFunctionality<I, R> listenToChannel<I, R>({required IChannel channel, required bool closeChannelIfFinish, int identifier = 0}) =>
      ConnectInteractiveFunctionalityOnChannel<I, R>(channel: channel, idenfifier: identifier, closeChannelIfFinish: closeChannelIfFinish);

  static IFunctionality<Future<ChannelExecutionResult<R>>> createChannelExecutor<I, R>({
    required IChannel channel,
    required FutureOr<InteractiveFunctionality<I, R>> Function(Stream) functionalityBuilder,
    bool closeChannelIfFinish = true,
    bool cancelIfChannelCloses = true,
    int idenfifier = 0,
  }) =>
      ExecuteFunctionalityWithinToChannel<I, R>(
        channel: channel,
        cancelIfChannelCloses: cancelIfChannelCloses,
        closeChannelIfFinish: closeChannelIfFinish,
        functionalityBuilder: functionalityBuilder,
        idenfifier: idenfifier,
      );

  //static InteractiveFunctionalityOperator<I, R> listenAsyncStream<I, R>(FutureOr<Stream> Function() streamGetter) => RunInteractiveFunctionalityOnStream<I, R>(streamGetter: streamGetter).createOperator()..start();
  //static InteractiveFunctionalityOperator<I, R> listenStream<I, R>(Stream stream) => RunInteractiveFunctionalityOnStream<I, R>(streamGetter: () => stream).createOperator()..start();

  InteractiveFunctionalityOperator<I, R> createOperator({int identifier = 0}) => LocalInteractiveFunctionalityOperator<I, R>(functionality: this, identifier: identifier);

  MaxiFuture<R> executeAndWait({int identifier = 0, void Function(I)? onItem}) => LocalInteractiveFunctionalityOperator<I, R>(functionality: this, identifier: identifier).waitResult(onItem: onItem);

  InteractiveFunctionality<I, R> inThreadServer() => RunInteractiveFunctionalityOnMainThread<I, R>(anotherFunctionality: this);
  InteractiveFunctionality<I, R> inBackground() => RunInteractiveFunctionalityOnBackgroud<I, R>(anotherFunctionality: this);

  InteractiveFunctionality<I, R> inAnotherThread({required IThreadInvoker invoker}) => RunInteractiveFunctionalityOnAnotherThread<I, R>(thread: invoker, anotherFunctionality: this);
  InteractiveFunctionality<I, R> inService<S extends Object>() => RunInteractiveFunctionalityOnServiceThread<S, I, R>(anotherFunctionality: this);

  IFunctionality<Future<ChannelExecutionResult<R>>> settingOnchannel({
    required IChannel channel,
    bool closeChannelIfFinish = true,
    bool cancelIfChannelCloses = true,
    int idenfifier = 0,
    void Function(InteractiveFunctionality<I, R>, Stream)? setStream,
  }) =>
      ExecuteFunctionalityWithinToChannel<I, R>(
          channel: channel,
          cancelIfChannelCloses: cancelIfChannelCloses,
          closeChannelIfFinish: closeChannelIfFinish,
          functionalityBuilder: (stream) {
            if (setStream != null) {
              setStream(this, stream);
            }
            return this;
          },
          idenfifier: idenfifier);

  IChannel createChannel({
    bool closeChannelIfFinish = true,
    bool cancelIfChannelCloses = true,
    int idenfifier = 0,
    void Function(InteractiveFunctionality<I, R>, Stream)? setStream,
  }) {
    final channel = MasterChannel(closeIfEveryoneClosed: closeChannelIfFinish);

    final instance = settingOnchannel(
      channel: channel,
      closeChannelIfFinish: closeChannelIfFinish,
      cancelIfChannelCloses: cancelIfChannelCloses,
      idenfifier: idenfifier,
      setStream: setStream,
    );
    scheduleMicrotask(() async {
      await continueOtherFutures();
      instance.runFunctionality();
    });

    return channel.createSlave();
  }

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

  Future<R> joinExecutor<T>(InteractiveFunctionalityExecutor<I, T> manager, {void Function(I)? onItem}) {
    manager.checkActivity();
    final newOperator = createOperator(identifier: manager.identifier);

    manager.onDispose.whenComplete(() {
      newOperator.dispose();
    });

    manager.onCancelOrDone.whenComplete(() {
      newOperator.cancel();
    });

    //unitedOperator.joinDisponsabeObject(item: newOperator);

    return newOperator.waitResult(onItem: (x) {
      manager.sendItem(x);
      if (onItem != null) {
        onItem(x);
      }
    });
  }
}

class _InteractiveFunctionalityExpress<I, R> with InteractiveFunctionality<I, R> {
  final FutureOr<R> Function(InteractiveFunctionalityExecutor<I, R>) function;

  _InteractiveFunctionalityExpress({required this.function});

  @override
  FutureOr<R> runFunctionality({required InteractiveFunctionalityExecutor<I, R> manager}) => function(manager);
}
