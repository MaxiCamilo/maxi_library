import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

class ThreadInitializerTest with IThreadInitializer {
  @override
  Future<void> performInitializationInThread(IThreadManager channel) async {
    log('Hola maxi!');

    //throw NegativeResult(identifier: NegativeResultCodes.abnormalOperation, message: Oration(message:':('));
  }
}
