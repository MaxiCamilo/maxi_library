@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

import 'functionalities/new_functionality.dart';
import 'services/first_service.dart';

void main() {
  group('Texteable functionality test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test local functionality', () async {
      final result = await NewFunctionality().executeAndWait(
        onItem: (x) => print(x),
      );

      print(result);
    });

    test('Test cancel local functionality', () async {
      final future = NewFunctionality().executeAndWait(
        onItem: (x) => print(x),
      );

      future.then((x) => print(x));

      await Future.delayed(const Duration(seconds: 2));
      future.ignore();

      await Future.delayed(const Duration(seconds: 22));
    });

    test('Call on service', () async {
      await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));

      final funcOperator = NewFunctionality().runInService<FirstService>();

      final result = await funcOperator.waitResult(
        onItem: (x) => print(x),
      );

      print(result);
    });

    test('Call on  background', () async {
      await ApplicationManager.changeInstance(
        newInstance: DartApplicationManager(
          defineLanguageOperatorInOtherThread: false,
          reflectors: const [],
        ),
        initialize: true,
      );
      await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));

      final results = await Future.wait([
        NewFunctionality().runInBackground().waitResult(onItem: (x) => print(x)),
        NewFunctionality().runInBackground().waitResult(onItem: (x) => print(x)),
        NewFunctionality().runInBackground().waitResult(onItem: (x) => print(x))
      ]);

      print(results);

       final otherResults = await Future.wait([
        NewFunctionality().runInBackground().waitResult(onItem: (x) => print(x)),
        NewFunctionality().runInBackground().waitResult(onItem: (x) => print(x)),
        //NewFunctionality().runInBackground().waitResult(onItem: (x) => print(x))
      ]);

      print(otherResults);
    });

    test('Call on enitity background', () async {
      await ApplicationManager.changeInstance(
        newInstance: DartApplicationManager(
          defineLanguageOperatorInOtherThread: false,
          reflectors: const [],
        ),
        initialize: true,
      );
      await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));
      final result = await ThreadManager.callEntityFunction<FirstService, String>(function: (serv, para) => serv.callBackgroudFunctionality());

      print(result);
    });

    test('Call on Stream', () async {
      final streamController = StreamController();

      final receiver = InteractableFunctionality.listenStream<Oration, String>(streamController.stream);

      final sender = NewFunctionality(secondWaiting: 10).runInStream(sender: streamController, closeSenderIfDone: true);

      //Future.delayed(const Duration(seconds: 5)).whenComplete(() => sender.cancel());

      final result = await receiver.waitResult(onItem: (item) => print(item.toString()));
      print(result);
      await Future.delayed(const Duration(seconds: 5));
    });

    test('Call on Json Stream', () async {
      final streamController = StreamController<String>.broadcast();

      streamController.stream.listen((x) => print(x));

      final receiver = InteractableFunctionality.listenStream<Oration, String>(streamController.stream);

      final sender = NewFunctionality(secondWaiting: 10).runInJsonStream(sender: streamController, closeSenderIfDone: true);
      //Future.delayed(const Duration(seconds: 5)).whenComplete(() => sender.cancel());

      final result = await receiver.waitResult(onItem: (item) => print(item.toString()));
      print(result);
    });
  });
}
