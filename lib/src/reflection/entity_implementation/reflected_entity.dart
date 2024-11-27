import 'package:maxi_library/export_reflectors.dart';
import 'package:maxi_library/src/reflection/entity_implementation/field_entity.dart';
import 'package:maxi_library/src/reflection/entity_implementation/method_entity.dart';
import 'package:maxi_library/src/reflection/entity_implementation/method_get_entity.dart';
import 'package:maxi_library/src/reflection/entity_implementation/method_set_entity.dart';
import 'package:maxi_library/src/reflection/interfaces/igetter_reflector.dart';
import 'package:maxi_library/src/reflection/interfaces/isetter_reflector.dart';
import 'package:maxi_library/src/reflection/templates/reflected_entity_type_template.dart';

class ReflectedEntity<T> extends ReflectedEntityTypeTemplate {
  final GeneratedReflectedClass<T> reflectedClass;

  ReflectedEntity({required this.reflectedClass})
      : super(
          annotations: reflectedClass.annotations,
          name: reflectedClass.name,
          type: reflectedClass.type,
        );

  late ITypeEntityReflection? _baseClass;
  late IMethodReflection? _defalutContruct;

  final List<ITypeEntityReflection> _inheritance = [];
  final List<IMethodReflection> _constructors = [];
  final List<IFieldReflection> _fields = [];
  final List<IMethodReflection> _methods = [];
  final List<IGetterReflector> _getters = [];
  final List<ISetterReflector> _setters = [];

  @override
  bool get isAbstract => reflectedClass.isAbstract || reflectedClass.isMixin;

  @override
  bool get isStatic => isAbstract; //<---- ¿?

  @override
  ITypeEntityReflection? get baseClass => _executeOnlyIfInitialized(() => _baseClass);

  @override
  List<IMethodReflection> get constructors => _executeOnlyIfInitialized(() => _constructors);

  @override
  List<IFieldReflection> get fields => _executeOnlyIfInitialized(() => _fields);

  @override
  bool get hasDefaultConstructor => _executeOnlyIfInitialized(() => _defalutContruct != null);

  @override
  List<IGetterReflector> get getters => _executeOnlyIfInitialized(() => _getters);

  @override
  List<ITypeEntityReflection> get inheritance => _executeOnlyIfInitialized(() => _inheritance);

  @override
  List<IMethodReflection> get methods => _executeOnlyIfInitialized(() => _methods);

  @override
  List<ISetterReflector> get setters => _executeOnlyIfInitialized(() => _setters);

  R _executeOnlyIfInitialized<R>(R Function() function) {
    initialized();
    return function();
  }

  @override
  buildEntityWithoutParameters() {
    checkProgrammingFailure(thatChecks: tr('Entity %1 has a default construct', [name]), result: () => _defalutContruct != null);
    return _defalutContruct!.callMethod(instance: null, fixedParametersValues: const [], namedParametesValues: const {});
  }

  @override
  void initializeReflector() {
    _establishInheritances();
    _establishMethods();
    _establishExternMethods();
    _establishFieldAndExtern();
  }

  void _establishInheritances() {
    if (reflectedClass.baseClass == null) {
      _baseClass = null;
    } else {
      _baseClass = ReflectionManager.getReflectionEntity(reflectedClass.baseClass!);
      _inheritance.add(_baseClass!);
    }

    for (final type in reflectedClass.classThatImplement) {
      final found = ReflectionManager.tryGetReflectionEntity(type);
      if (found != null) {
        _inheritance.add(found);
      }
    }
  }

  void _establishMethods() {
    for (final method in reflectedClass.methods) {
      final methodIntance = MethodEntity.make(method: method);
      _methods.add(methodIntance);

      if (methodIntance.isConstructor) {
        _constructors.add(methodIntance);
      } else if (methodIntance.isGetter) {
        final methorGetter = MethodGetEntity.make(method: method);
        _getters.add(methorGetter);
      } else if (methodIntance.isSetter) {
        final methorSetter = MethodSetEntity.make(method: method);
        _setters.add(methorSetter);
      }
    }

    _defalutContruct = _methods.selectItem((x) => x.isConstructor && x.fixedParametes.isEmpty && x.namedParametes.isEmpty);
  }

  void _establishExternMethods() {
    final externalMethods = _inheritance.expand((x) => x.methods).where((x) => !x.isConstructor);
    for (final extern in externalMethods) {
      if (!_methods.any((x) => x.name == extern.name)) {
        _methods.add(extern);
      }
    }

    for (final externGetter in _inheritance.expand((x) => x.getters)) {
      if (!_getters.any((x) => x.name == externGetter.name)) {
        _getters.add(externGetter);
      }
    }

    for (final externSetter in _inheritance.expand((x) => x.setters)) {
      if (!_setters.any((x) => x.name == externSetter.name)) {
        _setters.add(externSetter);
      }
    }
  }

  void _establishFieldAndExtern() {
    for (final field in reflectedClass.fields) {
      final fieldInstance = FieldEntity.make(field: field);
      _fields.add(fieldInstance);
    }

    for (final extern in _inheritance.expand((x) => x.fields)) {
      if (!_fields.any((x) => x.name == extern.name)) {
        _fields.add(extern);
      }
    }
  }

  @override
  List createList([Iterable? content]) {
    final newList = reflectedClass.createListGenerator().generateEmptryObject() as List;

    if (content != null) {
      newList.addAll(content);
    }

    return newList;
  }
}
