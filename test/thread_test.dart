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

Future<void> _testExternalTest(InvocationParameters parameters) async {
  final pipe = parameters.firts<ThreadPipe<String, String>>();
  await pipe.initialize();

  pipe.stream.listen((x) {
    print('Server sent $x');
  });

  Future.delayed(Duration(seconds: 17)).whenComplete(() => pipe.close());

  for (int i = 0; i < 5; i++) {
    if (pipe.isActive) {
      pipe.addIfActive('Hi! Number $i');
    }
    await Future.delayed(Duration(seconds: 5));
  }

  await pipe.close();
}

void main() {
  group('Thread test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Start and finalize thread', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      newThread.callFunctionAsAnonymous(function: (p) async {
        log('waiting to finish');
        await Future.delayed(Duration(seconds: 10));
        scheduleMicrotask(() async {
          log('Bye!');
          p.thread.closeThread();
        });

        return 'juajuajua';
      }).then((x) {
        log('Function sent $x');
      });

      await newThread.done;
      log('Thread has finalized');
    });

    test('Request the end of the thread', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');
      newThread.callFunctionAsAnonymous(function: (p) async {
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
      final received = await newThread.callFunctionAsAnonymous(function: (_) async {
        log('Hi from client!');
        return 'jejejeje';
      });
      print('Thred sent $received');
    });

    test('Mount thread and execute functions', () async {
      ThreadManager.addThreadInitializer(initializer: ThreadInitializerTest());
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      final textReceive = await newThread.callFunctionAsAnonymous(function: _greetUserMaxi);
      log('The Thread sent "$textReceive"');

      String greetingText = await newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Peludo'));
      log('The Thread sent "$greetingText"');

      greetingText = await newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Pelado'));
      log('The Thread sent "$greetingText"');

      greetingText = await newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Petizo'));
      log('The Thread sent "$greetingText"');

      greetingText = await newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Barbudo'));
      log('The Thread sent "$greetingText"');
    });

    test('check synchronization', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      await Future.wait([
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('First')).then((x) {
          log('Finished first: $x');
        }),
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Second')).then((x) {
          log('Finished second: $x');
        }),
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Third')).then((x) {
          log('Finished third: $x');
        }),
      ]);

      log('Function finished');

      await newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Fourth')).then((x) {
        log('Finished Fourth: $x');
      });

      await newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Fifth')).then((x) {
        log('Finished fifth: $x');
      });

      await Future.wait([
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Sixth')).then((x) {
          log('Finished sixth: $x');
        }),
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Seventh')).then((x) {
          log('Finished seventh: $x');
        }),
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Eighth')).then((x) {
          log('Finished eighth: $x');
        }),
        newThread.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Nineth')).then((x) {
          log('Finished nineth: $x');
        }),
      ]);
    });

    test('check Streams', () async {
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      final stream = await newThread.callStreamAsAnonymous<String>(function: (_) async => _makeTexts());
      final waiter = Completer();
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
      final pipe = ThreadManager.makePipe<String, String>();
      final newThread = await (ThreadManager.instance as IThreadManagerServer).makeNewThread(initializers: [], name: 'Test thread');

      newThread.callFunctionAsAnonymous(function: _testExternalTest, parameters: InvocationParameters.only(pipe.cloner()));
      await pipe.initialize();

      scheduleMicrotask(() async {
        for (int i = 1; i < 3; i++) {
          pipe.addIfActive('N° $i');
          await Future.delayed(Duration(seconds: 7));
        }
      });

      pipe.stream.listen((x) => print('Thread sent: $x'));
      await pipe.done;
      print('Finish');
      //await Future.delayed(Duration(seconds: 90));
    });
  });
}
