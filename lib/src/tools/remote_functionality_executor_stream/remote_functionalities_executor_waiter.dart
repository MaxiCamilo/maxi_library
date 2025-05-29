import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/tools/remote_functionality_executor_stream/remote_functionalities_executor_stream.dart';

class RemoteFunctionalitiesExecutorWaiter<T> with IDisposable, InteractableFunctionalityOperator<Oration, T> {
  @override
  final int identifier;
  final RemoteFunctionalitiesExecutorStream mainOperator;

  late final StreamController<Map<String, dynamic>> _streamController;
  late final InteractableFunctionalityOperator<Oration, T> _functionalityOperator;

  RemoteFunctionalitiesExecutorWaiter({required this.identifier, required this.mainOperator}) {
    _streamController = StreamController();
    _functionalityOperator = InteractableFunctionality.listenStream<Oration, T>(_streamController.stream);
    _functionalityOperator.start();
  }

  @override
  void cancel() {
    containError(function: () => mainOperator.output.add({'\$type': 'cancel', 'id': identifier}));
    dispose();
  }

  void sendMessage(Map<String, dynamic> message) {
    _streamController.addIfActive(message);
  }

  @override
  Stream<Oration> get itemStream => _functionalityOperator.itemStream;

  @override
  void performObjectDiscard() {
    _streamController.close();
    _functionalityOperator.cancel();
  }

  @override
  void start() {}

  @override
  MaxiFuture<T> waitResult({void Function(Oration item)? onItem}) => _functionalityOperator.waitResult(onItem: onItem);
}
