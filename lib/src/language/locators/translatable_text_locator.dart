import 'dart:io';

import 'package:maxi_library/src/language/interfaces/itranslatable_text_locator.dart';

class TranslatableTextLocator with ITranslatableTextLocator {
  final List<String> directories;

  const TranslatableTextLocator({required this.directories});

  @override
  Future<List<String>> searchTranslatableText() async {
    final Set<String> texts = {};

    for (var directoryPath in directories) {
      final directory = Directory(directoryPath);

      await for (var entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final contents = await entity.readAsString();

          final trRegex = RegExp(r"tr\(\s*'(.*?)'\s*\)");
          final trcRegex = RegExp(r"trc\(\s*'(.*?)'");

          for (var match in trRegex.allMatches(contents)) {
            texts.add(match.group(1)!);
          }

          for (var match in trcRegex.allMatches(contents)) {
            texts.add(match.group(1)!);
          }
        }
      }
    }

    return texts.toList();
  }
}
