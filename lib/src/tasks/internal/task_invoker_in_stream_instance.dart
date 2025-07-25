import 'dart:async';

import 'package:maxi_library/export_reflectors.dart';

class TaskInvokerInStreamInstance<T> with TextableFunctionality<T> {
  final TaskInvokerInStream mainOperator;
  final Duration confirmationDeadline;
  final Duration? resultDeadline;
  final dynamic content;

  const TaskInvokerInStreamInstance({
    required this.mainOperator,
    required this.confirmationDeadline,
    required this.content,
    this.resultDeadline,
  });

  @override
  Future<T> runFunctionality({required InteractiveFunctionalityExecutor<Oration, T> manager}) async {
    manager.sendItemAsync(const Oration(message: 'Sending server request'));
    // ignore: invalid_use_of_protected_member
    final id = await manager.waitFuture(future: mainOperator.sendTask(content: content, timeout: confirmationDeadline));
    final waiterResult = manager.joinWaiter();

    late final String contentType;
    MaxiTimer? timer;

    manager.joinEvent(
      // ignore: invalid_use_of_protected_member
      event: mainOperator.orationStream.where((x) => x.$1 == id).map((x) => x.$2),
      onData: manager.sendItem,
    );

    manager.joinEvent(
      // ignore: invalid_use_of_protected_member
      event: mainOperator.resultStream.where((x) => x.$1 == id).map((x) => (x.$2, x.$3)),
      onData: (x) {
        contentType = x.$1;
        waiterResult.completeIfIncomplete(x.$2);
      },
    );

    manager.joinEvent(
      // ignore: invalid_use_of_protected_member
      event: mainOperator.errorStream.where((x) => x.$1 == id).map((x) => x.$2),
      onData: (x) => waiterResult.completeErrorIfIncomplete(x),
    );

    if (resultDeadline != null) {
      timer = manager.createTimer(
        duration: resultDeadline!,
        callback: () {
          waiterResult.completeErrorIfIncomplete(NegativeResult(
            identifier: NegativeResultCodes.timeout,
            message: const Oration(message: 'Excessive wait time for the server task result'),
          ));
        },
      );
    }

    mainOperator.joinDisponsabeObject(item: manager);

    manager.sendItem(const Oration(message: 'Server sent confirmation of the task, waiting for a result'));

    final rawContent = await waiterResult.future;
    timer?.cancel();

    if (contentType == '' || contentType == 'void') {
      if (T == dynamic || T.toString() == 'void') {
        return rawContent as T;
      } else {
        throw NegativeResult(
          identifier: NegativeResultCodes.wrongType,
          message: const Oration(message: 'A result of type %1 was expected, but the tara does not return anything'),
        );
      }
    }

    return ConverterUtilities.castDynamicJson(text: rawContent, type: T);
  }
}
