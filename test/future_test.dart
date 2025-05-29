@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';


void main() {
  group('Future test', () {
    setUp(() {});

    test('Invoke Future and ignore', () async {
      final MaxiCompleter<String> completer = MaxiCompleter<String>(
        onNoOneListen: () {
          print('Oh rayor');
        },
      );

      final first = completer.future;
      await Future.delayed(const Duration(seconds: 3));
      first.ignore();

      final second = completer.future;
      scheduleMicrotask(() async {
        await Future.delayed(const Duration(seconds: 3));
        completer.complete('jejejejeje');
      });

      print(await second);

      await Future.delayed(const Duration(seconds: 3));
    });
  });
}
