import 'package:maxi_library/maxi_library.dart';

class DartApplicationInitializer with StartableFunctionality {
  final String appName;
  final double appVersion;

  final IApplicationManager appManager;
  final IFunctionalTask loadConfiguration;
  final List<Future Function()> startupFunctions;

  late final SeriesFunctions _serialExecutor;
  late final SeriesFunctions _serviceLoader;

  DartApplicationInitializer({
    required this.loadConfiguration,
    required this.appName,
    required this.appVersion,
    required this.startupFunctions,
    required this.appManager,
  }) {
    _serialExecutor = SeriesFunctions(functions: [
      FunctionalTaskExpress.withoutController(_printAppVersion),
      FunctionalTaskExpress.withoutController(_makeAppManager),
      loadConfiguration,
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

  Future<void> _loadStartupFunctions() {
    return _serviceLoader.execute();
  }

  Future<void> _makeAppManager() async {
    await appManager.initialize();
  }
}
