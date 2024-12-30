import 'package:maxi_library/maxi_library.dart';

class NegativeResultEntity extends NegativeResultValue {
  final List<NegativeResultValue> invalidProperties;

  NegativeResultEntity({required super.message, required super.formalName, required super.name, required this.invalidProperties});

  @override
  Map<String, dynamic> serialize() {
    final map = super.serialize();

    map['\$type'] = 'error.entity';
    map['invalidProperties'] = invalidProperties.map<Map<String, dynamic>>((x) => x.serialize()).toList();

    return map;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(message);
    for (final error in invalidProperties) {
      buffer.writeln('-> ${error.formalName.toString()} : ${error.message} [Value: ${error.value}]');
    }

    return buffer.toString();
  }
}
