mixin ITaskFunctionality {
  int get identifier;
  bool get itIsPersistent;
  DateTime get nextTurn;

  int get attempts;
  Duration get waitToTryAgain;
  set attempts(int newValue);
}
