import 'dart:async';
import 'dart:collection';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:meta/meta.dart';

abstract class TemplateLanguageOperator with StartableFunctionality, IOperatorLanguage, IThreadInitializer {
  final _languageChangeNotifier = StreamController.broadcast();

  late String _prefixLanguage;
  SplayTreeMap<String, String> _transateMap = SplayTreeMap.from({});

  @override
  String get prefixLanguage => _prefixLanguage;

  @override
  Stream get notifyLanguageChange => _languageChangeNotifier.stream;

  @protected
  Future<void> initializeImplementation();

  @protected
  Future<SplayTreeMap<String, String>> obtainTranslationScheme(String prefix);

  TemplateLanguageOperator({required String selectedPrefix}) {
    _prefixLanguage = selectedPrefix;
  }

  @override
  Future<void> changeLanguage(String newPrefixLanguage) async {
    _transateMap = await obtainTranslationScheme(newPrefixLanguage);
    _prefixLanguage = newPrefixLanguage;
    _languageChangeNotifier.add(null);
  }

  @override
  String getTranslation(String reference) {
    if (isInitialized) {
      return reference;
    }

    return _transateMap[reference] ?? reference;
  }

  @override
  Future<void> initializeFunctionality() async {
    await initializeImplementation();

    final result = await containErrorLogAsync(
      detail: () => 'Downloading the translated text with prefix $_prefixLanguage',
      function: () => obtainTranslationScheme(_prefixLanguage),
    );

    if (result != null) {
      _transateMap = result;
    }

    ThreadManager.threadInitializers.add(this);
  }

  @override
  Future<void> performInitializationInThread(IThreadCommunicationMethod channel) {
    return LanguageManager.changeOperator(this);
  }
}
