import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';

class EntityReaderOperatorBackend<T> with IBackendEntityQuery<T> {
  final IEntityReader<T> entityReader;

  const EntityReaderOperatorBackend({required this.entityReader});

  @override
  TextableFunctionality<bool> exists({required int identifier}) => TextableFunctionality.express((_) => entityReader.exists(id: identifier));

  @override
  TextableFunctionality<T> locator({required int identifier}) => TextableFunctionality.express((_) => entityReader.locate(id: identifier));

  @override
  TextableFunctionality<List<T>> range({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) => TextableFunctionality.express(
        (_) => entityReader.selectAsFirstList(minimun: minimun, maximum: maximum, limit: limit, conditions: conditions, reverse: reverse),
      );

  @override
  TextableFunctionality<List<int>> rangeID({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) => TextableFunctionality.express(
        (_) => entityReader.selectFirstIDsAsList(minimun: minimun, maximum: maximum, limit: limit, conditions: conditions, reverse: reverse),
      );

  @override
  TextableFunctionality<Map<int, bool>> whichExist({required List<int> ids, int? limit, List<IConditionQuery> conditions = const []}) => TextableFunctionality.express(
        (_) => entityReader.checkWhichExistsAsMap(ids: ids, conditions: conditions, limit: limit),
      );
}

class EntityReaderOperatorBackendOnService<S extends Object, T> with IBackendEntityQuery<T> {
  final InvocationParameters parameters;
  final FutureOr<IEntityReader<T>> Function(S, InvocationParameters) functionalityGetter;

  const EntityReaderOperatorBackendOnService({required this.parameters, required this.functionalityGetter});

  static Future<IEntityReader<T>> _getOperator<S, T>(S serv, InvocationParameters parameters) async {
    return await parameters.last<FutureOr<IEntityReader<T>> Function(S, InvocationParameters)>()(serv, parameters);
  }

  @override
  TextableFunctionality<bool> exists({required int identifier}) => InteractiveFunctionality.fromService<S, Oration, bool>(
        parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [identifier, functionalityGetter]),
        functionalityGetter: (serv, para) async {
          return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).exists(identifier: para.penultimate<int>());
        },
      );

  @override
  TextableFunctionality<T> locator({required int identifier}) => InteractiveFunctionality.fromService<S, Oration, T>(
        parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [identifier, functionalityGetter]),
        functionalityGetter: (serv, para) async {
          return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).locator(identifier: para.penultimate<int>());
        },
      );

  @override
  TextableFunctionality<List<T>> range({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) {
    return InteractiveFunctionality.fromService<S, Oration, List<T>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [minimun, maximum, limit, conditions, reverse, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final minimun = para.reverseIndex<int?>(5);
        final maximum = para.reverseIndex<int?>(4);
        final limit = para.reverseIndex<int?>(3);
        final conditions = para.reverseIndex<List<IConditionQuery>>(2);
        final reverse = para.reverseIndex<bool>(1);

        return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).range(minimun: minimun, maximum: maximum, conditions: conditions, limit: limit, reverse: reverse);
      },
    );
  }

  @override
  TextableFunctionality<List<int>> rangeID({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) {
    return InteractiveFunctionality.fromService<S, Oration, List<int>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [minimun, maximum, limit, conditions, reverse, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final minimun = para.reverseIndex<int?>(5);
        final maximum = para.reverseIndex<int?>(4);
        final limit = para.reverseIndex<int?>(3);
        final conditions = para.reverseIndex<List<IConditionQuery>>(2);
        final reverse = para.reverseIndex<bool>(1);

        return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).rangeID(minimun: minimun, maximum: maximum, conditions: conditions, limit: limit, reverse: reverse);
      },
    );
  }

  @override
  TextableFunctionality<Map<int, bool>> whichExist({required List<int> ids, int? limit, List<IConditionQuery> conditions = const []}) {
    return InteractiveFunctionality.fromService<S, Oration, Map<int, bool>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [ids, limit, conditions, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final ids = para.reverseIndex<List<int>>(3);
        final limit = para.reverseIndex<int?>(2);
        final conditions = para.reverseIndex<List<IConditionQuery>>(1);

        return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).whichExist(ids: ids, conditions: conditions, limit: limit);
      },
    );
  }
}

class EntityWriterOperatorBackend<T> with IBackendEntityEditor<T> {
  final IEntityWriter<T> entityWriter;

  const EntityWriterOperatorBackend({required this.entityWriter});

  @override
  TextableFunctionality<List<int>> aggregator({required List<T> list}) => entityWriter.add(list: list);

  @override
  TextableFunctionality<void> assignor({required List<T> list}) => entityWriter.assign(list: list);

  @override
  TextableFunctionality<void> modifier({required List<T> list}) => entityWriter.modify(list: list);

  @override
  TextableFunctionality<void> remover({required List<int> listIDs}) => entityWriter.delete(listIDs: listIDs);

  @override
  TextableFunctionality<void> totalRemover() => entityWriter.deleteAll();
}

class EntityWriterOperatorBackendOnService<S extends Object, T> with IBackendEntityEditor<T> {
  final InvocationParameters parameters;
  final FutureOr<IEntityWriter<T>> Function(S, InvocationParameters) functionalityGetter;

  const EntityWriterOperatorBackendOnService({required this.parameters, required this.functionalityGetter});

  static Future<IEntityWriter<T>> _getOperator<S, T>(S serv, InvocationParameters parameters) async {
    return await parameters.last<FutureOr<IEntityWriter<T>> Function(S, InvocationParameters)>()(serv, parameters);
  }

  @override
  TextableFunctionality<List<int>> aggregator({required List<T> list}) {
    return InteractiveFunctionality.fromService<S, Oration, List<int>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [list, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<T>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).aggregator(list: list);
      },
    );
  }

  @override
  TextableFunctionality<void> assignor({required List<T> list}) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [list, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<T>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).assignor(list: list);
      },
    );
  }

  @override
  TextableFunctionality<void> modifier({required List<T> list}) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [list, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<T>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).modifier(list: list);
      },
    );
  }

  @override
  TextableFunctionality<void> remover({required List<int> listIDs}) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [listIDs, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<int>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).remover(listIDs: list);
      },
    );
  }

  @override
  TextableFunctionality<void> totalRemover() {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [functionalityGetter]),
      functionalityGetter: (serv, para) async {
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).totalRemover();
      },
    );
  }
}

class EntityTableOperatorBackend<T> with IBackendEntityQuery<T>, IBackendEntityEditor<T>, IBackendEntityTable<T> {
  final IEntityTable<T> tableOperator;

  @override
  Stream get notifyListChanged => tableOperator.notifyListChanged;

  const EntityTableOperatorBackend({required this.tableOperator});

  @override
  TextableFunctionality<bool> exists({required int identifier}) => TextableFunctionality.express((_) => tableOperator.exists(id: identifier));

  @override
  TextableFunctionality<T> locator({required int identifier}) => TextableFunctionality.express((_) => tableOperator.locate(id: identifier));

  @override
  TextableFunctionality<List<T>> range({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) => TextableFunctionality.express(
        (_) => tableOperator.selectAsFirstList(minimun: minimun, maximum: maximum, limit: limit, conditions: conditions, reverse: reverse),
      );

  @override
  TextableFunctionality<List<int>> rangeID({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) => TextableFunctionality.express(
        (_) => tableOperator.selectFirstIDsAsList(minimun: minimun, maximum: maximum, limit: limit, conditions: conditions, reverse: reverse),
      );

  @override
  TextableFunctionality<Map<int, bool>> whichExist({required List<int> ids, int? limit, List<IConditionQuery> conditions = const []}) => TextableFunctionality.express(
        (_) => tableOperator.checkWhichExistsAsMap(ids: ids, conditions: conditions, limit: limit),
      );

  @override
  TextableFunctionality<List<int>> aggregator({required List<T> list}) => tableOperator.add(list: list);

  @override
  TextableFunctionality<void> assignor({required List<T> list}) => tableOperator.assign(list: list);

  @override
  TextableFunctionality<void> modifier({required List<T> list}) => tableOperator.modify(list: list);

  @override
  TextableFunctionality<void> remover({required List<int> listIDs}) => tableOperator.delete(listIDs: listIDs);

  @override
  TextableFunctionality<void> totalRemover() => tableOperator.deleteAll();
}

class EntityTableOperatorBackendOnService<S extends Object, T> with IBackendEntityQuery<T>, IBackendEntityEditor<T>, IBackendEntityTable<T> {
  final InvocationParameters parameters;
  final FutureOr<IEntityTable<T>> Function(S, InvocationParameters) functionalityGetter;

  const EntityTableOperatorBackendOnService({required this.parameters, required this.functionalityGetter});

  static Future<IEntityTable<T>> _getOperator<S, T>(S serv, InvocationParameters parameters) async {
    return await parameters.last<FutureOr<IEntityTable<T>> Function(S, InvocationParameters)>()(serv, parameters);
  }

  @override
  Stream get notifyListChanged async* {
    yield* await ThreadManager.callEntityStream<S, dynamic>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [functionalityGetter]),
      function: (serv, para) async {
        return (await _getOperator(serv, para)).notifyListChanged;
      },
    );
  }

  @override
  TextableFunctionality<List<int>> aggregator({required List<T> list}) {
    return InteractiveFunctionality.fromService<S, Oration, List<int>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [list, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<T>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).aggregator(list: list);
      },
    );
  }

  @override
  TextableFunctionality<void> assignor({required List<T> list}) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [list, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<T>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).assignor(list: list);
      },
    );
  }

  @override
  TextableFunctionality<void> modifier({required List<T> list}) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [list, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<T>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).modifier(list: list);
      },
    );
  }

  @override
  TextableFunctionality<void> remover({required List<int> listIDs}) {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [listIDs, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final list = para.reverseIndex<List<int>>(1);
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).remover(listIDs: list);
      },
    );
  }

  @override
  TextableFunctionality<void> totalRemover() {
    return InteractiveFunctionality.fromService<S, Oration, void>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [functionalityGetter]),
      functionalityGetter: (serv, para) async {
        return EntityWriterOperatorBackend<T>(entityWriter: await _getOperator(serv, para)).totalRemover();
      },
    );
  }

  @override
  TextableFunctionality<bool> exists({required int identifier}) => InteractiveFunctionality.fromService<S, Oration, bool>(
        parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [identifier, functionalityGetter]),
        functionalityGetter: (serv, para) async {
          return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).exists(identifier: para.penultimate<int>());
        },
      );

  @override
  TextableFunctionality<T> locator({required int identifier}) => InteractiveFunctionality.fromService<S, Oration, T>(
        parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [identifier, functionalityGetter]),
        functionalityGetter: (serv, para) async {
          return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).locator(identifier: para.penultimate<int>());
        },
      );

  @override
  TextableFunctionality<List<T>> range({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) {
    return InteractiveFunctionality.fromService<S, Oration, List<T>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [minimun, maximum, limit, conditions, reverse, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final minimun = para.reverseIndex<int?>(5);
        final maximum = para.reverseIndex<int?>(4);
        final limit = para.reverseIndex<int?>(3);
        final conditions = para.reverseIndex<List<IConditionQuery>>(2);
        final reverse = para.reverseIndex<bool>(1);

        return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).range(minimun: minimun, maximum: maximum, conditions: conditions, limit: limit, reverse: reverse);
      },
    );
  }

  @override
  TextableFunctionality<List<int>> rangeID({int? minimun, int? maximum, int? limit, List<IConditionQuery> conditions = const [], bool reverse = false}) {
    return InteractiveFunctionality.fromService<S, Oration, List<int>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [minimun, maximum, limit, conditions, reverse, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final minimun = para.reverseIndex<int?>(5);
        final maximum = para.reverseIndex<int?>(4);
        final limit = para.reverseIndex<int?>(3);
        final conditions = para.reverseIndex<List<IConditionQuery>>(2);
        final reverse = para.reverseIndex<bool>(1);

        return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).rangeID(minimun: minimun, maximum: maximum, conditions: conditions, limit: limit, reverse: reverse);
      },
    );
  }

  @override
  TextableFunctionality<Map<int, bool>> whichExist({required List<int> ids, int? limit, List<IConditionQuery> conditions = const []}) {
    return InteractiveFunctionality.fromService<S, Oration, Map<int, bool>>(
      parameters: InvocationParameters.addParameters(original: parameters, fixedParameters: [ids, limit, conditions, functionalityGetter]),
      functionalityGetter: (serv, para) async {
        final ids = para.reverseIndex<List<int>>(3);
        final limit = para.reverseIndex<int?>(2);
        final conditions = para.reverseIndex<List<IConditionQuery>>(1);

        return EntityReaderOperatorBackend<T>(entityReader: await _getOperator(serv, para)).whichExist(ids: ids, conditions: conditions, limit: limit);
      },
    );
  }
}
