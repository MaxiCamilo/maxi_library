import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';

class ThreadExecuteFunction<R> with IThreadMessage {
  final InvocationParameters parameters;
  final FutureOr<R> Function(InvocationContext) function;

  const ThreadExecuteFunction({required this.parameters, required this.function});

  Completer<R> makeCompleter() => MaxiCompleter<R>();
}
