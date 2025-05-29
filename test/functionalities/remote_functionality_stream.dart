import 'package:maxi_library/maxi_library.dart';

@reflect
class RemoteFunctionalityStream with TextableFunctionality<String> {
  final String name;
  final int timeout;

  const RemoteFunctionalityStream({required this.name, required this.timeout});

  @override
  Future<String> runFunctionality({required TextableFunctionalityExecutor<String> manager}) async {
    await manager.sendItemAsync(const Oration(message: 'Hi! Let\'s start this functionality'));

    for (int i = 0; i < timeout; i++) {
      await manager.sendItemAsync(Oration(message: '[%1] %2 seconds out of %3', textParts: [name, i + 1, timeout]));
      await manager.delayed(const Duration(seconds: 1));
    }

    await manager.sendItemAsync(Oration(message: '[%1] I have finished', textParts: [name]));

    return 'Bye bye';
  }
}
