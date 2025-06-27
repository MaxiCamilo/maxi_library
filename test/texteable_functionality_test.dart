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

    test('Test cancel and ignore local functionality', () async {
      final future = NewFunctionality().executeAndWait(
        onItem: (x) => print(x),
      );

      future.then((x) => print(x));

      await Future.delayed(const Duration(seconds: 2));
      future.ignore();

      await Future.delayed(const Duration(seconds: 22));
    });

    test('Test cancel local functionality', () async {
      final newOperator = NewFunctionality().createOperator();

      Future.delayed(const Duration(seconds: 1)).whenComplete(() => newOperator.cancel());

      await newOperator.waitResult();
    });

    test('Call on service', () async {
      await ThreadManager.mountEntity<FirstService>(entity: FirstService(isMustFail: false));

      final funcOperator = NewFunctionality().inService<FirstService>().createOperator();

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
        NewFunctionality().inBackground().createOperator().waitResult(onItem: (x) => print(x)),
        NewFunctionality().inBackground().createOperator().waitResult(onItem: (x) => print(x)),
        NewFunctionality().inBackground().createOperator().waitResult(onItem: (x) => print(x))
      ]);

      print(results);

      final otherResults = await Future.wait([
        NewFunctionality().inBackground().createOperator().waitResult(onItem: (x) => print(x)),
        NewFunctionality().inBackground().createOperator().waitResult(onItem: (x) => print(x)),
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

    test('Cancel extern operator', () async {
      await ApplicationManager.changeInstance(
        newInstance: DartApplicationManager(
          defineLanguageOperatorInOtherThread: false,
          reflectors: const [],
        ),
        initialize: true,
      );
      final newOperator = NewFunctionality(secondWaiting: 60).inBackground().createOperator();

      final future = newOperator.waitResult(onItem: (x) => print(x));
      future.then((x) => print(x));

      await Future.delayed(const Duration(seconds: 10));
      future.ignore();

      await Future.delayed(const Duration(seconds: 15));
    });


    
  });
}
