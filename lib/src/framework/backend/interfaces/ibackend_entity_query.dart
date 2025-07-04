import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/backend_adapters/writer_and_reader_backend_operators.dart';

mixin IBackendEntityQuery<T> {
  TextableFunctionality<T> locator({required int identifier});
  TextableFunctionality<bool> exists({required int identifier});

  TextableFunctionality<List<T>> range({
    int? minimun,
    int? maximum,
    int? limit,
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  });

  TextableFunctionality<List<int>> rangeID({
    int? minimun,
    int? maximum,
    int? limit,
    List<IConditionQuery> conditions = const [],
    bool reverse = false,
  });

  TextableFunctionality<Map<int, bool>> whichExist({
    required List<int> ids,
    int? limit,
    List<IConditionQuery> conditions = const [],
  });

  static IBackendEntityQuery<T> fromEntityOperator<T>(IEntityReader<T> reader) => EntityReaderOperatorBackend<T>(entityReader: reader);

  static IBackendEntityQuery<T> fromEntityOperatorInService<S extends Object, T>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<IEntityReader<T>> Function(S, InvocationParameters) functionalityGetter,
  }) =>
      EntityReaderOperatorBackendOnService<S, T>(
        parameters: parameters,
        functionalityGetter: functionalityGetter,
      );
}
