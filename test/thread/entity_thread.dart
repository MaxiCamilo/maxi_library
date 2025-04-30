import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/maxi_library.dart';

import '../services/first_service.dart';
import '../services/second_service.dart';

Future<void> main() async {
  await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));
  /*final second =*/ await ThreadManager.mountEntity<SecondService>(entity: SecondService());
  /*

  await second.callFunction(
    parameters: InvocationParameters.emptry,
    function: (p1) => print('Hi!'),
  );

  (await ThreadManager.getEntityInstance<FirstService>()).done.then((_) => log('First service is closed'));

  await ThreadManager.callEntityFunction<SecondService, void>(function: (serv, para) => serv.callFromFirstService());
  */

  //await ThreadManager.callEntityFunction<SecondService, void>(function: (serv, para) => serv.mountFirstService());

  /* await ThreadManager.callEntityFunction<SecondService, void>(function: (serv, para) async {
    (await ThreadManager.instance.getEntityInstance<FirstService>())!.requestEndOfThread();
  });*/

  //await ThreadManager.callEntityFunction<FirstService, void>(function: (serv, para) => serv.createPipeInSecondService());

  final waiter = MaxiCompleter();
  (await ThreadManager.callEntityStream<FirstService, String>(
    function: (serv, para) => serv.generateSomeText(amount: 10, waitingSeconds: 3),
  ))
      .listen(
    (x) => print('Thread sent: $x'),
    onError: (x, y) => print('Thread setn error!: $x'),
    onDone: () {
      log('Stream was closed');
      waiter.completeIfIncomplete();
    },
  );

  log('Stream is active');

  await waiter.future;

  log('Chau chau');
}
