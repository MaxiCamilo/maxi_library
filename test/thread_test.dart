@Timeout(Duration(minutes: 30))
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

import 'old_entities/thread_initialicer_test.dart';
import 'services/first_service.dart';
import 'services/second_service.dart';

Future<String> _greetUserMaxi(InvocationParameters parameters) async {
  log('Hello maxi!');

  return ':D';
}

Future<String> _greetUser(InvocationParameters parameters) async {
  final random = math.Random();
  final seconds = random.nextInt(5) + 1;
  log('"${parameters.firts<String>()}" waiting $seconds seconds');

  await Future.delayed(Duration(seconds: seconds));

  return 'Hello ${parameters.firts<String>()}!';
}

Stream<String> _makeTexts() async* {
  int i = 1;
  while (i <= 5) {
    await Future.delayed(Duration(seconds: 3));
    log('In thread, send $i');

    yield 'Now I am at $i';
    i += 1;

    //throw 'D:';
  }

  log('Now, I have finished');
}

void main() {
  group('Thread test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Start and finalize thread', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      newThread
          .callFunction(
              parameters: InvocationParameters.emptry,
              function: (p) async {
                log('waiting to finish');
                await Future.delayed(Duration(seconds: 10));
                maxiScheduleMicrotask(() async {
                  log('Bye!');
                  p.thread.closeThread();
                });

                return 'juajuajua';
              })
          .then((x) {
        log('Function sent $x');
      });

      await newThread.done;
      log('Thread has finalized');
    });

    test('Request the end of the thread', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');
      newThread.callFunction(
          parameters: InvocationParameters.emptry,
          function: (p) async {
            log('Hi maxi');
          });

      await Future.delayed(Duration(seconds: 5));
      log('We\'ll now kill the child process');

      newThread.requestEndOfThread();
      await newThread.done;

      log('Thread is dead');
    });

    test('New thread', () async {
      ThreadManager.addThreadInitializer(initializer: ThreadInitializerTest());

      await ThreadManager.instance.callFunctionOnTheServer(function: (_) async => print('Hi from here!'));

      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');
      final received = await newThread.callFunction(
          parameters: InvocationParameters.emptry,
          function: (_) async {
            log('Hi from client!');
            return 'jejejeje';
          });
      print('Thred sent $received');
    });

    test('Mount thread and execute functions', () async {
      ThreadManager.addThreadInitializer(initializer: ThreadInitializerTest());
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      final textReceive = await newThread.callFunction(function: _greetUserMaxi, parameters: InvocationParameters.emptry);
      log('The Thread sent "$textReceive"');

      String greetingText = await newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Peludo'));
      log('The Thread sent "$greetingText"');

      greetingText = await newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Pelado'));
      log('The Thread sent "$greetingText"');

      greetingText = await newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Petizo'));
      log('The Thread sent "$greetingText"');

      greetingText = await newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Barbudo'));
      log('The Thread sent "$greetingText"');
    });

    test('check synchronization', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      await Future.wait([
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('First')).then((x) {
          log('Finished first: $x');
        }),
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Second')).then((x) {
          log('Finished second: $x');
        }),
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Third')).then((x) {
          log('Finished third: $x');
        }),
      ]);

      log('Function finished');

      await newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Fourth')).then((x) {
        log('Finished Fourth: $x');
      });

      await newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Fifth')).then((x) {
        log('Finished fifth: $x');
      });

      await Future.wait([
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Sixth')).then((x) {
          log('Finished sixth: $x');
        }),
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Seventh')).then((x) {
          log('Finished seventh: $x');
        }),
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Eighth')).then((x) {
          log('Finished eighth: $x');
        }),
        newThread.callFunction(function: _greetUser, parameters: InvocationParameters.only('Nineth')).then((x) {
          log('Finished nineth: $x');
        }),
      ]);
    });

    test('check Streams', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      final stream = await newThread.callStream<String>(parameters: InvocationParameters.emptry, function: (_) async => _makeTexts());
      final waiter = MaxiCompleter();
      // ignore: unused_local_variable
      final subcription = stream.listen(
        (x) => log('The stream send item "$x"'),
        onDone: () => waiter.complete(),
        onError: (x) => log('The thread send error: "$x"'),
      );

      //Future.delayed(Duration(seconds: 5)).whenComplete(() {
      //  //CAUTION: If a stream is canceled, the "onDone" is not triggered
      //  subcription.cancel();
      //});

      await waiter.future;
      log('The stream finalize');
    });

    test('Mounth Service', () async {
      try {
        await ThreadManager.mountEntity(entity: FirstService(isMustFail: true));
      } catch (ex) {
        log(ex.toString());
      }

      await ThreadManager.mountEntity(entity: FirstService(isMustFail: false));

      final text = await ThreadManager.callEntityFunction<FirstService, String>(function: (x, _) => x.passSomeText());

      log('The service sent "$text"');

      final number = await ThreadManager.callEntityFunction<FirstService, int>(function: (x, _) => x.passSomeNumber());
      log('The service sent a number "$number"');
    });

    test('Using Stream in the entities', () async {
      await ThreadManager.mountEntity(entity: FirstService(isMustFail: false));

      final stream = (await ThreadManager.callEntityStream<FirstService, String>(function: (x, p) async => x.generateSomeText(amount: 15, waitingSeconds: 3))).asBroadcastStream();

      stream.listen(
        (x) => log('The stream of the entity sent "$x"'),
        onDone: () => log('The stream closed'),
      );

      await stream.waitFinish(errorsAreFatal: true);

      log('I am done');
    });

    test('Service calling another service', () async {
      await ThreadManager.mountEntity(entity: FirstService(isMustFail: false));
      await ThreadManager.mountEntity(entity: SecondService());

      await ThreadManager.callEntityFunction<SecondService, void>(function: (service, parameters) => service.callFromFirstService());
      log('yey');
    });

    test('Service Stream another service', () async {
      await ThreadManager.mountEntity(entity: FirstService(isMustFail: false));
      await ThreadManager.mountEntity(entity: SecondService());

      final stream = (await ThreadManager.callEntityStream<SecondService, String>(function: (x, p) async => x.callStreamFromFirstService())).asBroadcastStream();

      stream.listen(
        (x) => log('The stream of the entity sent "$x"'),
        onDone: () => log('The stream closed'),
      );

      await stream.waitFinish(errorsAreFatal: true);

      log('I am done');
    });

    test('Service mount another service', () async {
      await ThreadManager.mountEntity(entity: SecondService());
      await ThreadManager.callEntityFunction<SecondService, void>(function: (service, parameters) => service.mountFirstService());
      log('I am done');
    });

    test('External Stream Test ', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      final channel = await newThread.createChannel(function: _externalChannel);
      channel.receiver.listen((x) => print('From Thread -> Main: Number $x'));

      for (int i = 1; i < 21; i++) {
        channel.addIfActive('Hi! I go for $i');
        await Future.delayed(Duration(seconds: 1));
      }

      await channel.close();
      await Future.delayed(Duration(seconds: 30));
    });

    test('External channel between 2 services', () async {
      await ThreadManager.mountEntity(entity: FirstService(isMustFail: false));
      await ThreadManager.mountEntity(entity: SecondService());

      await ThreadManager.callEntityFunction<FirstService, void>(
        function: (serv, para) => serv.createPipeInSecondService(),
      );
    });
  });
}

Future<void> _externalChannel(InvocationContext context, IChannel<String, int> channel) async {
  channel.receiver.listen((x) => print('From Main -> Thread: "$x"'));
  channel.done.whenComplete(() => print('Good bye From thread'));

  for (int i = 1; i < 30; i++) {
    if (!channel.isActive) {
      break;
    }
    channel.add(i);
    await Future.delayed(Duration(seconds: 3));
  }

  await Future.delayed(Duration(seconds: 1));
  channel.close();
}
