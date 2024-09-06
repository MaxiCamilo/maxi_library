
import 'package:analyzer/dart/ast/ast.dart';
import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/annotation_detected.dart';
import 'package:maxi_library/src/reflection/build/detected/field_detected.dart';
import 'package:maxi_library/src/reflection/build/detected/method_detected.dart';

class ClassDetected {
  final List<AnnotationDetected> annotations;
  final String name;
  final String baseClass;
  final List<String> classThatImplement;
  final List<MethodDetected> methods;
  final List<FieldDetected> fields;
  final bool isAbstract;
  final bool isMixin;

  bool get isPrivate => name.first == '_';

  static bool isReflectedClass({required ClassDeclaration declaration}) => declaration.metadata.any((annotation) => annotation.name.name == 'reflect');
  static bool isReflectedMixed({required ClassDeclaration declaration}) => declaration.metadata.any((annotation) => annotation.name.name == 'reflect');

  const ClassDetected({
    required this.annotations,
    required this.name,
    required this.baseClass,
    required this.classThatImplement,
    required this.methods,
    required this.fields,
    required this.isAbstract,
    required this.isMixin,
  });

  factory ClassDetected.fromClassAnalizer({required ClassDeclaration declaration}) {

    return ClassDetected(
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      name: declaration.name.toString(),
      fields: declaration.members.whereType<FieldDeclaration>().expand((field) => field.fields.variables).map((x) => FieldDetected.fromFieldAnalizer(declaration: x)).toList(),
      methods: [
        ...declaration.members.whereType<MethodDeclaration>().map((x) => MethodDetected.fromMethodAnalizer(declaration: x)),
        ...declaration.members.whereType<ConstructorDeclaration>().map((x) => MethodDetected.fromConstructAnalizer(declaration: x)),
      ],
      baseClass: _extractBaseClass(declaration),
      classThatImplement: _getInheritance(declaration.extendsClause, declaration.implementsClause, declaration.withClause, null),
      isAbstract: declaration.abstractKeyword != null,
      isMixin: false,
    );
  }

  factory ClassDetected.fromMixinAnalizer({required MixinDeclaration declaration}) {
    return ClassDetected(
      annotations: declaration.metadata.map((x) => AnnotationDetected.fromAnalizer(anotation: x)).toList(),
      name: declaration.name.toString(),
      fields: declaration.members.whereType<FieldDeclaration>().expand((field) => field.fields.variables).map((x) => FieldDetected.fromFieldAnalizer(declaration: x)).toList(),
      methods: [
        ...declaration.members.whereType<MethodDeclaration>().map((x) => MethodDetected.fromMethodAnalizer(declaration: x)),
        ...declaration.members.whereType<ConstructorDeclaration>().map((x) => MethodDetected.fromConstructAnalizer(declaration: x)),
      ],
      baseClass: '',
      classThatImplement: _getInheritance(null, declaration.implementsClause, null, declaration.onClause),
      isAbstract: true,
      isMixin: true,
    );
  }

  static List<String> _getInheritance(ExtendsClause? extendsClause, ImplementsClause? implementsClause, WithClause? withClause, MixinOnClause? onClause) {
    final list = <String>[];
    /*
    if (extendsClause != null) {
      list.add(extendsClause.superclass.name2.toString());
    }
    */

    if (implementsClause != null) {
      for (final item in implementsClause.interfaces) {
        list.add(item.name2.toString());
      }
    }

    if (withClause != null) {
      for (final item in withClause.mixinTypes) {
        list.add(item.name2.toString());
      }
    }

    if (onClause != null) {
      for (final item in onClause.superclassConstraints) {
        list.add(item.name2.toString());
      }
    }

    return list;
  }

  static String _extractBaseClass(ClassDeclaration declaration) {
    if (declaration.extendsClause != null) {
      return declaration.extendsClause!.superclass.name2.toString();
    } else {
      return '';
    }
  }
}
