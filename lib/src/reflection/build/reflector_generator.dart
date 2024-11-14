import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:maxi_library/export_reflectors.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:maxi_library/src/reflection/build/detected/class_detected.dart';
import 'package:maxi_library/src/reflection/build/detected/enum_detected.dart';

class ReflectorGenerator {
  final List<String> directories;
  final String albumName;
  final String fileCreationPlace;

  const ReflectorGenerator({
    required this.directories,
    required this.fileCreationPlace,
    required this.albumName,
  });

  Future<void> build() async {
    final imports = <String>{
      'import \'package:maxi_library/export_reflectors.dart\'',
      'import \'package:maxi_library/maxi_library.dart\'',
    };

    await ApplicationManager.changeInstance(
      initialize: true,
      newInstance: DartApplicationManager(defineLanguageOperatorInOtherThread: false, useWorkingPathInDebug: false, useWorkingPath: true, reflectors: []),
    );

    final castDirectories = directories.map((x) => DirectoryUtilities.interpretPrefix(x)).toList();
    final enumNames = <String>[];
    final classNames = <String>[];

    for (final path in castDirectories) {
      if (!Directory(path).existsSync()) {
        throw NegativeResult(identifier: NegativeResultCodes.nonExistent, message: tr('Directory %1 does not exists', [path]));
      }
    }

    final dartFiles = <FileSystemEntity>[];
    for (final dir in castDirectories) {
      dartFiles.addAll(Directory(dir).listSync(recursive: true).where((file) => file.path.endsWith('.dart')));
    }

    final classList = <ClassDetected>[];
    final enumList = <EnumDetected>[];

    for (var file in dartFiles) {
      final content = File(file.path).readAsStringSync();
      final result = parseString(content: content, throwIfDiagnostics: false);
      final unit = result.unit;

      final visitor = _ReflectVisitor();
      unit.visitChildren(visitor);

      classList.addAll(visitor.classList);
      enumList.addAll(visitor.enumList);
      imports.addAll(visitor.imports);
    }

    final file = File('${DirectoryUtilities.interpretPrefix(fileCreationPlace)}/${albumName.toLowerCase()}.dart');

    if (file.existsSync()) {
      file.deleteSync();
    }

    file.writeAsStringSync('// ignore_for_file: unnecessary_const, unnecessary_import, duplicate_import, unused_import\n\n');

    for (final imp in imports) {
      if (imp.last == ';') {
        file.writeAsStringSync('$imp\n', mode: FileMode.append);
      } else {
        file.writeAsStringSync('$imp;\n', mode: FileMode.append);
      }
    }

    file.writeAsStringSync('\n\n\n', mode: FileMode.append);

    for (final enu in enumList) {
      final (name, content) = GeneratedReflectedEnum.makeScript(enumInstance: enu);
      if (enumNames.contains(name)) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidFunctionality,
          message: tr('Two enumerators with the same name were found ("%1")', [name]),
        );
      } else {
        enumNames.add(name);
        file.writeAsStringSync('$content\n', mode: FileMode.append);
      }
    }

    for (final cla in classList) {
      final (name, content) = GeneratedReflectedClass.makeScript(classInstance: cla);
      if (classNames.contains(name)) {
        throw NegativeResult(
          identifier: NegativeResultCodes.invalidFunctionality,
          message: tr('Two class with the same name were found ("%1")', [name]),
        );
      } else {
        classNames.add(name);
        file.writeAsStringSync('$content\n', mode: FileMode.append);
      }
    }

    final className = albumName.toFirstInCapitalLetter();

    final albumContet = '''
class _Album$className extends GeneratedReflectorAlbum {
  const _Album$className();
  @override
  List<GeneratedReflectedClass> get classes => const [${TextUtilities.generateCommand(list: classNames.map((x) => '$x()'))}];

  @override
  List<TypeEnumeratorReflector> get enums => const [${TextUtilities.generateCommand(list: enumNames.map((x) => '$x()'))}];
}\n

const ${albumName.toFirstInLowercase()}Reflectors = _Album$className();
''';
    file.writeAsStringSync(albumContet, mode: FileMode.append);
  }
}

class SuperAlbum extends GeneratedReflectorAlbum {
  const SuperAlbum();
  @override
  List<GeneratedReflectedClass> get classes => throw UnimplementedError();

  @override
  List<GeneratedReflectedEnum> get enums => throw UnimplementedError();
}

class _ReflectVisitor extends GeneralizingAstVisitor<void> {
  final imports = <String>{};
  final classList = <ClassDetected>[];
  final enumList = <EnumDetected>[];

  @override
  void visitImportDirective(ImportDirective node) {
    imports.add(node.toString());

    super.visitImportDirective(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    if (node.metadata.any((annotation) => annotation.name.name == 'reflect')) {
      final clas = ClassDetected.fromMixinAnalizer(declaration: node);
      if (!clas.isPrivate) {
        classList.add(clas);
      }
    }

    super.visitMixinDeclaration(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.metadata.any((annotation) => annotation.name.name == 'reflect')) {
      final clas = ClassDetected.fromClassAnalizer(declaration: node);
      if (!clas.isPrivate) {
        classList.add(clas);
      }
    }

    super.visitClassDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    if (node.metadata.any((annotation) => annotation.name.name == 'reflect')) {
      final enu = EnumDetected.fromenumFactory(declaration: node);
      if (!enu.isPrivate) {
        enumList.add(enu);
      }
    }

    super.visitEnumDeclaration(node);
  }
}
