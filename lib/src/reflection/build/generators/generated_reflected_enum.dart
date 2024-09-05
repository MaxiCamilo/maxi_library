import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/reflection/build/detected/enum_detected.dart';
import 'package:maxi_library/src/reflection/build/utils/build_reflector_utilities.dart';

abstract class GeneratedReflectedEnum extends TypeEnumeratorReflector {
  const GeneratedReflectedEnum({required super.optionsList, required super.annotations, required super.type, required super.name});

  //const GeneratedReflectedEnum() : super(optionsList: _optionsList, annotations: _anotations, name: 'jeje', type: String);

  static (String, String) makeScript({required EnumDetected enumInstance}) {
    final className = '_${enumInstance.name}Enum';

    final buffer = StringBuffer('class $className extends TypeEnumeratorReflector {');

    buffer.write('\tconst $className(): super(');

    buffer.write('\t\ttype: ${enumInstance.name},\n');
    buffer.write('\t\tname: \'${enumInstance.name}\',\n');

    buffer.write('\t\tannotations: ${BuildReflectorUtilities.makeAnnotationsScript(anotations: enumInstance.annotations)},\n');

    buffer.write('\t\toptionsList: const [\n');
    for (final item in enumInstance.options) {
      buffer.write('\t\t\tEnumOption(annotations: ${BuildReflectorUtilities.makeAnnotationsScript(anotations: item.annotations)}, value: ${enumInstance.name}.${item.value}),\n');
    }

    buffer.write('\t\t],\t\n);\n}\n');

    return (className, buffer.toString());
  }
}
