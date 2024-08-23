import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class ThreadInitializerTest with IThreadInitializer {
  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) async {
    log('Hola maxi!');
  }
}
