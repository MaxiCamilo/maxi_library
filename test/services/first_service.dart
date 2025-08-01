import 'dart:developer';
import 'dart:math' as math;

import 'package:maxi_library/maxi_library.dart';

import '../functionalities/new_functionality.dart';
import 'second_service.dart';

@reflect
class FirstService with StartableFunctionality, IThreadService {
  final bool isMustFail;

  FirstService({required this.isMustFail});

  @override
  String get serviceName => 'First services';

  @override
  Future<void> initializeFunctionality() async {
    log('¡Hi Susana!');

    if (isMustFail) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: Oration(message: 'Hey! I must fail'));
    }
  }

  Future<String> passSomeText() async {
    log('Wait a few secons');
    await Future.delayed(Duration(seconds: 5));
    return 'Jejejejeje';
  }

  Future<int> passSomeNumber() async {
    log('Wait a few secons');
    await Future.delayed(Duration(seconds: 5));
    return math.Random().nextInt(99999) + 1;
  }

  Stream<String> generateSomeText({required int amount, required int waitingSeconds}) async* {
    await Future.delayed(Duration(seconds: 100));
    for (int i = 1; i < amount; i++) {
      final text = 'Going by number $i';
      log('Going to send N° $i = "$text"');
      yield text;
      await Future.delayed(Duration(seconds: waitingSeconds));
    }

    log('Ended the stream');
  }

  Future<void> createPipeInSecondService() async {
    final newPipe = await ThreadManager.createEntityChannel<SecondService, int, String>(
      function: (entity, context, pipe) => entity.usePipe(pipe),
    );

    newPipe.receiver.listen((x) => log('Thread sent "$x"'));

    await Future.delayed(Duration(seconds: 3));
    newPipe.add(1);
    await Future.delayed(Duration(seconds: 3));
    newPipe.add(2);
    await Future.delayed(Duration(seconds: 1));
    newPipe.add(3);
    await Future.delayed(Duration(seconds: 1));
    newPipe.add(4);
    await Future.delayed(Duration(seconds: 1));
    newPipe.add(5);
    await Future.delayed(Duration(seconds: 1));

    await newPipe.done;

    await Future.delayed(Duration(seconds: 5));
  }

  Future<String> callBackgroudFunctionality() async {
    final funcOperator = NewFunctionality().inBackground().createOperator();

    //Future.delayed(const Duration(seconds: 5)).whenComplete(() => funcOperator.cancel());

    return await funcOperator.waitResult(
      onItem: (x) => log(x.toString()),
    );
  }
}
