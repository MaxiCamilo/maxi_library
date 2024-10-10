import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

import 'first_service.dart';

class SecondService with StartableFunctionality, ThreadService {
  @override
  Future<void> initializeFunctionality() async {}

  @override
  String get serviceName => 'Second service';

  Future<void> callFromFirstService() async {
    final any = await ThreadManager.callEntityFunction<FirstService, String>(
      function: (service, parameters) => service.passSomeText(),
    );

    log('First service returned $any');
  }

  Stream<String> callStreamFromFirstService() async* {
    final stream = await ThreadManager.callEntityStream<FirstService, String>(
      function: (service, parameters) async => service.generateSomeText(amount: 12, waitingSeconds: 5),
    );

    await for (final item in stream) {
      yield 'External: $item';
    }

    log('First external stream');
  }

  Future<void> mountFirstService() async {
    await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));
    await callFromFirstService();
  }
}
