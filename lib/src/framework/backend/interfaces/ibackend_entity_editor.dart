import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/backend_adapters/writer_and_reader_backend_operators.dart';

mixin IBackendEntityEditor<T> {
  TextableFunctionality<List<int>> aggregator({required List<T> list});

  TextableFunctionality<void> modifier({required List<T> list});

  TextableFunctionality<void> assignor({required List<T> list});

  TextableFunctionality<void> remover({required List<int> listIDs});

  TextableFunctionality<void> totalRemover();

  static IBackendEntityEditor<T> fromEntityOperator<T>(IEntityWriter<T> writer) => EntityWriterOperatorBackend<T>(entityWriter: writer);

  static IBackendEntityEditor<T> fromEntityOperatorInService<S extends Object, T>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<IEntityWriter<T>> Function(S, InvocationParameters) functionalityGetter,
  }) =>
      EntityWriterOperatorBackendOnService<S, T>(
        parameters: parameters,
        functionalityGetter: functionalityGetter,
      );
}
