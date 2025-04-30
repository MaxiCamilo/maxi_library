import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

mixin IRemoteFunctionalitiesExecutor {
  bool get isActive;
  Future<T> executeFunctionality<T, F extends IFunctionality<FutureOr<T>>>({InvocationParameters parameters = InvocationParameters.emptry});
  StreamStateTexts<T> executeStreamFunctionality<T, F extends IStreamFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry});
}
