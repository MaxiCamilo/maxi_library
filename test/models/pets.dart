import 'package:maxi_library/maxi_library.dart';

import 'mammal.dart';

class TestConst {
  final String name;

  const TestConst({required this.name});
}

@reflect
enum TypeAnimal { cat, dog, bird, monster }

@reflect
class Pets with Mammal {
  String name = '';
  int age = 0;
  TypeAnimal type = TypeAnimal.cat;
  bool isBeautiful = true;

  bool get doesThisThingMeow => type == TypeAnimal.cat;

  set putNickName(String nickname) => print('that is very ugly :(');

  Pets();

  factory Pets.makeMonster({String name = 'zombie', int age = 69, TestConst test = const TestConst(name: 'jeje')}) => Pets()
    ..name = name
    ..age = age
    ..type = TypeAnimal.monster;

  @override
  String sayHi(String namePerson) {
    return switch (type) {
      TypeAnimal.cat => 'Miau',
      TypeAnimal.dog => 'Guau',
      TypeAnimal.bird => 'Pio pio',
      TypeAnimal.monster => 'RAAAWWWW',
    };
  }
}
