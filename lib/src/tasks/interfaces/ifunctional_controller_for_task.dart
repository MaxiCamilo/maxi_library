mixin IFunctionalControllerForTask {
  void checkState();
  Future<void> wait(Duration duration);
  void interruptWait();
}
