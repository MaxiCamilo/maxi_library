@Timeout(Duration(minutes: 30))
import 'dart:async';
import 'dart:math';

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

import 'functionalities/remote_functionality.dart';
import 'functionalities/remote_functionality_stream.dart';
import 'test.dart';

void main() {
  group('Reflection test', () {
    setUp(() {
      ReflectionManager.defineAlbums = [testReflectors];
      ReflectionManager.defineAsTheMainReflector();
    });

    test('Invoke Functionality', () async {
      final clientPipe = StreamController<Map<String, dynamic>>();
      final serverPipe = StreamController<Map<String, dynamic>>();

      final clientExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: serverPipe.stream, sender: clientPipe, confirmConnection: true);
      final serverExecutor = RemoteFunctionalitiesExecutorViaStream.filtrePackage(receiver: clientPipe.stream, sender: serverPipe, confirmConnection: true);

      await serverExecutor.initialize();
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
        waitFunctionalStream(
          stream: clientExecutor.executeStreamFunctionality<String, RemoteFunctionalityStream>(
              parameters: InvocationParameters.named({
            'name': 'Peladito',
            'timeout': Random().nextInt(18) + 3,
          })),
          onData: (x) => print(x.toString()),
        ),
        waitFunctionalStream(
          stream: clientExecutor.executeStreamFunctionality<String, RemoteFunctionalityStream>(
              parameters: InvocationParameters.named({
            'name': 'Peluditos',
            'timeout': Random().nextInt(18) + 3,
          })),
          onData: (x) => print(x.toString()),
        ),
        waitFunctionalStream(
          stream: clientExecutor.executeStreamFunctionality<String, RemoteFunctionalityStream>(
              parameters: InvocationParameters.named({
            'name': 'Barbudito',
            'timeout': Random().nextInt(18) + 3,
          })),
          onData: (x) => print(x.toString()),
        ),
      ]);

      print('Result $result');
    });
  });
}
