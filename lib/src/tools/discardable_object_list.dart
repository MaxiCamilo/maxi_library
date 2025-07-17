import 'dart:developer';
import 'dart:math' show Random;

import 'package:maxi_library/export_reflectors.dart';

class DiscardableObjectList<I extends IDisposable> with IDisposable implements List<I> {
  final _realList = <I>[];

  DiscardableObjectList();

  void _joinItem(I value) {
    value.onDispose.whenComplete(() {
      _realList.remove(value);
    });
  }

  @override
  void add(I value) {
    _realList.add(value);
    _joinItem(value);
  }

  @override
  void addAll(Iterable<I> iterable) {
    iterable.iterar((x) => add(x));
  }

  @override
  bool remove(Object? value) {
    if (value == null) {
      return false;
    }

    final original = _realList.selectItem((x) => x == value);

    if (original == null) {
      return false;
    }
    _realList.remove(original);
    original.dispose();

    return true;
  }

  @override
  I removeAt(int index) {
    final item = _realList.removeAt(index);
    item.dispose();

    return item;
  }

  @override
  void clear() {
    _realList.iterar((x) => x.dispose());
    _realList.clear();
  }

  @override
  void operator []=(int index, I value) {
    final previous = _realList[index];
    _realList[index] = value;
    _joinItem(value);
    previous.dispose();
  }

  @override
  void insert(int index, I element) {
    _realList.insert(index, element);

    _joinItem(element);
  }

  @override
  void insertAll(int index, Iterable<I> iterable) {
    final list = iterable.toList(growable: true);
    _realList.insertAll(index, list);
    list.iterar((x) => _joinItem(x));
  }

  //#################################################################################################################################

  @override
  I get first => _realList.first;

  @override
  I get last => _realList.last;

  @override
  int get length => _realList.length;

  @override
  set first(I value) {
    this[0] = value;
  }

  @override
  set last(I value) {
    this[length - 1] = value;
  }

  @override
  set length(int newLength) {
    throw '¿?';
  }

  @override
  List<I> operator +(List<I> other) {
    return _realList + other;
  }

  @override
  I operator [](int index) {
    return _realList[index];
  }

  @override
  bool any(bool Function(I element) test) {
    return _realList.any(test);
  }

  @override
  Map<int, I> asMap() {
    return _realList.asMap();
  }

  @override
  List<R> cast<R>() {
    return _realList.cast<R>();
  }

  @override
  bool contains(Object? element) {
    return _realList.contains(element);
  }

  @override
  I elementAt(int index) {
    return _realList.elementAt(index);
  }

  @override
  bool every(bool Function(I element) test) {
    return _realList.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(I element) toElements) {
    return _realList.expand<T>(toElements);
  }

  @override
  void fillRange(int start, int end, [I? fillValue]) {
    return _realList.fillRange(start, end, fillValue);
  }

  @override
  I firstWhere(bool Function(I element) test, {I Function()? orElse}) {
    return _realList.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, I element) combine) {
    return _realList.fold<T>(initialValue, combine);
  }

  @override
  Iterable<I> followedBy(Iterable<I> other) {
    return _realList.followedBy(other);
  }

  @override
  void forEach(void Function(I element) action) {
    _realList.forEach(action);
  }

  @override
  Iterable<I> getRange(int start, int end) {
    return _realList.getRange(start, end);
  }

  @override
  int indexOf(I element, [int start = 0]) {
    return _realList.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(I element) test, [int start = 0]) {
    return indexWhere(test, start);
  }

  @override
  bool get isEmpty => _realList.isEmpty;

  @override
  bool get isNotEmpty => _realList.isNotEmpty;

  @override
  Iterator<I> get iterator => _realList.iterator;

  @override
  String join([String separator = ""]) {
    return _realList.join(separator);
  }

  @override
  int lastIndexOf(I element, [int? start]) {
    return lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(I element) test, [int? start]) {
    return _realList.lastIndexWhere(test, start);
  }

  @override
  I lastWhere(bool Function(I element) test, {I Function()? orElse}) {
    return _realList.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> map<T>(T Function(I e) toElement) {
    return _realList.map<T>(toElement);
  }

  @override
  I reduce(I Function(I value, I element) combine) {
    return _realList.reduce(combine);
  }

  @override
  I removeLast() {
    return _realList.removeAt(length - 1);
  }

  @override
  void removeRange(int start, int end) {
    _realList.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(I element) test) {
    _realList.removeWhere(test);
  }

  @override
  void replaceRange(int start, int end, Iterable<I> replacements) {
    _realList.replaceRange(start, end, replacements);
  }

  @override
  void retainWhere(bool Function(I element) test) {
    _realList.retainWhere(test);
  }

  @override
  Iterable<I> get reversed => _realList.reversed;

  @override
  void setAll(int index, Iterable<I> iterable) {
    log('OJOOOOOOOOOOOOOOOOOO!');
    _realList.setAll(index, iterable);
  }

  @override
  void setRange(int start, int end, Iterable<I> iterable, [int skipCount = 0]) {
    log('OJOOOOOOOOOOOOOOOOOO!');
    _realList.setRange(start, end, iterable, skipCount);
  }

  @override
  void shuffle([Random? random]) {
    _realList.shuffle(random);
  }

  @override
  I get single => _realList.single;

  @override
  I singleWhere(bool Function(I element) test, {I Function()? orElse}) {
    return _realList.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<I> skip(int count) {
    return _realList.skip(count);
  }

  @override
  Iterable<I> skipWhile(bool Function(I value) test) {
    return _realList.skipWhile(test);
  }

  @override
  void sort([int Function(I a, I b)? compare]) {
    _realList.sort(compare);
  }

  @override
  List<I> sublist(int start, [int? end]) {
    return _realList.sublist(start, end);
  }

  @override
  Iterable<I> take(int count) {
    return _realList.take(count);
  }

  @override
  Iterable<I> takeWhile(bool Function(I value) test) {
    return _realList.takeWhile(test);
  }

  @override
  List<I> toList({bool growable = true}) {
    return _realList.toList(growable: growable);
  }

  @override
  Set<I> toSet() {
    return _realList.toSet();
  }

  @override
  Iterable<I> where(bool Function(I element) test) {
    return _realList.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _realList.whereType();
  }

  @override
  void performObjectDiscard() {
    clear();
  }
}
