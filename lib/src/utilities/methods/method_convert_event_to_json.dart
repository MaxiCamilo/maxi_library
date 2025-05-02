import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';

class MethodConvertEventToJson with IFunctionality<Map<String, dynamic>> {
  final dynamic result;

  const MethodConvertEventToJson({required this.result});

  String runFunctionalityToText() {
    return json.encode(runFunctionality());
  }

  @override
  Map<String, dynamic> runFunctionality() {
    final map = <String, dynamic>{};

    if (result == null) {
      map['\$type'] = 'null';
      map['content'] = '';
    } else if (result is NegativeResult) {
      final errorMap = result.serialize();
      map['\$type'] = errorMap['\$type'];
      map['content'] = errorMap;
    } else if (ConverterUtilities.isPrimitive(result.runtimeType) != null) {
      map['\$type'] = result.runtimeType.toString().toLowerCase();
      map['content'] = result;
    } else if (result is ICustomSerialization) {
      map['\$type'] = result.runtimeType.toString();
      map['content'] = result.serialize();
    } else if (result is List) {
      map['\$type'] = 'List';
      map['content'] = (result as List).map((e) => MethodConvertEventToJson(result: e).runFunctionality()).toList(growable: false);
    } else {
      map['\$type'] = result.runtimeType.toString();
      map['content'] = ReflectionManager.getReflectionEntity(result.runtimeType).serializeToMap(result);
    }

    return map;
  }
}
