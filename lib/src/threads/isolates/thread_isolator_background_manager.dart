import 'dart:async';
import 'dart:io';

import 'package:maxi_library/maxi_library.dart';

class ThreadIsolatorBackgroundManager {
  final IThreadManagerServer manager;
  final List<IThreadInvokeInstance> instances = [];

  final List<IThreadInvokeInstance> freeInstances = [];
  final List<IThreadInvokeInstance> busyInstances = [];

  late final int busyInstanceLimit;

  final _threadReserveSynchronizer = Semaphore();

  Completer<IThreadInvokeInstance>? _freeWaiter;

  ThreadIsolatorBackgroundManager({required this.manager}) {
    busyInstanceLimit = Platform.numberOfProcessors * 2;
  }

  Future<IThreadInvokeInstance> reserveThread() => _threadReserveSynchronizer.execute(function: _reserveThreadSincronized);

  Future<IThreadInvokeInstance> _reserveThreadSincronized() async {
    if (freeInstances.isNotEmpty) {
      final item = freeInstances.removeLast();
      busyInstances.add(item);
      return item;
    } else if (instances.length >= busyInstanceLimit) {
      late final IThreadInvokeInstance free;
      while (true) {
        _freeWaiter ??= MaxiCompleter<IThreadInvokeInstance>();
        await _freeWaiter!.future;

        if (freeInstances.isNotEmpty) {
          free = freeInstances.removeAt(0);
          break;
        }
      }

      return free;

      /*
      _freeWaiter ??= Completer<IThreadInvokeInstance>();
      final free = await _freeWaiter!.future;
      freeInstances.remove(free);
      busyInstances.add(free);
      return free;*/
    } else {
      final newThread = await manager.makeNewThread(initializers: const [], name: 'Thread in the background No. ${instances.length + 1}');
      instances.add(newThread);
      busyInstances.add(newThread);
      return newThread;
    }
  }

  void releaseThread(IThreadInvokeInstance thread) {
    busyInstances.remove(thread);
    freeInstances.add(thread);
    _freeWaiter?.completeIfIncomplete(thread);
    _freeWaiter = null;
  }

  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required FutureOr<R> Function(InvocationContext para) function}) async {
    final thread = await reserveThread();
    try {
      return await thread.callFunction<R>(parameters: parameters, function: function);
    } finally {
      releaseThread(thread);
    }
  }

  Future<Stream<R>> callBackgroundStream<R>({required InvocationParameters parameters, required FutureOr<Stream<R>> Function(InvocationContext p1) function}) async {
    final thread = await reserveThread();

    bool wasClose = false;

    return (await thread.callStream(parameters: parameters, function: function)).doOnCancel(() {
      if (!wasClose) {
        wasClose = true;
        releaseThread(thread);
      }
    }).asBroadcastStream(
      onCancel: (_) {
        if (!wasClose) {
          wasClose = true;
          releaseThread(thread);
        }
      },
    );
  }

  Future<IChannel<S, R>> callBackgroundChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function}) async {
    final thread = await reserveThread();

    try {
      final channel = await thread.createChannel<R, S>(function: function, parameters: parameters);
      channel.done.whenComplete(() => releaseThread(thread));
      return channel;
    } catch (_) {
      releaseThread(thread);
      rethrow;
    }
  }
}
