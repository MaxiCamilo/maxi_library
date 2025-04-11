import 'package:maxi_library/src/error_handling.dart';
import 'package:maxi_library/src/language/oration.dart';

extension ExtensionsMap<K, V> on Map<K, V> {
  V getRequiredValue(K key, [V? defaultValue]) {
    final item = this[key];
    if (item == null) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(
          message: 'The map does not contain item %1',
          textParts: [key],
        ),
      );
    }

    return item;
  }

  T getRequiredValueWithSpecificType<T>(K key, [T? defaultValue]) {
    final item = this[key];
    if (item == null) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw NegativeResult(
        identifier: NegativeResultCodes.nonExistent,
        message: Oration(
          message: 'The map does not contain item %1',
          textParts: [key],
        ),
      );
    }

    if (item is T) {
      return item as T;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(
          message: 'The map has the item, but of type %1 (it was expected to be %2)',
          textParts: [T, item.runtimeType],
        ),
      );
    }
  }
}
