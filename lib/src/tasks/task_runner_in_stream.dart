import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';

class TaskRunnerInStream with IDisposable {
  final StreamSink sender;
  final Stream receiver;
  final FutureOr<TextableFunctionality> Function(TaskRunnerInStream, int, dynamic) functionalityCreator;

  final _activeTasks = <InteractiveFunctionalityOperator>[];

  int _lastID = 1;

  TaskRunnerInStream({
    required this.sender,
    required this.receiver,
    required this.functionalityCreator,
    int initialIdentifier = 1,
  }) {
    _lastID = initialIdentifier;
    sender.done.whenComplete(dispose);
    receiver.listen(
      _processRequest,
      onDone: dispose,
    );
  }

  factory TaskRunnerInStream.asJsonChannel({
    required Stream receiver,
    required StreamSink sender,
    required bool ignoreIfNotJSON,
    required FutureOr<TextableFunctionality> Function(TaskRunnerInStream runner, int taskID, Map<String, dynamic> data) functionalityCreator,
    bool Function(Map<String, dynamic>)? filterPackage,
    int initialIdentifier = 1,
  }) {
    return TaskRunnerInStream(
      sender: sender,
      initialIdentifier: initialIdentifier,
      receiver: receiver.map((x) => _checkIfJson(item: x, filterPackage: filterPackage, ignoreIfNotJSON: ignoreIfNotJSON)).whereNotNull(),
      functionalityCreator: (oper, id, pack) async {
        if (pack is NegativeResult) {
          throw pack;
        }

        return await functionalityCreator(oper, id, pack as Map<String, dynamic>);
      },
    );
  }

  static dynamic _checkIfJson({required dynamic item, required bool ignoreIfNotJSON, required bool Function(Map<String, dynamic>)? filterPackage}) {
    if (item is Map<String, dynamic>) {
      if (filterPackage == null) {
        return item;
      } else {
        return filterPackage(item) ? item : null;
      }
    }

    if (item is String) {
      try {
        final mapItem = ConverterUtilities.interpretToObjectJson(text: item);
        return _checkIfJson(item: mapItem, filterPackage: filterPackage, ignoreIfNotJSON: ignoreIfNotJSON);
      } catch (_) {}
    }

    if (ignoreIfNotJSON) {
      return null;
    } else {
      return NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: const Oration(message: 'Only requests in JSON format are processed'),
      );
    }
  }

  bool cancelViaEvent(Map<String, dynamic> event) {
    if (event.containsKey('\$type') && event['\$type'] == 'cancel') {
      return false;
    }

    final id = event.getRequiredValueWithSpecificType<int>('id');

    final task = _activeTasks.selectItem((x) => x.identifier == id);

    if (task == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(message: 'Task number %1 was not found', textParts: [id]),
      );
    }

    task.cancel();
    return true;
  }

  Future<void> _processRequest(event) async {
    final id = _lastID;
    _lastID += 1;

    InteractiveFunctionalityOperator<Oration, dynamic>? functionalityOperator;

    try {
      sender.add({
        '\$type': 'newTask',
        'id': id,
      });

      final newFunctionality = await functionalityCreator(this, id, event);
      functionalityOperator = newFunctionality.createOperator(identifier: id);

      _activeTasks.add(functionalityOperator);

      final result = await functionalityOperator.waitResult(
        onItem: (item) {
          sender.add({
            '\$type': 'text',
            'id': id,
            'content': item.serialize(),
          });
        },
      );

      sender.add({
        '\$type': 'result',
        'id': id,
        'content': result == null ? '' : ConverterUtilities.serializeToJson(result),
        'contentType': result == null ? 'void' : result.runtimeType.toString(),
      });
    } catch (ex) {
      final rn = NegativeResult.searchNegativity(item: ex, actionDescription: const Oration(message: 'Executing task'));
      sender.add({
        '\$type': 'error',
        'id': id,
        'content': rn.serialize(),
      });
    } finally {
      if (functionalityOperator != null) {
        _activeTasks.remove(functionalityOperator);
      }
    }
  }

  @override
  void performObjectDiscard() {
    _activeTasks.iterar((x) => x.cancel());
    _activeTasks.clear();
  }
}
