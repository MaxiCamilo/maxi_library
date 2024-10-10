mixin FunctionalityUtilities {
  static Future<T> eternalRetry<T>({
    required Future<T> Function() function,
     Duration waitingDuration  =const Duration(seconds: 3),
    void Function(dynamic)? doError,
  }) async {
    do {
      try {
        return await function();
      } catch (ex) {
        if (doError == null) {
          print('[X] -> $ex');
        } else {
          doError(ex);
        }

        await Future.delayed(waitingDuration);
      }
    } while (true);
  }
}
