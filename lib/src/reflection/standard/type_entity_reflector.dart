import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/interfaces/ifield_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/imethod_reflection.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';
import 'package:maxi_library/src/reflection/standard/field_reflector_standard.dart';
import 'package:maxi_library/src/reflection/standard/getter_reflector_standard.dart';
import 'package:maxi_library/src/reflection/standard/method_reflector_standard.dart';
import 'package:maxi_library/src/reflection/standard/setter_reflector_standard.dart';
import 'package:maxi_library/src/reflection/templates/template_type_entity_reflector.dart';

class TypeEntityReflector extends TemplateTypeEntityReflector {
  final Reflectable reflectable;
  final ClassMirror classMirror;

  @override
  bool get isStatic => classMirror.isAbstract;

  TypeEntityReflector({
    required this.reflectable,
    required this.classMirror,
  }) : super(
          annotations: classMirror.metadata,
          name: classMirror.simpleName,
          type: classMirror.dynamicReflectedType,
        );

  late final bool _hasDefaultConstructor;
  late final ITypeEntityReflection? _baseClass;

  final List<ITypeEntityReflection> _inheritance = [];
  final List<IMethodReflection> _constructors = [];
  final List<IFieldReflection> _fields = [];
  final List<IMethodReflection> _methods = [];
  final List<IGetterReflector> _getters = [];
  final List<ISetterReflector> _setters = [];

  T _executeOnlyIfInitialized<T>(T Function() function) {
    initialized();
    return function();
  }

  @override
  ITypeEntityReflection? get baseClass => _executeOnlyIfInitialized(() => _baseClass);

  @override
  List<IMethodReflection> get constructors => _executeOnlyIfInitialized(() => _constructors);

  @override
  List<IFieldReflection> get fields => _executeOnlyIfInitialized(() => _fields);

  @override
  bool get hasDefaultConstructor => _executeOnlyIfInitialized(() => _hasDefaultConstructor);

  @override
  List<IGetterReflector> get getters => _executeOnlyIfInitialized(() => _getters);

  @override
  bool get isAbstract => classMirror.isAbstract;

  @override
  List<ITypeEntityReflection> get inheritance => _executeOnlyIfInitialized(() => _inheritance);

  @override
  List<IMethodReflection> get methods => _executeOnlyIfInitialized(() => _methods);

  @override
  List<ISetterReflector> get setters => _executeOnlyIfInitialized(() => _setters);

  @override
  buildEntityWithoutParameters() {
    return classMirror.newInstance('', []);
  }

  @override
  void initializeReflector() {
    _establishInheritances();
    _establishDeclarations();
  }

  void _establishInheritances() {
    try {
      if (classMirror.superclass != null) {
        _baseClass = ReflectionManager.getReflectionEntity(classMirror.superclass!.dynamicReflectedType);
        if (_baseClass == null) {
          throw NegativeResult(identifier: NegativeResultCodes.implementationFailure, message: trc('Class %1 has base class %2, but it is not reflected', [name, classMirror.superclass!.simpleName]));
        } else {
          _inheritance.add(_baseClass);
        }
      } else {
        _baseClass = null;
      }
    } on NegativeResult catch (_) {
      rethrow;
    } catch (ex) {
      _baseClass = null;
    }

    for (final item in classMirror.superinterfaces) {
      final found = ReflectionManager.tryGetReflectionEntity(item.dynamicReflectedType);
      if (found == null) {
        throw NegativeResult(identifier: NegativeResultCodes.nonExistent, message: trc('The class %1 inherits from class %2, but that class was not reflected', [name, item.simpleName]));
      } else {
        _inheritance.add(found);
      }
    }
  }

  void _establishDeclarations() {
    for (final item in classMirror.declarations.entries) {
      if (item.value is VariableMirror) {
        final variable = item.value as VariableMirror;
        final field = FieldReflectorStandard(reflectable: reflectable, classMirror: classMirror, variableMirror: variable);
        _fields.add(field);
      } else if (item.value is MethodMirror) {
        final methodMirror = item.value as MethodMirror;
        final method = MethodReflectorStandard.make(reflectable: reflectable, classMirror: classMirror, methodMirror: methodMirror);
        _methods.add(method);

        if (method.isGetter) {
          final getter = GetterReflectorStandard(reflectable: reflectable, classMirror: classMirror, methodMirror: methodMirror);
          _getters.add(getter);
        } else if (method.isSetter) {
          final setter = SetterReflectorStandard(reflectable: reflectable, classMirror: classMirror, methodMirror: methodMirror);
          _setters.add(setter);
        }
      }
    }

    _includeExternMembers(classMirror.staticMembers.values);
    _includeExternMembers(classMirror.instanceMembers.values);

    _constructors.addAll(_methods.where((x) => x.isConstructor));
    _hasDefaultConstructor = _constructors.any((x) => x.name == '');

    _combineDeclarationsOfInheritance();
  }

  void _includeExternMembers(Iterable<MethodMirror> externsMethods) {
    final list = externsMethods.toList();
    list.sort((a, b) => a.simpleName.compareTo(b.simpleName));

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (_methods.any((x) => x.name == item.simpleName)) {
        continue;
      }
      final newMethod = MethodReflectorStandard.make(reflectable: reflectable, classMirror: classMirror, methodMirror: item);
      _methods.add(newMethod);
    }
  }

  void _combineDeclarationsOfInheritance() {
    for (final classInherited in _inheritance) {
      for (final method in classInherited.methods) {
        if (!_methods.any((x) => x.name == method.name)) {
          _methods.add(method);
        }
      }

      for (final field in classInherited.fields) {
        if (!_fields.any((x) => x.name == field.name)) {
          _fields.add(field);
        }
      }
    }
  }

 
}
