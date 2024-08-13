mixin StartableFunctionality {
  Future<void> initializeFunctionality();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await initializeFunctionality();
    _isInitialized = true;
  }
}
