import 'package:maxi_library/maxi_library.dart';

class OrationTranslator with TextableFunctionality<void> {
  final TextableFunctionality<List<Oration>> Function() searcherBuilder;
  final TextableFunctionality<Map<Oration, String>> Function(List<Oration>) translatorBuilder;
  final TextableFunctionality Function(Map<Oration, String>) creatorBuilder;

  OrationTranslator({
    required this.searcherBuilder,
    required this.translatorBuilder,
    required this.creatorBuilder,
  });

  @override
  Future<void> runFunctionality({required InteractiveFunctionalityExecutor<Oration, void> manager}) async {
    manager.sendItem(const Oration(message: 'Looking for texts in files'));
    final seacher = await searcherBuilder().joinExecutor(manager);
    manager.sendItem(Oration(message: 'Translating %1 texts', textParts: [seacher.length]));
    final locatedText = await translatorBuilder(seacher).joinExecutor(manager);
    manager.sendItem(const Oration(message: 'Generating file'));
    await creatorBuilder(locatedText).joinExecutor(manager);
  }
}
