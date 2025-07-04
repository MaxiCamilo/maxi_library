import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/tools/backend_adapters/writer_and_reader_backend_operators.dart';

mixin IBackendEntityTable<T> on IBackendEntityEditor<T>, IBackendEntityQuery<T> {
  Stream get notifyListChanged;

  static IBackendEntityTable<T> fromEntityOperator<T>(IEntityTable<T> table) => EntityTableOperatorBackend<T>(tableOperator: table);

  static IBackendEntityTable<T> fromEntityOperatorInService<S extends Object, T>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<IEntityTable<T>> Function(S serv, InvocationParameters para) functionalityGetter,
  }) =>
      EntityTableOperatorBackendOnService<S, T>(
        parameters: parameters,
        functionalityGetter: functionalityGetter,
      );
}
