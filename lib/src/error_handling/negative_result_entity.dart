import 'package:maxi_library/maxi_library.dart';

class NegativeResultEntity extends NegativeResultValue {
  final List<NegativeResultValue> invalidProperties;

  NegativeResultEntity({required super.message, required super.name, required this.invalidProperties});

  @override
  Map<String, dynamic> serialize() {
    final map = super.serialize();
    map['invalidProperties'] = Map.fromEntries(invalidProperties.map((x) => MapEntry(x.name, x.serialize())));

    return map;
  }
}
