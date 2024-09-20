import 'package:maxi_library/maxi_library.dart';

class ThreadManagersFactoryAvoid with IThreadManagersFactory {
  const ThreadManagersFactoryAvoid();

  @override
  IThreadInvoker createServer({required List<IThreadInitializer> threadInitializer}) {
    throw NegativeResult(
      identifier: NegativeResultCodes.implementationFailure,
      message: 'You cannot create a thread manager, you must assign an already initialized one. For example, when a thread is generated as a client, you must generate the request server beforehand.',
    );
  }
}
