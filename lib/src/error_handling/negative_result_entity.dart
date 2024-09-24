import 'package:maxi_library/maxi_library.dart';

class NegativeResultEntity extends NegativeResultValue {
  final List<NegativeResultValue> invalidProperties;

  NegativeResultEntity({required super.message, required super.name, required this.invalidProperties});

  @override
  Map<String, dynamic> serialize() {
    final map = super.serialize();

    map['\$type'] = 'error.entity';
    map['invalidProperties'] = Map.fromEntries(invalidProperties.map((x) => MapEntry(x.name, x.serialize())));

    return map;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(message);
    for (final error in invalidProperties) {
      buffer.writeln('-> ${error.name} : ${error.message} [Value: ${error.value}]');
    }

    return buffer.toString();
  }
}
