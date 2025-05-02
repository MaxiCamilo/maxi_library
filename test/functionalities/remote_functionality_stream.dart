import 'package:maxi_library/maxi_library.dart';

@reflect
class RemoteFunctionalityStream with IStreamFunctionality<String> {
  final String name;
  final int timeout;

  const RemoteFunctionalityStream({required this.name, required this.timeout});

  @override
  StreamStateTexts<String> runFunctionality({required FunctionalityStreamManager<String> manager}) async* {
    yield streamTextStatus(const Oration(message: 'Hi! Let\'s start this functionality'));

    for (int i = 0; i < timeout; i++) {
      yield streamTextStatus(Oration(message: '%1 seconds out of %2', textParts: [i + 1, timeout]));
      await Future.delayed(const Duration(seconds: 1));
    }

    yield streamTextStatus(const Oration(message: 'I have finished'));

    yield streamResult('Bye bye');
  }
}
