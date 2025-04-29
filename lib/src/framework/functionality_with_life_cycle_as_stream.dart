import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin FunctionalityWithLifeCycleAsStream on StartableFunctionality, FunctionalityWithLifeCycle {
  StreamController<StreamState<Oration, void>>? _initializerController;

  StreamStateTextsVoid textInitializationStream({required bool initializeIsInactive}) async* {
    if (isInitialized) {
      return;
    }
    if (_initializerController == null || _initializerController!.isClosed) {
      _initializerController = StreamController<StreamState<Oration, void>>();
    }
    if (initializeIsInactive) {
      containErrorLogAsync(detail: const Oration(message: 'Initializing functionality'), function: initialize);
    }
    yield* connectFunctionalStream(_initializerController!.stream);
    print('chau!');
  }

  @protected
  StreamStateTextsVoid afterInitializingFunctionalityAsStream();

  void cancelInitialization() {
    if (!isInitialized && _initializerController != null && !_initializerController!.isClosed) {
      _initializerController?.close();
      _initializerController = null;

      removeJoinedObjects();
    }
  }

  @override
  Future<void> afterInitializingFunctionality() async {
    if (_initializerController == null || _initializerController!.isClosed) {
      _initializerController = StreamController<StreamState<Oration, void>>();
    }

    try {
      return await waitFunctionalStream(
        stream: afterInitializingFunctionalityAsStream(),
        onData: (x) => _initializerController?.addIfActive(streamTextStatus(x)),
        onError: (ex) => _initializerController?.addErrorIfActive(ex),
      );
    } finally {
      _initializerController?.close();
      _initializerController = null;
    }
  }
}
