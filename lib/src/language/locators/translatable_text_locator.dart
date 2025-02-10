import 'dart:io';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/itranslatable_text_locator.dart';

class TranslatableTextLocator with ITranslatableTextLocator {
  final List<String> directories;

  const TranslatableTextLocator({required this.directories});

  @override
  Future<Set<String>> searchTranslatableText() async {
    await ApplicationManager.changeInstance(
      newInstance: DartApplicationManager(
        defineLanguageOperatorInOtherThread: false,
        reflectors: const [],
      ),
      initialize: true,
    );
    final Set<String> texts = {};

    final realAddress = <String>[];

    for (final item in directories) {
      final mask = FileOperatorMask(isLocal: false, rawRoute: item);
      await mask.initialize();
      realAddress.add(mask.directAddress);
    }

    for (var directoryPath in realAddress) {
      final directory = Directory(directoryPath);

      await for (var entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final contents = await entity.readAsString();

          final trRegex = RegExp(r"tr\(\s*'(.*?)'\s*\)");
          final trcRegex = RegExp(r"trc\(\s*'(.*?)'");
          final messageRegex = RegExp(r"Oration\(\s*message:\s*'([^']*)'", dotAll: true);

          for (var match in trRegex.allMatches(contents)) {
            texts.add(match.group(1)!);
          }

          for (var match in trcRegex.allMatches(contents)) {
            texts.add(match.group(1)!);
          }

          for (var match in messageRegex.allMatches(contents)) {
            final text = match.group(1)!;
            print('TR: $text');
            texts.add(text);
          }
        }
      }
    }

    return texts;
  }
}
