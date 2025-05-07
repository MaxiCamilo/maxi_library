@Timeout(Duration(minutes: 30))
import 'package:maxi_library/maxi_library.dart';
import 'package:test/test.dart';

void main() {
  group('Reflection test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Generate file reflect', () {
      ReflectorGenerator(directories: ['test/models', 'test/old_entities', 'test/functionalities','test/services'], fileCreationPlace: '/home/maxiro/Proyectos/maxi_proyectos/maxi_library/test', albumName: 'Test').build();
    });
  });
}
