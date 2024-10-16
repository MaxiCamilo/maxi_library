import 'package:maxi_library/maxi_library.dart';

@reflect
class CompareIncludesValues with IConditionQuery {
  final String fieldName;
  final String selectedTable;
  final List options;
  final bool shieldValue;
  final bool isInclusive;

  const CompareIncludesValues({
    required this.fieldName,
    required this.options,
    this.selectedTable = '',
    this.shieldValue = true,
    this.isInclusive = true,
  });
}
