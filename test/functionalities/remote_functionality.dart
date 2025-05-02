import 'dart:math';

import 'package:maxi_library/maxi_library.dart';

@reflect
class RemoteFunctionality with IFunctionality<Future<String>> {
  final String name;
  final int timeout;

  const RemoteFunctionality({required this.name, required this.timeout});

  @override
  Future<String> runFunctionality() async {
    print('Name: $name');
    print('waiting: $timeout');

    await Future.delayed(Duration(seconds: timeout));

    if (Random().nextBool()) {
      throw NegativeResult(identifier: NegativeResultCodes.abnormalOperation, message: const Oration(message: 'Auch!'));
    }

    return '$name finished!';
  }
}
