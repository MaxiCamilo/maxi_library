@Timeout(Duration(minutes: 30))
import 'dart:math' show Random;

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

Future<int> _otherFunction() async {
  return await _anotherOneOfAnotherFunction();
}

Future<int> _anotherOneOfAnotherFunction() async {
  final random = Random();

  if (random.nextBool()) {
    throw NegativeResult(identifier: NegativeResultCodes.abnormalOperation, message: const Oration(message: 'Holy shit!'));
  }

  return 21;
}

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test semaphore', () async {
      final semaphore = Semaphore();
      try {
        await semaphore.execute(function: _otherFunction);
      } catch (ex, st) {
        print(ex.toString());
        print(st);
      }
    });

    test('Test completer', () async {
      print('Hi!');
      try {
        final completer = MaxiCompleter<int>.fromFuture(() => _otherFunction());
        print(await completer.future);
      } catch (ex, st) {
        print(ex.toString());
        print(st);
      }
    });
  });
}
