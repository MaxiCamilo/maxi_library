import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

import 'first_service.dart';

class SecondService with StartableFunctionality, IThreadService {
  @override
  Future<void> initializeFunctionality() async {}

  @override
  String get serviceName => 'Second service';

  Future<void> callFromFirstService() async {
    final any = await ThreadManager.callEntityFunction<FirstService, String>(
      function: (service, parameters) => service.passSomeText(),
    );

    (await ThreadManager.instance.getEntityInstance<FirstService>())!.done.whenComplete(() => log('First service is closed in Second service'));

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

  Future<void> usePipe(IPipe<int, String> pipe) async {
    pipe.add('Waiting number');
    await for (final number in pipe.stream) {
      if (number == 5) {
        pipe.add('Oh no! It\'s five, that\'s bad');
        break;
      }

      pipe.add('You sent #$number');
      await Future.delayed(Duration(seconds: 3));
    }

    pipe.add('Good bye!');
    pipe.close();
  }
}
