import 'package:maxi_library/export_reflectors.dart';

class CompareSimilarNumber with IConditionQuery {
  final String fieldName;
  final num similarNumber;
  final bool shieldValue;
  final String selectedTable;

  const CompareSimilarNumber({
    required this.fieldName,
    required this.similarNumber,
    this.shieldValue = true,
    this.selectedTable = '',
  });
}
