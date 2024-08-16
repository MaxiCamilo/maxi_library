import 'dart:async';

extension ExtensionsCompleters<T> on Completer<T> {
  void completeIfIncomplete([FutureOr<T>? value]) {
    if (!isCompleted) {
      complete(value);
    }
  }

  void completeErrorIfIncomplete(Object error, [StackTrace? stackTrace]) {
    if (!isCompleted) {
      completeError(error, stackTrace);
    }
  }
}
