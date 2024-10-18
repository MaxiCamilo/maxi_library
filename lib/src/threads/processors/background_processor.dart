import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/ithread_invoke_instance.dart';

class BackgroundProcessor {
  final IThreadManagerServer server;

  BackgroundProcessor({required this.server});

  final _freeThreads = <IThreadInvokeInstance>[];
  final _busyThreads = <IThreadInvokeInstance>[];
  final _semaphore = Semaphore();

  int _lastId = 1;

  Future<IThreadInvokeInstance> _getThread() {
    return _semaphore.execute(function: () async {
      if (_freeThreads.isNotEmpty) {
        final selected = _freeThreads.removeAt(0);
        _busyThreads.add(selected);
        return selected;
      }

      final newThread = await server.makeNewThread(initializers: [], name: 'Background thread #$_lastId');
      _lastId += 1;

      _busyThreads.add(newThread);

      return newThread;
    });
  }

  Future<R> callBackgroundFunction<R>({InvocationParameters parameters = InvocationParameters.emptry, required Future<R> Function(InvocationContext para) function}) async {
    final thread = await _getThread();

    try {
      return await thread.callFunctionAsAnonymous(function: function, parameters: parameters);
    } finally {
      _declareFree(thread);
    }
  }

  void _declareFree(IThreadInvokeInstance thread) {
    _busyThreads.remove(thread);
    _freeThreads.add(thread);
  }
}
