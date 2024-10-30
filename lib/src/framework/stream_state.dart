mixin StreamState<S, R> {}

mixin FunctionalStream<S, R> {
  Stream<StreamState<S, R>> execute();
}
