import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/isolated_interactable_funcionality_executor.dart';
import 'package:maxi_library/src/framework/interactable_functionality_operators/isolated_interactable_functionality_operator.dart';

class IsolatedInteractingFunctionalitiesManager {
  static IsolatedInteractingFunctionalitiesManager? _instance;

  IsolatedInteractingFunctionalitiesManager._();

  static IsolatedInteractingFunctionalitiesManager get singleton {
    _instance ??= IsolatedInteractingFunctionalitiesManager._();
    return _instance!;
  }

  final _externalFunctionalities = <IsolatedInteractableFunctionalityOperator>[];
  final _internalFunctionalities = <IsolatedInteractableFuncionalityExecutor>[];

  int _lastId = 1;

  void asignExternal(IsolatedInteractableFunctionalityOperator item) {
    _externalFunctionalities.add(item);
    item.onDispose.whenComplete(() => _externalFunctionalities.remove(item));
  }

  int mounthFunctionality<I, R>({required InteractableFunctionality<I, R> functionality, required IThreadInvoker invoker}) {
    final id = _lastId;
    _lastId += 1;

    final newOperator = IsolatedInteractableFuncionalityExecutor<I, R>(functionality: functionality, identifier: id, invoker: invoker);
    _internalFunctionalities.add(newOperator);
    newOperator.onDone.whenComplete(() => _internalFunctionalities.remove(newOperator));

    return id;
  }

  IsolatedInteractableFunctionalityOperator? _getExternal(int idetifier) {
    final item = _externalFunctionalities.selectItem((x) => x.identifier == idetifier);

    if (item == null) {
      print('[IsolatedInteractableFunctionalityOperator] External operator $idetifier not found');
    }

    return item;
  }

  IsolatedInteractableFuncionalityExecutor? _getInternal(int idetifier) {
    final item = _internalFunctionalities.selectItem((x) => x.identifier == idetifier);

    if (item == null) {
      print('[IsolatedInteractableFunctionalityOperator] Internal operator $idetifier not found');
    }

    return item;
  }

  void cancelFunctionality(int id) {
    final internalOperator = _getInternal(id);
    if (internalOperator == null) {
      return;
    }

    internalOperator.cancel();
  }

  void receiveItem({required int id, required dynamic item}) {
    final externalOperator = _getExternal(id);
    if (externalOperator == null) {
      return;
    }

    externalOperator.receiveItem(item);
  }

  void receiveResult({required int id, required dynamic result}) {
    final externalOperator = _getExternal(id);
    if (externalOperator == null) {
      return;
    }
    externalOperator.receiveResult(result);
  }

  void receiveError({required int id, required NegativeResult error, required StackTrace stackTrace}) {
    final externalOperator = _getExternal(id);
    if (externalOperator == null) {
      return;
    }
    externalOperator.receiveError(error: error, stackTrace: stackTrace);
  }
}
