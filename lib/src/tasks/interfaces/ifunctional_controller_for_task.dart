mixin IFunctionalControllerForTask {
  checkState();
  Future<void> wait(Duration duration);
  void interruptWait();
}
