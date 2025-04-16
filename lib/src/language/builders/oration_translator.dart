import 'package:maxi_library/maxi_library.dart';

class OrationTranslator with IStreamFunctionality<void> {
  final IStreamFunctionality<List<Oration>> Function() searcherBuilder;
  final IStreamFunctionality<Map<Oration, String>> Function(List<Oration>) translatorBuilder;
  final IStreamFunctionality Function(Map<Oration, String>) creatorBuilder;

  OrationTranslator({
    required this.searcherBuilder,
    required this.translatorBuilder,
    required this.creatorBuilder,
  });

  @override
  StreamStateTexts<void> runFunctionality({required FunctionalityStreamManager<void> manager}) async* {
    yield streamTextStatus(const Oration(message: 'Looking for texts in files'));
    final seacher = await searcherBuilder().runOtherManagerAsFuture(manager: manager);
    yield streamTextStatus(Oration(message: 'Translating %1 texts', textParts: [seacher.length]));
    final locatedText = await translatorBuilder(seacher).runOtherManagerAsFuture(manager: manager);
    yield streamTextStatus(const Oration(message: 'Generating file'));
    await creatorBuilder(locatedText).runOtherManagerAsFuture(manager: manager);
  }
}
