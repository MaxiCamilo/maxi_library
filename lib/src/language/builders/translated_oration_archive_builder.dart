import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class TranslatedOrationArchiveBuilder with IStreamFunctionality<void> {
  final String destinationAddress;
  final String fileName;
  final List<String> directories;

  final IStreamFunctionality<Map<String, String>> Function(List<String>)? translateBuild;

  const TranslatedOrationArchiveBuilder({
    required this.destinationAddress,
    required this.fileName,
    required this.directories,
    this.translateBuild,
  });

  @override
  StreamStateTexts<void> runFunctionality({required FunctionalityStreamManager<void> manager}) async* {
    await ApplicationManager.changeInstanceIfInactive(
      newInstance: DartApplicationManager(defineLanguageOperatorInOtherThread: false, reflectors: const []),
      initialize: true,
    );

    yield streamTextStatus(const Oration(message: 'Looking for file sentences'));
    late final Set<String> orations;
    late final Map<String, String> actualValues;

    yield* connectSeveralFunctionalStream(
      streamList: [
        connectFunctionalStream(
          OrationSearchEngine(directories: directories).runWithoutManagerInBackground(),
          (x) => orations = x,
        ),
        connectFunctionalStream(
          ThreadManager.callBackgroundStreamSync(parameters: InvocationParameters.list([fileName, destinationAddress]), function: _getActualsText),
          (x) => actualValues = x,
        ),
      ],
    );

    if (actualValues.isEmpty) {
      yield* await ThreadManager.callBackgroundStream(parameters: InvocationParameters.list([fileName, destinationAddress, orations, translateBuild]), function: _createFile);
    } else {
      yield* await ThreadManager.callBackgroundStream(parameters: InvocationParameters.list([fileName, destinationAddress, orations, actualValues, translateBuild]), function: _mixValue);
    }
  }

  static StreamStateTexts<Map<String, String>> _getActualsText(InvocationContext context) async* {
    final fileName = context.firts<String>();
    final destinationAddress = context.second<String>();
    final file = FileOperatorMask(isLocal: false, rawRoute: '$destinationAddress/$fileName');

    if (!await file.existsFile()) {
      yield streamTextStatus(const Oration(message: 'File does not exists'));
      yield streamResult(<String, String>{});
    }

    try {
      final rawContent = await file.readTextual();
      final jsonContent = ConverterUtilities.interpretToObjectJson(text: rawContent);
      yield streamResult(jsonContent.map((x, y) => MapEntry(x, y.toString())));
    } catch (ex) {
      yield streamTextStatus(Oration(message: 'An error occurred when reading the file located in %1, a new template will be used', textParts: [ex.toString()]));
      yield streamResult(<String, String>{});
    }
  }

  static StreamStateTexts<void> _createFile(InvocationContext context) async* {
    final fileName = context.firts<String>();
    final destinationAddress = context.second<String>();
    final orations = context.third<Set<String>>();
    final translatorBuilder = context.fourth<IStreamFunctionality<Map<String, String>> Function(List<String>)?>();

    late final Map<String, String> mapValues;

    if (translatorBuilder != null) {
      final translator = translatorBuilder(orations.toList(growable: false));
      yield* connectFunctionalStream(
        translator.runWithoutManager(),
        (x) => mapValues = x,
      );
    } else {
      mapValues = Map.fromEntries(orations.map((x) => MapEntry(x, x)));
    }

    final file = FileOperatorMask(isLocal: false, rawRoute: '$destinationAddress/$fileName');
    await file.initialize();

    yield* streamTextStatusSync(Oration(message: 'Writing data in file %1', textParts: [file.directAddress]));

    final jsonValue = json.encode(mapValues);

    await file.writeText(content: jsonValue);
  }

  static StreamStateTexts<void> _mixValue(InvocationContext context) async* {
    final fileName = context.firts<String>();
    final destinationAddress = context.second<String>();
    final orations = context.third<Set<String>>();
    final actualValues = context.fourth<Map<String, String>>();
    final translatorBuilder = context.fifth<IStreamFunctionality<Map<String, String>> Function(List<String>)?>();

    final mapToFile = <String, String>{};

    if (translatorBuilder == null) {
      for (final text in orations) {
        mapToFile[text] = actualValues[text] ?? text;
      }
    } else {
      final nonExists = <String>[];

      for (final text in orations) {
        final exists = actualValues[text];
        if (exists == null) {
          nonExists.add(text);
        } else {
          mapToFile[text] = exists;
        }
      }

      if (nonExists.isNotEmpty) {
        final translator = translatorBuilder(nonExists);
        yield* connectFunctionalStream(
          translator.runWithoutManager(),
          (x) => mapToFile.addAll(x),
        );
      }
    }

    final file = FileOperatorMask(isLocal: false, rawRoute: '$destinationAddress/$fileName');
    await file.initialize();

    yield* streamTextStatusSync(Oration(message: 'Writing data in file %1', textParts: [file.directAddress]));

    final jsonValue = json.encode(mapToFile);
    await file.writeText(content: jsonValue);
  }
}
