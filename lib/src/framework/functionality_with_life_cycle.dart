import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin FunctionalityWithLifeCycle on StartableFunctionality, PaternalFunctionality {
  bool get initiallyPreviouslyExecuted => _initiallyPreviouslyExecuted;

  bool _initiallyPreviouslyExecuted = false;

  Completer? _onDone;

  Future get done {
    _onDone ??= MaxiCompleter();
    return _onDone!.future;
  }

  @protected
  Future<void> afterInitializingFunctionality();

  @override
  @protected
  @mustCallSuper
  Future<void> initializeFunctionality() async {
    try {
      await afterInitializingFunctionality();
      onDispose.whenComplete(() {
        _onDone?.completeIfIncomplete();
        _onDone = null;
      });
    } catch (ex, st) {
      removeJoinedObjects();
      afterDiscard();
      _onDone?.completeErrorIfIncomplete(ex, st);
      _onDone = null;
      rethrow;
    } finally {
      _initiallyPreviouslyExecuted = true;
    }
  }

  @override
  @mustCallSuper
  void performObjectDiscard() {
    super.performObjectDiscard();
    afterDiscard();
  }

  @protected
  void afterDiscard() {}

/*
  R joinObject<R extends Object>({required R item}) {
    _otherActiveList.add(item);
    return item;
  }*/
}
