import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/tools/backend_adapters/entity_file_backend_adapter.dart';

mixin IBackendEntityIndividual<T> {
  TextableFunctionality<T> getter();
  TextableFunctionalityVoid assigner(T newValue);
  TextableFunctionalityVoid remover();

  static IBackendEntityIndividual<T> fromFile<T>({required EntityFile<T> entityOperator}) => EntityFileBackendAdapter<T>(entityOperator: entityOperator);
  static IBackendEntityIndividual<T> fromFileOnService<S extends Object, T>({
    InvocationParameters parameters = InvocationParameters.emptry,
    required FutureOr<EntityFile<T>> Function(S serv, InvocationParameters para) functionalityGetter,
  }) =>
      EntityFileBackendAdapterOnService<S, T>(parameters: parameters, functionalityGetter: functionalityGetter);
}
