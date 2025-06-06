import 'package:maxi_library/maxi_library.dart';

class GeneralConverter {
  final dynamic item;
  const GeneralConverter(this.item);

  int toInt({required Oration propertyName, bool ifEmptyIsZero = false}) => ConverterUtilities.toInt(
        value: item,
        propertyName: propertyName,
        ifEmptyIsZero: ifEmptyIsZero,
      );

  double toDouble({required Oration propertyName, bool ifEmptyIsZero = false}) => ConverterUtilities.toDouble(
        value: item,
        propertyName: propertyName,
        ifEmptyIsZero: ifEmptyIsZero,
      );

  DateTime toDateTime({required Oration propertyName, bool isLocal = true}) => ConverterUtilities.toDateTime(
        value: item,
        propertyName: propertyName,
        isLocal: isLocal,
      );

  Map<String, dynamic> toMapObjeto({required Oration propertyName, bool isLocal = true}) => ConverterUtilities.interpretToObjectJson(
      text: item,
      extra: Oration(
        message: '"%1" parameter',
        textParts: [propertyName],
      ));

  bool toBoolean({required Oration propertyName}) => ConverterUtilities.toBoolean(value: item);

  T toEnum<T>({required List<Enum> optionsList, Oration propertyName = Oration.empty}) => volatile(
        detail: Oration(message: 'In the list of options not all are $T'),
        //codeReasonFailure: NegativeResultCodes.implementationFailure,
        function: () => ConverterUtilities.toEnum(optionsList: optionsList, value: item) as T,
      );
}
/*
extension ExtensionConverters on Object {
  GeneralConverter get convertQuickly => GeneralConverter(this);
}
*/
