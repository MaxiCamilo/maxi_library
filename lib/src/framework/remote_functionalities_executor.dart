import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';

mixin RemoteFunctionalitiesExecutor on IDisposable {
  TextableFunctionality< T> executeInteractiveFunctionality<T, F extends TextableFunctionality<T>>({InvocationParameters parameters = InvocationParameters.emptry});
  TextableFunctionality<T> executeInteractiveFunctionalityViaName<T>({required String functionalityName, InvocationParameters parameters = InvocationParameters.emptry});

  static RemoteFunctionalitiesExecutor fromStream({required Stream<Map<String, dynamic>> input, required StreamSink<Map<String, dynamic>> output}) => RemoteFunctionalitiesExecutorStream(input: input, output: output);
}
