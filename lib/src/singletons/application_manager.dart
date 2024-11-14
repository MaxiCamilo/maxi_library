import 'package:maxi_library/maxi_library.dart';

mixin ApplicationManager {
  static IApplicationManager? _instance;

  static IApplicationManager get instance {
    if (_instance == null) {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: tr('Application operator not setter and initialized'));
    }

    return _instance!;
  }

  static Future<void> changeInstance({required IApplicationManager newInstance, required bool initialize}) async {
    if (_instance != null) {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: tr('An application operator has already been initialized'));
    }
    _instance = newInstance;

    if (ThreadManager.instanceDefined) {
      ThreadManager.addThreadInitializer(initializer: newInstance);
    } else {
      final factoryThread = newInstance.serverThreadsFactory;
      ThreadManager.generalFactory = factoryThread;
      ThreadManager.instance = factoryThread.createServer(threadInitializer: [newInstance]);
    }

    if (initialize) {
      await newInstance.initialize();
    }
  }
}
