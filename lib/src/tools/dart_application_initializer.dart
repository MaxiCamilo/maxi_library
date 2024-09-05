import 'package:maxi_library/maxi_library.dart';

class DartApplicationInitializer with StartableFunctionality {
  final String appName;
  final double appVersion;

  final IFunctionalTask loadConfiguration;
  final IOperatorLanguage languages;
  final List<IReflectorAlbum> reflectors;
  final IThreadManagersFactory serverThreads;
  final List<Future Function()> startupFunctions;

  late final SeriesFunctions _serialExecutor;
  late final SeriesFunctions _serviceLoader;

  DartApplicationInitializer({
    required this.loadConfiguration,
    required this.appName,
    required this.appVersion,
    required this.languages,
    required this.reflectors,
    required this.serverThreads,
    required this.startupFunctions,
  }) {
    _serialExecutor = SeriesFunctions(functions: [
      FunctionalTaskExpress.withoutController(_printAppVersion),
      loadConfiguration,
      FunctionalTaskExpress.withoutController(_loadReflectors),
      FunctionalTaskExpress.withoutController(_loadLanguages),
      FunctionalTaskExpress.withoutController(_loadServerThread),
      FunctionalTaskExpress.withoutController(_loadStartupFunctions),
    ]);

    _serviceLoader = SeriesFunctions(
      functions: startupFunctions
          .map(
            (x) => FunctionalTaskExpress.withoutController(x),
          )
          .toList(),
    );
  }

  Future<void> executeUntilCompletion({Duration waitForReExecution = const Duration(seconds: 3)}) async {
    while (true) {
      try {
        await initialize();
        break;
      } catch (ex) {
        final nr = NegativeResult.searchNegativity(item: ex, actionDescription: tr('Initiated the application'));
        nr.printConsole();
        await Future.delayed(waitForReExecution);
      }
    }
  }

  @override
  Future<void> initializeFunctionality() {
    return _serialExecutor.execute();
  }

  void cancel() => _serialExecutor.cancel();

  Future<void> _printAppVersion() async {
    print('$appName V$appVersion');
    print('----------------------------------------------------------------------------------');
  }

  Future<void> _loadReflectors() async {
    ReflectionManager.defineAlbums = reflectors;
    ReflectionManager.defineAsTheMainReflector();
  }

  Future<void> _loadLanguages() {
    return LanguageManager.changeOperator(languages);
  }

  Future<void> _loadServerThread() async {
    ThreadManager.generalFactory = serverThreads;
  }

  Future<void> _loadStartupFunctions() {
    return _serviceLoader.execute();
  }
}
