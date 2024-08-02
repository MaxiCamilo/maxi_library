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
      throw NegativeResult(identifier: NegativeResultCodes.invalidFunctionality, message: 'Hey! I must fail');
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
}
