import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:maxi_library/maxi_library.dart';

mixin HexadecimalUtilities {
  static const int uint32MaxValue = 4294967295;
  static const int uint16MaxValue = 32767;
  static const int uint8MaxValue = 255;

  static const _referencesTable = <int, String>{
    0: "0",
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "6",
    7: "7",
    8: "8",
    9: "9",
    10: "A",
    11: "B",
    12: "C",
    13: "D",
    14: "E",
    15: "F",
  };

  static List<int> serialize32Bits(int numero) {
    if (numero > uint32MaxValue) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'It is not possible to convert the number value to a 32-bit binary, because it exceeds its maximum (%1)', textParts: [numero]),
      );
    }

    if (numero < 0) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: const Oration(message: 'It is not possible to convert the number value to a 32-bit binary, because it is negative'),
      );
    }

    List<int> lista = [];

    lista.add((numero >> 24) & 0xFF);
    lista.add((numero >> 16) & 0xFF);
    lista.add((numero >> 8) & 0xFF);
    lista.add((numero >> 0) & 0xFF);

    return lista;
  }

  static List<int> serialize8Bits(int numero) {
    if (numero > uint8MaxValue) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'It is not possible to convert the number value to a 8-bit binary, because it exceeds its maximum (%1)', textParts: [numero]),
      );
    }

    if (numero < 0) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'It is not possible to convert the number value to a 8-bit binary, because it is negative'),
      );
    }

    return [(numero >> 0) & 0xFF];
  }

  static List<int> serialize16Bits(int numero) {
    if (numero > uint16MaxValue) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'It is not possible to convert the number value to a 16-bit binary, because it exceeds its maximum (%1)', textParts: [numero]),
      );
    }

    if (numero < 0) {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(message: 'It is not possible to convert the number value to a 16-bit binary, because it is negative'),
      );
    }

    List<int> lista = [];

    lista.add((numero >> 8) & 0xFF);
    lista.add((numero >> 0) & 0xFF);

    return lista;
  }

  static int interpretNumber(List<int> bytes, {bool fromLowestToHighest = true}) {
    if (!fromLowestToHighest) {
      bytes = bytes.reversed.toList();
    }

    int numero = 0;
    int va = 0;
    for (int i = bytes.length - 1; i >= 0; i--) {
      final item = bytes[i];
      numero += item * pow(16, va).toInt();

      va += 2;
    }

    return numero;
  }

  static String passListNumbersToHex(List<int> numbers, [String separator = '']) => numbers.map((e) => e.toRadixString(16)).join(separator);

  static String generateDebugging(List<int> numbers) {
    final buffer = StringBuffer();
    buffer.write('-> Was: ${DateTime.now().toString()}\n');
    buffer.write('-> Size: ${numbers.length} bytes\n');
    buffer.write('       |  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16    123456789123456\n');
    buffer.write('       | ----------------------------------------------------------------------------------\n');
    int va = 0;

    for (final parte in numbers.splitIntoParts(16)) {
      buffer.write('${TextUtilities.zeroFill(value: va, quantityZeros: 6, cutIfExceeds: false, cutFromTheEnd: true)} | ');

      for (final item in parte) {
        buffer.write('${TextUtilities.zeroFill(value: item.toRadixString(16), quantityZeros: 2, cutIfExceeds: false, cutFromTheEnd: true)}  ');
      }

      for (int i = 16 - parte.length; i > 0; i--) {
        buffer.write('    ');
      }

      buffer.write('  ');

      for (final item in parte) {
        if (item < 32) {
          buffer.write('◌');
        } else {
          buffer.write(latin1.decode([item]));
        }
      }

      buffer.write('\n');
      va = va + 16;
    }

    buffer.write('--------------------------------------------------------------------------------------------\n\n');

    return buffer.toString();
  }

  static void addDebugging(String direccion, List<int> datos, [String? titulo]) {
    titulo ??= '';
    final archvio = File(direccion);

    if (titulo.isNotEmpty) {
      archvio.writeAsStringSync('$titulo\n', mode: FileMode.append);
    }

    archvio.writeAsStringSync(generateDebugging(datos), flush: true, mode: FileMode.append);
  }

  static bool getBit({required int number, required int position}) {
    if (position > 7) {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'A 1-byte number must be between 0 and 7.'));
    }

    //Si es 7, con saber si es impar ya da el resultado
    if (position == 7) {
      return number % 2 == 1;
    }

    final lista = <int>[];
    for (int i = 0; i <= position; i++) {
      final potencia = pow(2, 7 - i);
      final dio = lista.sum + potencia <= number;

      if (i == position) {
        return dio;
      } else if (dio) {
        lista.add(potencia.toInt());
      }
    }

    throw NegativeResult(identifier: NegativeResultCodes.abnormalOperation, message: Oration(message: 'This functionality should not be here'));
  }

  static List<bool> convertByteToBinary(int numero) {
    final retorno = <bool>[];
    final lista = <int>[];

    for (int i = 0; i < 8; i++) {
      final potencia = pow(2, 7 - i);
      bool dio = lista.sum + potencia <= numero;

      retorno[i] = dio;
      if (dio) {
        lista.add(potencia.toInt());
      }
    }

    return retorno;
  }

  static int generateByteFromBinary(List<bool> dato) {
    if (dato.length != 8) {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'A 1-byte number must be 8 bites.'));
    }

    int dio = 0;

    for (int i = 0; i < 8; i++) {
      if (dato[i]) {
        dio += pow(2, 7 - i).toInt();
      }
    }

    return dio;
  }

  static int changeBitFromByte({required int number, required int position, required bool value}) {
    if (position > 7) {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: Oration(message: 'A 1-byte number must be between 0 and 7'));
    }

    var serializado = convertByteToBinary(number);

    if (serializado[position] == value) {
      return number;
    }

    serializado[position] = value;

    return generateByteFromBinary(serializado);
  }

  static int passBinaryLiteralToNumber(Iterable<int> datos) {
    return GeneralConverter(datos.map((x) => TextUtilities.zeroFill(value: x.toRadixString(16), quantityZeros: 2)).join()).toInt(propertyName: Oration(message: 'Convert Hexadecimal to literal decimal (integer)'));
  }

  static int passLiteralHexEquivalentNumeric(String numero) {
    if (numero.length > 2) {
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: const Oration(message: 'The number %1 has 2 digits'));
    } else if (numero.length == 2) {
      for (final item in _referencesTable.entries) {
        int maximo = 0;
        if (item.value[0] == numero[0]) {
          maximo = item.key * 16;
          for (final otroItem in _referencesTable.entries) {
            if (otroItem.value[0] == numero[1]) {
              return maximo + otroItem.key;
            }
          }
          throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: const Oration(message: 'The number %1 is not hexadecimal valid number'));
        }
      }
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: const Oration(message: 'The number %1 is not hexadecimal valid number'));
    } else if (numero.length == 1) {
      for (final item in _referencesTable.entries) {
        if (item.value == numero) {
          return item.key;
        }
      }
      throw NegativeResult(identifier: NegativeResultCodes.wrongType, message: const Oration(message: 'The number %1 is not hexadecimal valid number'));
    } else {
      return 0;
    }
  }
}
