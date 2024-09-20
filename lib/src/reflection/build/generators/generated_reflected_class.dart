import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/class_detected.dart';
import 'package:maxi_library/src/reflection/build/detected/method_detected.dart';
import 'package:maxi_library/src/reflection/build/generators/generated_reflected_field.dart';
import 'package:maxi_library/src/reflection/build/generators/generated_reflected_method.dart';
import 'package:maxi_library/src/reflection/build/utils/build_reflector_utilities.dart';

abstract class GeneratedReflectedClass<T> {
  List get annotations;
  String get name;
  Type? get baseClass;
  List<Type> get classThatImplement;
  List<GeneratedReflectedMethod> get methods;
  List<GeneratedReflectedField> get fields;
  bool get isAbstract;
  bool get isMixin;

  Type get type => T;

  GeneratorList<T> createListGenerator() => GeneratorList<T>(annotations: annotations);

  const GeneratedReflectedClass();

  static (String, String) makeScript({required ClassDetected classInstance}) {
    final className = '_${classInstance.name}';
    final buffer = StringBuffer('/*----------------------------------   Class ${classInstance.name}   ----------------------------------*/\n\n\n');

    final fieldsNameList = <String>[];
    final methodNameList = <String>[];

    buffer.writeln('/*${classInstance.name.toUpperCase()} FIELDS*/\n');

    for (final field in classInstance.fields.where((x) => !x.isPrivate)) {
      final (name, content) = GeneratedReflectedField.makeScript(entityName: classInstance.name, field: field);
      fieldsNameList.add(name);
      buffer.writeln(content);
      buffer.writeln();
    }

    buffer.writeln('/*${classInstance.name.toUpperCase()} METHODS*/\n');

    for (final method in classInstance.methods.where((x) => !x.isPrivate)) {
      if (classInstance.isAbstract && (method.type == MethodDetectedType.buildMethod || method.type == MethodDetectedType.factoryMethod)) {
        continue;
      }

      final (name, content) = GeneratedReflectedMethod.makeScript(entityName: classInstance.name, method: method);
      methodNameList.add(name);
      buffer.writeln(content);
      buffer.writeln();
    }

    //Generate emptry constructor (if it is not abstract or mixin)
    if (!classInstance.isAbstract && !classInstance.isMixin && !classInstance.methods.any((x) => x.type == MethodDetectedType.buildMethod || x.type == MethodDetectedType.factoryMethod)) {
      final newMethod = MethodDetected(
        annotations: [],
        name: '',
        typeReturn: classInstance.name,
        type: MethodDetectedType.buildMethod,
        isStatic: true,
        parameters: [],
      );
      final (name, content) = GeneratedReflectedMethod.makeScript(entityName: classInstance.name, method: newMethod);
      methodNameList.add(name);
      buffer.writeln(content);
      buffer.writeln();
    }

    buffer.writeln('/*${classInstance.name.toUpperCase()} INSTANCE*/\n');

    buffer.writeln('class $className extends GeneratedReflectedClass<${classInstance.name}> {\nconst $className();');

    //Anotations
    buffer.write('''
@override
List get annotations => ${BuildReflectorUtilities.makeAnnotationsScript(anotations: classInstance.annotations)};\n
''');

    if (classInstance.baseClass.isNotEmpty) {
      buffer.writeln('''
@override
Type? get baseClass => ${classInstance.baseClass};
''');
    } else {
      buffer.writeln('''
@override
Type? get baseClass => null;
''');
    }

    buffer.writeln('''
@override
List<Type> get classThatImplement => const [${TextUtilities.generateCommand(list: classInstance.classThatImplement)}];
''');

    buffer.writeln('''
@override
bool get isAbstract => ${classInstance.isAbstract ? 'true' : 'false'};

@override
bool get isMixin => ${classInstance.isMixin ? 'true' : 'false'};

@override
String get name => '${classInstance.name}';

@override
List<GeneratedReflectedMethod> get methods => const [${TextUtilities.generateCommand(list: methodNameList.map((x) => '$x()'))}];

@override
List<GeneratedReflectedField> get fields => const [${TextUtilities.generateCommand(list: fieldsNameList.map((x) => '$x()'))}];

''');

    buffer.writeln('}');
    buffer.writeln('/*----------------------------------   x   ----------------------------------*/\n\n');

    return (className, buffer.toString());
  }
}
