import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/maxi_library.dart';

class AnnotationDetected {
  final String rawText;

  const AnnotationDetected({required this.rawText});

  factory AnnotationDetected.fromAnalizer({required Annotation anotation}) {
    return AnnotationDetected(rawText: anotation.toString().extractFrom(since: 1));
  }
}
