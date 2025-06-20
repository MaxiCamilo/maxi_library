import 'dart:async';
import 'dart:io';

import 'package:maxi_library/export_reflectors.dart';

class OrationSearchEngine with TextableFunctionality<List<Oration>> {
  final List<String> directories;

  static final orationPattern = RegExp(
    r'(?<!Translated)Oration\s*\(\s*((?:[^()]*\([^)]*\))*[^)]*)\)',
    multiLine: true,
  );

  static final messagePattern = RegExp(
    r'''message\s*:\s*(['"])((?:\\\1|.)*?)\1''',
    dotAll: true,
  );

  static final tokenIdPattern = RegExp(
    r'''tokenId\s*:\s*(['"])((?:\\\1|.)*?)\1''',
    dotAll: true,
  );

  const OrationSearchEngine({required this.directories});

  @override
  Future<List<Oration>> runFunctionality({required InteractiveFunctionalityExecutor<Oration, List<Oration>> manager}) async {
    final result = <Oration>[];

    final dartFiles = <File>[];

    for (final route in directories) {
      final list = await Directory(route).list(recursive: true).where((e) => e is File && e.path.endsWith('.dart')).cast<File>().toList();
      dartFiles.addAll(list);
    }

    for (final file in dartFiles) {
      final content = await file.readAsString();
      final matches = orationPattern.allMatches(content);

      for (final match in matches) {
        final args = match.group(1)!;

        final messageMatch = messagePattern.firstMatch(args);
        if (messageMatch == null) continue;

        final message = _unescape(messageMatch.group(2)!);

        final tokenIdMatch = tokenIdPattern.firstMatch(args);
        final tokenId = tokenIdMatch != null ? _unescape(tokenIdMatch.group(2)!) : '';

        if (!result.any((x) => x.message == message)) {
          result.add(Oration(message: message, tokenId: tokenId));
        }
      }
    }
    //log(result.map((x) => x.message).join('\n'));

    return result;
  }

  String _unescape(String input) {
    return input.replaceAll(r"\'", "'").replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
  }
}
