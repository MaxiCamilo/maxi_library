mixin ITaskFunctionality {
  bool get itIsPersistent;
  DateTime get nextTurn;

  int get attempts;
  Duration get waitToTryAgain;
  set attempts(int newValue);
}
