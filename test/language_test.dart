@Timeout(Duration(minutes: 30))
import 'package:maxi_library/maxi_library.dart';

import 'package:test/test.dart';

void main() {
  group('Language test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test translators with local AI', () async {
      final translator = TranslatorViaOllama(prompt: 'Traduce al español el texto "%1", solo muestra el texto traducido');
      final result = await translator.traslateText(
          'To display the data on screen, use the FutureBuilder widget. The FutureBuilder widget comes with Flutter and makes it easy to work with asynchronous data sources. You must provide two parameters');
      print('La traducción dio: "$result"');
    });

    test('Search texts', () async {
      final locator = TranslatableTextLocator(directories: ['/home/maxiro/Proyectos/maxi_proyectos/maxi_library/lib/src']);
      final texts = await locator.searchTranslatableText();

      texts.iterar((x) => print('$x\n'));
    });

    test('Generate texts', () async {
      final builder = AutomaticTranslationGenerator(
        prefix: 'es',
        locator: TranslatableTextLocator(directories: ['/home/maxiro/Proyectos/maxi_proyectos/maxi_library/lib/src']),
        translator: TranslatorViaOllama(prompt: 'Traduce al español "%1", solo muestra el texto traducido'),
        builder: TranslatedTextBuilderJson(locationToGenerate: '/home/maxiro/Proyectos/maxi_proyectos/maxi_library/lang'),
      );

      await builder.start();
    });
/*
    test('test translated text', () async {
      await LanguageManager.changeOperator(
       LanguageOperatorDirectory(selectedPrefix: 'es', translatedFileAddress: '/home/maxiro/Proyectos/maxi_proyectos/maxi_library/lang'),
      );

      containErrorLog(detail: tr(''), function: () => 'jejeje'.convertQuickly.toInt(propertyName: tr('pepe')));
    });*/
  });
}
