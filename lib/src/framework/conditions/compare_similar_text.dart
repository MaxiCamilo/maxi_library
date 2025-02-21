import 'package:maxi_library/maxi_library.dart';

@reflect
class CompareSimilarText with IConditionQuery {
  final String fieldName;
  final String similarText;
  final bool shieldValue;
  final String selectedTable;
  final bool differentiateUppercaseLetters;

  const CompareSimilarText({
    required this.fieldName,
    required this.similarText,
    this.shieldValue = true,
    this.selectedTable = '',
    this.differentiateUppercaseLetters = false,
  });
}
