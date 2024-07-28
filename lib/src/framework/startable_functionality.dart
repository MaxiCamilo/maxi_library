mixin StartableFunctionality {
  Future<void> initializeFunctionality();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await initializeFunctionality();
    _isInitialized = true;
  }
}
