@Timeout(Duration(minutes: 30))
import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

void main() {
  group('Reflection test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Generate reflectors', () async {
      await BuildReflectors.makeFilesReflection(mainFileDirection: 'test/entities/reflectors_generated.dart');
    });
  });
}
