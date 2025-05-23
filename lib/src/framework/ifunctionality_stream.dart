import 'package:maxi_library/maxi_library.dart';
import 'package:meta/meta.dart';

mixin IStreamFunctionality<T> {
  @protected
  bool get cancelIfItsInactive => true;

  @protected
  StreamStateTexts<T> runFunctionality({required FunctionalityStreamManager<T> manager});

  @protected
  void onThereIsNewListener({required FunctionalityStreamManager<T> manager}) {}

  @protected
  void onThereAreNoListeners({required FunctionalityStreamManager<T> manager}) {}

  @protected
  void onError({required FunctionalityStreamManager<T> manager, required dynamic error, required StackTrace stackTrace}) {}

  @protected
  void onResult({required FunctionalityStreamManager<T> manager, required T result}) {}

  @protected
  void onCancel({required FunctionalityStreamManager<T> manager}) {}

  @protected
  void onManagerDispose() {}

  @protected
  void onFinish({required FunctionalityStreamManager<T> manager, T? possibleResult, NegativeResult? possibleError}) {}

  FunctionalityStreamManager<T> createManager() => FunctionalityStreamManager<T>(functionality: this);
  StreamStateTexts<T> runWithoutManager({required void Function(T) then, void Function(dynamic, StackTrace)? onError}) => createManager().startAndBePending(then: then, onError: onError);

  StreamStateTexts<R> joinManager<R>({
    FunctionalityStreamManager<T>? manager,
    required FunctionalityStreamManager<R> otherManager,
    required void Function(T) then,
    void Function(dynamic, StackTrace)? onError,
    bool errorAreFatals = true,
  }) async* {
    manager ??= createManager();
    yield* manager.joinManager(otherManager: otherManager, then: then, errorAreFatals: errorAreFatals, onError: onError);
  }

  Future<T> waitResult({
    void Function(Oration)? onText,
    PaternalFunctionality? parent,
  }) {
    final manager = createManager();
    if (parent != null) {
      parent.joinDisponsabeObject(item: manager);
    }

    return manager.waitResult(onText: onText);
  }
}

extension VoidFunctionalityStreamManager on IStreamFunctionality<void> {
  StreamStateTexts<void> startAndWait({void Function()? then, void Function(dynamic, StackTrace)? onError}) {
    return runWithoutManager(
      then: (_) {
        if (then != null) {
          then();
        }
      },
      onError: onError,
    );
  }

  StreamStateTexts<R> joinManagerWithoutResult<R>({
    FunctionalityStreamManager<void>? manager,
    required FunctionalityStreamManager<R> otherManager,
    void Function()? then,
    void Function(dynamic, StackTrace)? onError,
    bool errorAreFatals = true,
  }) =>
      joinManager(
          otherManager: otherManager,
          onError: onError,
          errorAreFatals: errorAreFatals,
          then: (_) {
            if (then != null) {
              then();
            }
          });
}
