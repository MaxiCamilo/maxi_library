import 'dart:developer';
import 'dart:math' as math;

import 'package:maxi_library/maxi_library.dart';

class FirstService with StartableFunctionality, ThreadService {
  final bool isMustFail;

  FirstService({required this.isMustFail});

  @override
  String get serviceName => 'First services';

  @override
  Future<void> initializeFunctionality() async {
    log('¡Hi Susana!');

    if (isMustFail) {
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: tr('Hey! I must fail'));
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
    for (int i = 1; i < amount; i++) {
      final text = 'Going by number $i';
      log('Going to send N° $i = "$text"');
      yield text;
      await Future.delayed(Duration(seconds: waitingSeconds));
    }

    log('Ended the stream');
  }
}
