mixin State<S, R> {}

mixin FunctionalStream<S, R> {
  Stream<State<S, R>> execute();
}
