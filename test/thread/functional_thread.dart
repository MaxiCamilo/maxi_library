import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/thread_isolator_server.dart';

Future<void> main() async {
  final server = ThreadManager.instance as ThreadIsolatorServer;

  final newThread = await server.makeNewThread(initializers: [], name: 'Other test');

  String text = await newThread.callFunction(parameters: InvocationParameters.only('Maxi'), function: _invoked);
  log('Thread send $text');

  text = await newThread.callFunction(parameters: InvocationParameters.only('Maxi'), function: _invoked);
  log('Thread send $text');

  text = await newThread.callFunction(parameters: InvocationParameters.only('Maxi'), function: _invoked);
  log('Thread send $text');

  await newThread.callFunction(parameters: InvocationParameters.emptry, function: (x) async => x.thread.closeThread());
  await newThread.done;

  log('Thread was closed');
}

Future<String> _invoked(InvocationContext context) async {
  await Future.delayed(Duration(seconds: 3));
  return 'Hi ${context.firts<String>()}';
}
