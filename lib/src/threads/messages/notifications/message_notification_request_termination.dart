import 'dart:developer';

import 'package:maxi_library/src/threads/context_process_thread_messages.dart';
import 'package:maxi_library/src/threads/operators/ithread_message.dart';
import 'package:maxi_library/src/threads/operators/ithread_process_isolate.dart';

class MessageNotificationRequestTermination with IThreadMessage {
  @override
  Future<void> openMessage({required ContextProcessThreadMessages context}) async {
    if (context.managerThisThread is IThreadProcessIsolate) {
      (context.managerThisThread as IThreadProcessIsolate).requestThreadTermination();
    } else {
      log('[MessageNotificationRequestTermination] FAILED! The thread of type "${context.managerThisThread.runtimeType}" is not  "IThreadProcessIsolate');
    }
  }
}
