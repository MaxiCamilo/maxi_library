import 'package:maxi_library/maxi_library.dart';

mixin ApplicationManager {
  static bool get isDefined => _instance != null;

  static IApplicationManager? _instance;

  static IApplicationManager get instance {
    if (_instance == null) {
      throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: Oration(message: 'Application operator not setter and initialized'));
    }

    return _instance!;
  }

  static Future<T> changeInstance<T extends IApplicationManager>({required T newInstance, required bool initialize}) async {
    if (_instance != null) {
      throw NegativeResult(identifier: NegativeResultCodes.contextInvalidFunctionality, message: Oration(message: 'An application operator has already been initialized'));
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

    return _instance as T;
  }

  static changeInstanceIfInactive<T extends IApplicationManager>({required T newInstance, required bool initialize}) async {
    if (!isDefined) {
      await changeInstance<T>(newInstance: newInstance, initialize: initialize);
    }
  }
}
