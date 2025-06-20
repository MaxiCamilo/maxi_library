@Timeout(Duration(minutes: 30))
import 'dart:async';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';
import 'functionalities/remote_functionality_stream.dart';
import 'test.dart';

void main() {
  group('Reflection test', () {
    setUp(() async {
      //ReflectionManager.defineAlbums =;
      //ReflectionManager.defineAsTheMainReflector();

      await ApplicationManager.changeInstance(
        newInstance: DartApplicationManager(defineLanguageOperatorInOtherThread: false, reflectors: [testReflectors]),
        initialize: true,
      );
    });

    test('Invoke Functionality', () async {
      final clientPipe = StreamController<Map<String, dynamic>>();
      final serverPipe = StreamController<Map<String, dynamic>>();

      final clientExecutor = RemoteFunctionalitiesExecutor.fromStream(input: serverPipe.stream, output: clientPipe);
      // ignore: unused_local_variable
      final serverExecutor = RemoteFunctionalitiesExecutor.fromStream(input: clientPipe.stream, output: serverPipe);

      final oreo = clientExecutor
          .executeInteractiveFunctionality<String, RemoteFunctionalityStream>(
            parameters: InvocationParameters.named({
              'name': 'Oreo',
              'timeout': Random().nextInt(18) + 3,
            }),
          )
          .createOperator();

      String result = await oreo.waitResult(
        onItem: (x) => log('Text: "$x"'),
      );

      print('Result "$result"');

      final sabrina = clientExecutor
          .executeInteractiveFunctionality<String, RemoteFunctionalityStream>(
            parameters: InvocationParameters.named({
              'name': 'Sabrina',
              'timeout': Random().nextInt(18) + 3,
            }),
          )
          .createOperator();

      result = await sabrina.waitResult(
        onItem: (x) => log('Text: "$x"'),
      );

      print('Result "$result"');
    });

    test('Invoke exception', () async {
      final clientPipe = StreamController<Map<String, dynamic>>();
      final serverPipe = StreamController<Map<String, dynamic>>();

      final clientExecutor = RemoteFunctionalitiesExecutor.fromStream(input: serverPipe.stream, output: clientPipe);
      // ignore: unused_local_variable
      final serverExecutor = RemoteFunctionalitiesExecutor.fromStream(input: clientPipe.stream, output: serverPipe);

      final oreo = clientExecutor
          .executeInteractiveFunctionality<String, RemoteFunctionalityStream>(
            parameters: InvocationParameters.named({
              'name': 'Oreo',
              'timeout': Random().nextInt(18) + 3,
              'launchException': true,
            }),
          )
          .createOperator();

      String result = await oreo.waitResult(
        onItem: (x) => log('Text: "$x"'),
      );

      print('Result "$result"');
    });
/*
    test('Invoke Isolates Functionalities', () async {
      final serverChannel = await ThreadManager.callBackgroundChannel<Map<String, dynamic>, Map<String, dynamic>>(function: (_, channel) async {
        final serverExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: channel.receiver, sender: channel, confirmConnection: true);
        await serverExecutor.initialize();
      });

      final clientExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: serverChannel.receiver, sender: serverChannel, confirmConnection: true);
      await clientExecutor.initialize();

      final maxi = clientExecutor
          .executeFunctionality<String, RemoteFunctionality>(
              parameters: InvocationParameters.named({
            'name': 'Maxitito',
            'timeout': Random().nextInt(18) + 3,
          }))
          .then((x) => print(x))
          .onError((x, st) => print('Maxi error: $x'));

      final sebitito = clientExecutor
          .executeFunctionality<String, RemoteFunctionality>(
              parameters: InvocationParameters.named({
            'name': 'sebitito',
            'timeout': Random().nextInt(18) + 3,
          }))
          .then((x) => print(x))
          .onError((x, st) => print('Seba error: $x'));

      final oreo = clientExecutor
          .executeFunctionality<String, RemoteFunctionality>(
              parameters: InvocationParameters.named({
            'name': 'Oreo',
            'timeout': Random().nextInt(18) + 3,
          }))
          .then((x) => print(x))
          .onError((x, st) => print('Oreo error: $x'));

      final takara = clientExecutor
          .executeFunctionality<String, RemoteFunctionality>(
              parameters: InvocationParameters.named({
            'name': 'Takara',
            'timeout': Random().nextInt(18) + 3,
          }))
          .then((x) => print(x))
          .onError((x, st) => print('Takara error: $x'));

      await Future.wait([maxi, sebitito, oreo, takara]);
    });

    test('Invoke Isolates Stream', () async {
      final clientPipe = StreamController<Map<String, dynamic>>();
      final serverPipe = StreamController<Map<String, dynamic>>();

      final clientExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: serverPipe.stream, sender: clientPipe, confirmConnection: true);
      final serverExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: clientPipe.stream, sender: serverPipe, confirmConnection: true);

      await serverExecutor.initialize();
      await clientExecutor.initialize();

      final result = await Future.wait([
        ExpressFunctionalityStream(
          stream: clientExecutor.executeStreamFunctionality<String, RemoteFunctionalityStream>(
              parameters: InvocationParameters.named({
            'name': 'Peladito',
            'timeout': Random().nextInt(18) + 3,
          })),
          onText: (x) => print(x.toString()),
        ).waitResult(),
        ExpressFunctionalityStream(
          stream: clientExecutor.executeStreamFunctionality<String, RemoteFunctionalityStream>(
              parameters: InvocationParameters.named({
            'name': 'Peluditos',
            'timeout': Random().nextInt(18) + 3,
          })),
          onText: (x) => print(x.toString()),
        ).waitResult(),
        ExpressFunctionalityStream(
          stream: clientExecutor.executeStreamFunctionality<String, RemoteFunctionalityStream>(
              parameters: InvocationParameters.named({
            'name': 'Barbudito',
            'timeout': Random().nextInt(18) + 3,
          })),
          onText: (x) => print(x.toString()),
        ).waitResult(),
      ]);

      print('Result $result');
    });
  });

  test('Invoke thread entity', () async {
    ReflectionManager.defineAlbums = [testReflectors];
    ReflectionManager.defineAsTheMainReflector();
    await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));

    final clientPipe = StreamController<Map<String, dynamic>>();
    final serverPipe = StreamController<Map<String, dynamic>>();

    final clientExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: serverPipe.stream, sender: clientPipe, confirmConnection: true);
    final serverExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: clientPipe.stream, sender: serverPipe, confirmConnection: false);

    await serverExecutor.initialize();
    await clientExecutor.initialize();

    final result = await clientExecutor.executeReflectedEntityFunction(entityName: 'FirstService', methodName: 'passSomeText');
    print(result);
  });*/
  });
}
