import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class EntityFileBackendAdapter<T> with IBackendEntityIndividual<T> {
  final EntityFile<T> entityOperator;

  const EntityFileBackendAdapter({required this.entityOperator});

  @override
  TextableFunctionalityVoid assigner(T newValue) {
    return TextableFunctionalityVoid.express((_) {
      return entityOperator.changeFile(newValue: newValue);
    });
  }

  @override
  TextableFunctionality<T> getter() {
    return InteractiveFunctionality.express<Oration, T>((_) {
      return entityOperator.value;
    });
  }

  @override
  TextableFunctionalityVoid remover() {
    return TextableFunctionalityVoid.express((_) {
      final original = ReflectionManager.getReflectionEntity(T).buildEntity();
      return entityOperator.changeFile(newValue: original);
    });
  }
}

class EntityFileBackendAdapterOnService<S extends Object, T> with IBackendEntityIndividual<T> {
  final InvocationParameters parameters;
  final FutureOr<EntityFile<T>> Function(S, InvocationParameters) functionalityGetter;

  const EntityFileBackendAdapterOnService({required this.parameters, required this.functionalityGetter});

  static Future<EntityFile<T>> _getOperator<S, T>(S serv, InvocationParameters parameters) async {
    return await parameters.last<FutureOr<EntityFile<T>> Function(S, InvocationParameters)>()(serv, parameters);
  }

  @override
  TextableFunctionalityVoid assigner(T newValue) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [newValue, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final item = para.reverseIndex<T>(1);
        return EntityFileBackendAdapter<T>(entityOperator: await _getOperator(serv, para)).assigner(item);
      },
    );
  }

  @override
  TextableFunctionality<T> getter() {
    return InteractiveFunctionality.fromService<S, Oration, T>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [functionalityGetter]),
      functionalityGetter: (serv, para) async {
        return EntityFileBackendAdapter<T>(entityOperator: await _getOperator(serv, para)).getter();
      },
    );
  }

  @override
  TextableFunctionalityVoid remover() {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [functionalityGetter]),
      functionalityGetter: (serv, para) async {
        return EntityFileBackendAdapter<T>(entityOperator: await _getOperator(serv, para)).remover();
      },
    );
  }
}
