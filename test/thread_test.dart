@Timeout(Duration(minutes: 30))
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/utilities/extension/extensions_stream.dart';
import 'package:test/test.dart';

import 'services/first_service.dart';

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
    await Future.delayed(Duration(seconds: 1));
    log('In thread, send $i');

    yield 'Now I am at $i';
    i += 1;
  }

  log('Now, I have finished');
}

void main() {
  group('Thread test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Mount thread', () async {
      final textReceive = await ThreadManager.callFunctionAsAnonymous(function: _greetUserMaxi);
      log('The Thread sent "$textReceive"');

      String greetingText = await ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Peludo'));
      log('The Thread sent "$greetingText"');

      greetingText = await ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Pelado'));
      log('The Thread sent "$greetingText"');

      greetingText = await ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Petizo'));
      log('The Thread sent "$greetingText"');

      greetingText = await ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Barbudo'));
      log('The Thread sent "$greetingText"');
    });

    test('check synchronization', () async {
      await Future.wait([
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('First')).then((x) {
          log('Finished first: $x');
        }),
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Second')).then((x) {
          log('Finished second: $x');
        }),
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Third')).then((x) {
          log('Finished third: $x');
        }),
      ]);

      log('Function finished');

      await ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Fourth')).then((x) {
        log('Finished Fourth: $x');
      });

      await ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Fifth')).then((x) {
        log('Finished fifth: $x');
      });

      await Future.wait([
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Sixth')).then((x) {
          log('Finished sixth: $x');
        }),
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Seventh')).then((x) {
          log('Finished seventh: $x');
        }),
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Eighth')).then((x) {
          log('Finished eighth: $x');
        }),
        ThreadManager.callFunctionAsAnonymous(function: _greetUser, parameters: InvocationParameters.only('Nineth')).then((x) {
          log('Finished nineth: $x');
        }),
      ]);
    });

    test('check Streams', () async {
      final stream = await ThreadManager.callStreamAsAnonymous<String>(function: (_) async => _makeTexts());
      final waiter = Completer();
      // ignore: unused_local_variable
      final subcription = stream.listen(
        (x) => log('The stream send item "$x"'),
        onDone: () => waiter.complete(),
        onError: (x) => log('The thread send error: "$x"'),
      );

      //Future.delayed(Duration(seconds: 5)).whenComplete(() {
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

      final stream = await ThreadManager.callEntityStream<FirstService, String>(function: (x, p) async => x.generateSomeText(amount: 15, waitingSeconds: 3));

      stream.listen(
        (x) => log('The stream of the entity sent "$x"'),
        onDone: () => log('The stream closed'),
      );

      await stream.waitFinish();

      log('I am done');
    });
  });
}
