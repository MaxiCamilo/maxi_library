import 'dart:async';

import 'package:maxi_library/src/threads/ithread_message.dart';

mixin ITheadConnection on StreamSink {
  bool get isActive;

  Stream<ITheadConnection> get notifyConnectionClosure;
  Stream<IThreadMessage> get messageReceiver;
  Future<void> sendMessage({required IThreadMessage message});

  void defineConnectionClosed();
}
