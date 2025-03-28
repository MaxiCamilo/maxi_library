import 'dart:io';

import 'package:maxi_library/export_reflectors.dart';

class OrationSearchEngine with IStreamFunctionality<Set<String>> {
  final List<String> directories;

  const OrationSearchEngine({required this.directories});

  @override
  StreamStateTexts<Set<String>> runFunctionality({required FunctionalityStreamManager<void> manager}) async* {
    final result = <String>{};

    //yield* connectFunctionalStream(_searchDartFiles(manager, Directory(directory)), (x) => result.addAll(x));
    yield* connectSeveralFunctionalStream(
      streamList: directories.map((x) => ThreadManager.callBackgroundStreamSync(parameters: InvocationParameters.only(x), function: _searchDartFiles)).toList(),
      onResult: (x) => result.addAll(x),
    );

    yield* streamTextStatusSync(Oration(message: '%1 sentences have been obtained', textParts: [result.length]));
    yield streamResult(result);
  }

  static StreamStateTexts<Set<String>> _searchDartFiles(InvocationContext context) async* {
    final result = <String>{};
    final directory = Directory(context.firts<String>());

    if (!directory.existsSync()) {
      yield streamResult(result);
    }

    final dartFiles = directory.listSync(recursive: true).where((file) => file is File && file.path.endsWith('.dart'));

    for (var file in dartFiles) {
      yield* connectFunctionalStream(_extractOrationMessages(file as File), (x) => result.addAll(x));
    }

    yield streamResult(result);
  }

  static StreamStateTexts<Set<String>> _extractOrationMessages(File file) async* {
    //yield streamTextStatus(Oration(message: 'Looking for texts in %1', textParts: [file.path]));
    //await continueOtherFutures();

    final result = <String>{};
    final regex = RegExp(
      r"Oration\(.*?message:\s*'([^']+)'",
      dotAll: true,
    );

    final content = file.readAsStringSync();
    final matches = regex.allMatches(content);

    for (var match in matches) {
      final text = match.group(1);
      if (text != null) {
        result.add(text);
      }
    }

    if (result.isNotEmpty) {
      yield* streamTextStatusSync(Oration(message: 'The file %1 has %2 translatable sentences', textParts: [file.path, result.length]));
    }

    yield streamResult(result);
  }
}
