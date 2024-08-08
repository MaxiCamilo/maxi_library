import 'package:maxi_library/maxi_library.dart';

class GeneratorList<T> with IValueGenerator, IReflectionType {
  @override
  final List annotations;

  const GeneratorList({this.annotations = const []});

  @override
  Type get type => List<T>;

  @override
  String get name => 'List<$T>';

  @override
  bool isCompatible(item) {
    return item is Iterable;
  }

  @override
  generateEmptryObject() {
    return <T>[];
  }

  @override
  convertObject(originalItem) {
    if (originalItem is Iterable<T>) {
      return originalItem.toList();
    } else if (originalItem is Iterable) {
      final newList = <T>[];
      int i = 1;
      for (final part in originalItem) {
        if (part is T) {
          newList.add(part);
        } else {
          throw NegativeResult(
            identifier: NegativeResultCodes.wrongType,
            message: 'The item N° $i is ${part.runtimeType}, but only objects of type $T are accepted (and it is incompatible)',
          );
        }
      }

      return newList;
    } else if (originalItem is T) {
      return [originalItem];
    }

    throw NegativeResult(
      identifier: NegativeResultCodes.wrongType,
      message: 'It was about adapting a value to a list of type $T, but it But it is not a valid type for the list (it is ${originalItem.runtimeType})',
    );
  }

  @override
  bool isTypeCompatible(Type type) {
    return type == (List<T>) || type == List || type == (Iterable<T>) || type == Iterable || type == T;
  }

  @override
  serializeToMap(item) {
    if (item! is Iterable) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: 'A list of type $T was expected (The object is ${item.runtimeType})',
      );
    }

    if (item.isEmpty) {
      return [];
    }

    final allTypesAreSame = item.every((x) => x.runtimeType == T);
    if (allTypesAreSame) {
      return _serializeListSameType(item);
    } else {
      return _serializeListDifferentTypes(item);
    }
  }

  List<T> _serializeListSameType(Iterable list) {
    final typeOperator = ReflectionManager.getReflectionType(T, annotations: []);
    int i = 1;

    final newList = <T>[];

    for (final item in list) {
      final newItem = addToErrorDescription(
        additionalDetails: () => 'Item N° $i',
        function: () => typeOperator.serializeToMap(item),
      );
      newList.add(newItem);
      i += 1;
    }

    return newList;
  }

  List<T> _serializeListDifferentTypes(Iterable list) {
    int i = 1;

    IReflectionType? typeOperator;

    final newList = <T>[];

    for (final item in list) {
      if (typeOperator == null || typeOperator.type != item.runtimeType) {
        typeOperator = addToErrorDescription(
          additionalDetails: () => 'Item N° $i',
          function: () => ReflectionManager.getReflectionType(item.runtimeType, annotations: []),
        );
      }

      final newItem = addToErrorDescription(
        additionalDetails: () => 'Item N° $i',
        function: () => typeOperator!.serializeToMap(item),
      );
      newList.add(newItem);
      i += 1;
    }

    return newList;
  }

  @override
  cloneObject(originalItem) {
    if (originalItem! is Iterable) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: 'A list of type $T was expected (The object is ${originalItem.runtimeType})',
      );
    }

    int i = 1;
    IReflectionType? typeOperator;
    final newList = <T>[];

    for (final item in originalItem) {
      if (typeOperator == null || typeOperator.type != item.runtimeType) {
        typeOperator = addToErrorDescription(
          additionalDetails: () => 'Item N° $i',
          function: () => ReflectionManager.getReflectionType(item.runtimeType, annotations: []),
        );
      }

      final newItem = addToErrorDescription(
        additionalDetails: () => 'Item N° $i',
        function: () => typeOperator!.cloneObject(item),
      );
      newList.add(newItem);
      i += 1;
    }

    return newList;
  }
}
