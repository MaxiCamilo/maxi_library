import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/field_detected.dart';
import 'package:maxi_library/src/reflection/build/utils/build_reflector_utilities.dart';
import 'package:meta/meta.dart';

mixin GeneratedReflectedModifiableField<T, R> {
  bool get isStatic;
  String get name;
  bool get acceptNull;

  @protected
  void setReservedValue({required T? entity, required R newValue});

  void setValue({required dynamic entity, required dynamic newValue}) {
    if (!isStatic && entity == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: trc('The field %1 of the entity %2 is not static, instance is required', [name, T]),
      );
    }

    if (!isStatic && entity is! T) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: trc('The %1 field of the %2 object requires a %2 instance or a compatible one', [name, T]),
      );
    }

    if (newValue == null) {
      if (!acceptNull) {
        throw NegativeResult(
          identifier: NegativeResultCodes.nullValue,
          message: trc('The %1 field of the %2 object does not accept null values', [name, T]),
        );
      }
    } else if (newValue is! R) {
      throw NegativeResult(
        identifier: NegativeResultCodes.nullValue,
        message: trc('The %1 field of the %2 object does not accept %4 values, it only accept %3 values or their equivalents', [name, T, R, newValue.runtimeType]),
      );
    }

    setReservedValue(entity: entity, newValue: newValue);
  }
}

abstract class GeneratedReflectedField<T, R> {
  List get annotations;
  String get name;
  bool get isStatic;
  bool get isConst;
  bool get isLate;
  bool get isFinal;
  bool get hasDefaultValue;
  R? get defaulValue;
  bool get acceptNull;

  Type get typeReturn => R;

  const GeneratedReflectedField();

  @protected
  R getReservedValue({required T? entity});

  R getValue({required dynamic entity}) {
    if (!isStatic && entity == null) {
      throw NegativeResult(
        identifier: NegativeResultCodes.invalidValue,
        message: trc('The field %1 of the entity %2 is not static, instance is required', [name, T]),
      );
    }

    if (!isStatic && entity is! T) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: trc('The %1 field of the %2 object requires a %2 instance or a compatible one', [name, T]),
      );
    }

    return getReservedValue(entity: entity);
  }

  static (String, String) makeScript({required String entityName, required FieldDetected field}) {
    final genericsTypes = '<$entityName,${field.typeValue}>';
    final className = '_$entityName${field.name}';
    final isEditable = (!field.isFinal || field.isLate) && !field.isConst;

    //Write if it is modificable
    final buffer = StringBuffer('class $className extends GeneratedReflectedField$genericsTypes');
    if (isEditable) {
      buffer.write(' with GeneratedReflectedModifiableField$genericsTypes {');
    } else {
      buffer.write('{');
    }

    buffer.write('\nconst $className();\n');

    //Anotations
    buffer.write('''
@override
List get annotations => ${BuildReflectorUtilities.makeAnnotationsScript(anotations: field.annotations)};\n
''');

//Name and if it's static
    buffer.write('''
@override
String get name => '${field.name}';

@override
bool get isStatic => ${field.isStatic ? 'true' : 'false'};

@override
bool get isConst => ${field.isConst ? 'true' : 'false'};

@override
bool get isLate => ${field.isLate ? 'true' : 'false'};

@override
bool get isFinal => ${field.isFinal ? 'true' : 'false'};

@override
bool get acceptNull => ${field.acceptNull ? 'true' : 'false'};\n
''');

//Default value

    if (field.hasDefaultValue) {
      buffer.write('''
@override
bool get hasDefaultValue => true;
@override
${field.acceptNull ? field.typeValue : '${field.typeValue}?'} get defaulValue => ${field.defaulValue};\n
''');
    } else {
      buffer.write('''
@override
bool get hasDefaultValue => false;
@override
${field.acceptNull ? field.typeValue : '${field.typeValue}?'} get defaulValue => null;\n
''');
    }

    //Method return value
    buffer.write('''
@override
${field.typeValue} getReservedValue({required $entityName? entity}) =>
''');

    if (field.isConst || field.isStatic) {
      buffer.write('$entityName.${field.name};\n');
    } else {
      buffer.write('entity!.${field.name};\n');
    }

    if (isEditable) {
      buffer.write('''
@override
void setReservedValue({required $entityName? entity, required ${field.typeValue} newValue}) =>
''');

      if (field.isConst || field.isStatic) {
        buffer.write('\t$entityName.${field.name} = newValue;\n');
      } else {
        buffer.write('\tentity!.${field.name} = newValue;\n');
      }
    }

    buffer.write('}');

    return (className, buffer.toString());
  }
}
