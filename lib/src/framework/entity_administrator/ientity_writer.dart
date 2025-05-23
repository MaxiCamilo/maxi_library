import 'package:maxi_library/maxi_library.dart';

mixin IEntityWriter<T> {
  Stream<void> get notifyListChanged;
  Stream<List<int>> get notifyAssignedItems;
  Stream<List<int>> get notifyDeletedItems;
  Stream<void> get notifyTotalElimination;

  Stream<StreamState<Oration, void>> add({required List<T> list});

  Stream<StreamState<Oration, void>> modify({required List<T> list});

  Stream<StreamState<Oration, void>> assign({required List<T> list});

  Stream<StreamState<Oration, void>> delete({required List<int> listIDs});

  Stream<StreamState<Oration, void>> deleteAll();

  Future<bool> checkUniqueProperties({required T item});

  Future<R> reserve<R>(Future<R> Function() function);

  Stream<R> reserveStream<R>(Future<Stream<R>> Function() function);

  Future<void> deleteAllAsFuture() {
    return ExpressFunctionalityStream(stream: deleteAll()).waitResult();
  }

  Future<void> deleteAsFuture({required List<int> listIDs}) {
    return ExpressFunctionalityStream(stream: delete(listIDs: listIDs)).waitResult();
  }

  Future<void> addAsFuture({required List<T> list}) {
    return ExpressFunctionalityStream(stream: add(list: list)).waitResult();
  }

  Future<void> modifyAsFuture({required List<T> list}) {
    return ExpressFunctionalityStream(stream: modify(list: list)).waitResult();
  }

  Future<void> assignAsFuture({required List<T> list}) {
    return ExpressFunctionalityStream(stream: assign(list: list)).waitResult();
  }
}
