import 'package:maxi_library/maxi_library.dart';

mixin IEntityWriter<T> {
  Stream<void> get notifyListChanged;
  Stream<List<int>> get notifyAssignedItems;
  Stream<List<int>> get notifyDeletedItems;
  Stream<void> get notifyTotalElimination;

  TextableFunctionality<void> add({required List<T> list});

  TextableFunctionality<void> modify({required List<T> list});

  TextableFunctionality<void> assign({required List<T> list});

  TextableFunctionality<void> delete({required List<int> listIDs});

  TextableFunctionality<void> deleteAll();

  Future<bool> checkUniqueProperties({required T item});

  Future<R> reserve<R>(Future<R> Function() function);

  Stream<R> reserveStream<R>(Future<Stream<R>> Function() function);

  Future<void> deleteAllAsFuture() {
    return deleteAll().executeAndWait();
  }

  Future<void> deleteAsFuture({required List<int> listIDs}) {
    return delete(listIDs: listIDs).executeAndWait();
  }

  Future<void> addAsFuture({required List<T> list}) {
    return add(list: list).executeAndWait();
  }

  Future<void> modifyAsFuture({required List<T> list}) {
    return modify(list: list).executeAndWait();
  }

  Future<void> assignAsFuture({required List<T> list}) {
    return assign(list: list).executeAndWait();
  }
}
