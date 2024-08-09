// This file has been generated by the reflectable package.
// https://github.com/dart-lang/reflectable.
import 'dart:core';
import 'package:maxi_library/src/reflection/decorators/base_decorator_reflector.dart'
    as prefix4;
import 'package:maxi_library/src/reflection/decorators/essential_key.dart'
    as prefix7;
import 'package:maxi_library/src/reflection/decorators/primary_key.dart'
    as prefix5;
import 'package:maxi_library/src/reflection/validators/numbers/check_number_range.dart'
    as prefix6;
import 'package:maxi_library/src/reflection/validators/texts/check_text_length.dart'
    as prefix8;
import 'reflectors_generated.dart' as prefix0;
import 'second_test_class.dart' as prefix2;
import 'test_class.dart' as prefix1;
import 'third_test_class.dart' as prefix3;

// ignore_for_file: camel_case_types
// ignore_for_file: implementation_imports
// ignore_for_file: prefer_adjacent_string_concatenation
// ignore_for_file: prefer_collection_literals
// ignore_for_file: unnecessary_const
// ignore_for_file: unused_import

import 'package:reflectable/mirrors.dart' as m;
import 'package:reflectable/src/reflectable_builder_based.dart' as r;
import 'package:reflectable/reflectable.dart' as r show Reflectable;

final _data = <r.Reflectable, r.ReflectorData>{
  const prefix0.ReflectorTest(): r.ReflectorData(
      <m.TypeMirror>[
        r.NonGenericClassMirrorImpl(
            r'TestClass',
            r'.TestClass',
            134217735,
            0,
            const prefix0.ReflectorTest(),
            const <int>[0, 1, 13, 14, 15, 20, 21, 22, 23, 24, 25],
            const <int>[26, 15, 27, 28, 29, 13, 16, 17, 18, 19, 20, 21, 22, 23],
            const <int>[14],
            -1,
            {r'getterStatic': () => prefix1.TestClass.getterStatic},
            {},
            {
              r'': (bool b) => () => b ? prefix1.TestClass() : null,
              r'superHuman': (bool b) => ({name, date}) => b
                  ? prefix1.TestClass.superHuman(date: date, name: name)
                  : null
            },
            0,
            0,
            const <int>[],
            const <Object>[prefix0.reflector],
            null),
        r.NonGenericClassMirrorImpl(
            r'TestClassType',
            r'.TestClassType',
            138412039,
            1,
            const prefix0.ReflectorTest(),
            const <int>[2, 3, 4, 34],
            const <int>[26, 35, 27, 28, 29, 36],
            const <int>[30, 31, 32, 33],
            -1,
            {
              r'stupid': () => prefix1.TestClassType.stupid,
              r'idiot': () => prefix1.TestClassType.idiot,
              r'motherFucker': () => prefix1.TestClassType.motherFucker,
              r'values': () => prefix1.TestClassType.values
            },
            {},
            {},
            0,
            1,
            const <int>[],
            const <Object>[prefix0.reflector],
            null),
        r.NonGenericClassMirrorImpl(
            r'TestClassMakeIntList',
            r'.TestClassMakeIntList',
            134217735,
            2,
            const prefix0.ReflectorTest(),
            const <int>[37],
            const <int>[26, 35, 27, 28, 29, 38, 39, 40, 41, 42, 43, 44, 45, 46],
            const <int>[],
            -1,
            {},
            {},
            {r'': (bool b) => () => b ? prefix2.TestClassMakeIntList() : null},
            1,
            2,
            const <int>[],
            const <Object>[prefix0.reflector],
            null),
        r.NonGenericClassMirrorImpl(
            r'TestClassMakeRandomText',
            r'.TestClassMakeRandomText',
            134217735,
            3,
            const prefix0.ReflectorTest(),
            const <int>[47, 48, 49, 50, 51, 52],
            const <int>[26, 35, 27, 28, 29, 47, 48, 49, 50, 51],
            const <int>[],
            7,
            {},
            {},
            {
              r'': (bool b) =>
                  () => b ? prefix2.TestClassMakeRandomText() : null
            },
            1,
            3,
            const <int>[],
            const <Object>[prefix0.reflector],
            null),
        r.NonGenericClassMirrorImpl(
            r'SecondTestClassGenerator',
            r'.SecondTestClassGenerator',
            134217735,
            4,
            const prefix0.ReflectorTest(),
            const <int>[53, 54, 55],
            const <int>[26, 35, 27, 28, 29, 53, 54],
            const <int>[],
            -1,
            {},
            {},
            {
              r'': (bool b) =>
                  () => b ? prefix2.SecondTestClassGenerator() : null
            },
            1,
            4,
            const <int>[],
            const <Object>[prefix0.reflector],
            null),
        r.NonGenericClassMirrorImpl(
            r'SecondTestClass',
            r'.SecondTestClass',
            134217735,
            5,
            const prefix0.ReflectorTest(),
            const <int>[7, 8, 56, 61],
            const <int>[26, 35, 27, 28, 29, 56, 57, 58, 59, 60],
            const <int>[],
            -1,
            {},
            {},
            {r'': (bool b) => () => b ? prefix2.SecondTestClass() : null},
            1,
            5,
            const <int>[],
            const <Object>[
              prefix0.reflector,
              const prefix2.SecondTestClassGenerator()
            ],
            null),
        r.NonGenericClassMirrorImpl(
            r'ThirdTestClass',
            r'.ThirdTestClass',
            134217735,
            6,
            const prefix0.ReflectorTest(),
            const <int>[9, 10, 11, 12, 70],
            const <int>[26, 35, 27, 28, 29, 62, 63, 64, 65, 66, 67, 68, 69],
            const <int>[],
            -1,
            {},
            {},
            {r'': (bool b) => () => b ? prefix3.ThirdTestClass() : null},
            2,
            6,
            const <int>[],
            const <Object>[prefix0.reflector],
            null),
        r.NonGenericClassMirrorImpl(
            r'dart.core.Object with .IValueGenerator',
            r'.dart.core.Object with .IValueGenerator',
            134218311,
            7,
            const prefix0.ReflectorTest(),
            const <int>[71, 72, 73, 74, 75],
            const <int>[26, 35, 27, 28, 29],
            const <int>[],
            -1,
            const {},
            const {},
            const {},
            1,
            -1,
            const <int>[],
            const [],
            null)
      ],
      <m.DeclarationMirror>[
        r.VariableMirrorImpl(
            r'identifier',
            134348805,
            0,
            const prefix0.ReflectorTest(),
            -1,
            8,
            8,
            const <int>[],
            const <Object>[const prefix5.PrimaryKey()]),
        r.VariableMirrorImpl(r'anyDatetime', 134348805, 0,
            const prefix0.ReflectorTest(), -1, 9, 9, const <int>[], const []),
        r.VariableMirrorImpl(r'stupid', 134349973, 1,
            const prefix0.ReflectorTest(), 1, 1, 1, const <int>[], const []),
        r.VariableMirrorImpl(r'idiot', 134349973, 1,
            const prefix0.ReflectorTest(), 1, 1, 1, const <int>[], const []),
        r.VariableMirrorImpl(r'motherFucker', 134349973, 1,
            const prefix0.ReflectorTest(), 1, 1, 1, const <int>[], const []),
        r.VariableMirrorImpl(
            r'values',
            151127253,
            1,
            const prefix0.ReflectorTest(),
            -1,
            10,
            11,
            const <int>[1],
            const []),
        r.VariableMirrorImpl(
            r'annotations',
            151127045,
            -1,
            const prefix0.ReflectorTest(),
            -1,
            12,
            13,
            null,
            const <Object>[override]),
        r.VariableMirrorImpl(
            r'superList',
            151126021,
            5,
            const prefix0.ReflectorTest(),
            -1,
            14,
            15,
            const <int>[8],
            const <Object>[const prefix2.TestClassMakeIntList()]),
        r.VariableMirrorImpl(
            r'randomText',
            134348805,
            5,
            const prefix0.ReflectorTest(),
            -1,
            16,
            16,
            const <int>[],
            const <Object>[const prefix2.TestClassMakeRandomText()]),
        r.VariableMirrorImpl(
            r'identifier',
            134348805,
            6,
            const prefix0.ReflectorTest(),
            -1,
            8,
            8, const <int>[], const <Object>[
          const prefix5.PrimaryKey(),
          const prefix6.CheckNumberRange(maximum: 999)
        ]),
        r.VariableMirrorImpl(
            r'name',
            134348805,
            6,
            const prefix0.ReflectorTest(),
            -1,
            16,
            16, const <int>[], const <Object>[
          const prefix7.EssentialKey(),
          const prefix8.CheckTextLength(minimum: 3, maximum: 120)
        ]),
        r.VariableMirrorImpl(r'isAdmin', 134348805, 6,
            const prefix0.ReflectorTest(), -1, 17, 17, const <int>[], const []),
        r.VariableMirrorImpl(
            r'age',
            134348805,
            6,
            const prefix0.ReflectorTest(),
            -1,
            8,
            8, const <int>[], const <Object>[
          const prefix6.CheckNumberRange(minimum: 18, maximum: 120),
          const prefix7.EssentialKey()
        ]),
        r.MethodMirrorImpl(r'getter', 1310722, 0, -1, -1, -1, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'getterStatic',
            1310738,
            0,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const []),
        r.MethodMirrorImpl(
            r'toString',
            2097154,
            0,
            -1,
            16,
            16,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 0, 16),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 0, 17),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 1, 18),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 1, 19),
        r.MethodMirrorImpl(r'whatIDo', 2097155, 0, -1, 16, 16, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'type', 2097155, 0, 1, 1, 1, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'name', 2097155, 0, -1, 16, 16, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'name=', 1310724, 0, -1, -1, -1, const <int>[],
            const <int>[4], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'', 0, 0, -1, 0, 0, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'superHuman', 1, 0, -1, 0, 0, const <int>[],
            const <int>[0, 1], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'==', 2097154, -1, -1, 17, 17, const <int>[],
            const <int>[5], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'noSuchMethod',
            524290,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[6],
            const prefix0.ReflectorTest(),
            const []),
        r.MethodMirrorImpl(r'hashCode', 2097155, -1, -1, 8, 8, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'runtimeType',
            2097155,
            -1,
            -1,
            18,
            18,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const []),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 2, 30),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 3, 31),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 4, 32),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 5, 33),
        r.MethodMirrorImpl(r'', 192, 1, -1, 1, 1, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'toString', 2097154, -1, -1, 16, 16, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'index', 2097155, -1, -1, 8, 8, const <int>[],
            const <int>[], const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(r'', 128, 2, -1, 2, 2, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'isCompatible',
            2097154,
            -1,
            -1,
            17,
            17,
            const <int>[],
            const <int>[7],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'generateEmptryObject',
            524290,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'convertObject',
            524290,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[8],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'isTypeCompatible',
            2097154,
            -1,
            -1,
            17,
            17,
            const <int>[],
            const <int>[9],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'serializeToMap',
            524290,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[10],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'cloneObject',
            524290,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[11],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 6, 44),
        r.MethodMirrorImpl(
            r'type',
            2097155,
            -1,
            -1,
            18,
            18,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'name',
            2097155,
            -1,
            -1,
            16,
            16,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'cloneObject',
            524290,
            3,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[12],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'convertObject',
            524290,
            3,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[13],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'generateEmptryObject',
            524290,
            3,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'isCompatible',
            2097154,
            3,
            -1,
            17,
            17,
            const <int>[],
            const <int>[14],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'isTypeCompatible',
            2097154,
            3,
            -1,
            17,
            17,
            const <int>[],
            const <int>[15],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(r'', 128, 3, -1, 3, 3, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'generateByMap',
            2097154,
            4,
            5,
            5,
            5,
            const <int>[],
            const <int>[16],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(
            r'generateByMethod',
            2097154,
            4,
            5,
            5,
            5,
            const <int>[],
            const <int>[17, 18],
            const prefix0.ReflectorTest(),
            const <Object>[override]),
        r.MethodMirrorImpl(r'', 128, 4, -1, 4, 4, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'getterPerson',
            1310722,
            5,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[19],
            const prefix0.ReflectorTest(),
            const []),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 7, 57),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 7, 58),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 8, 59),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 8, 60),
        r.MethodMirrorImpl(r'', 64, 5, -1, 5, 5, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 9, 62),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 9, 63),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 10, 64),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 10, 65),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 11, 66),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 11, 67),
        r.ImplicitGetterMirrorImpl(const prefix0.ReflectorTest(), 12, 68),
        r.ImplicitSetterMirrorImpl(const prefix0.ReflectorTest(), 12, 69),
        r.MethodMirrorImpl(r'', 64, 6, -1, 6, 6, const <int>[], const <int>[],
            const prefix0.ReflectorTest(), const []),
        r.MethodMirrorImpl(
            r'generateEmptryObject',
            524802,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[],
            const prefix0.ReflectorTest(),
            const []),
        r.MethodMirrorImpl(
            r'convertObject',
            524802,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[26],
            const prefix0.ReflectorTest(),
            const []),
        r.MethodMirrorImpl(
            r'cloneObject',
            524802,
            -1,
            -1,
            -1,
            -1,
            const <int>[],
            const <int>[27],
            const prefix0.ReflectorTest(),
            const []),
        r.MethodMirrorImpl(
            r'isCompatible',
            2097666,
            -1,
            -1,
            17,
            17,
            const <int>[],
            const <int>[28],
            const prefix0.ReflectorTest(),
            const []),
        r.MethodMirrorImpl(
            r'isTypeCompatible',
            2097666,
            -1,
            -1,
            17,
            17,
            const <int>[],
            const <int>[29],
            const prefix0.ReflectorTest(),
            const [])
      ],
      <m.ParameterMirror>[
        r.ParameterMirrorImpl(
            r'name',
            134356998,
            25,
            const prefix0.ReflectorTest(),
            -1,
            16,
            16,
            const <int>[],
            const [],
            null,
            #name),
        r.ParameterMirrorImpl(
            r'date',
            134356998,
            25,
            const prefix0.ReflectorTest(),
            -1,
            9,
            9,
            const <int>[],
            const [],
            null,
            #date),
        r.ParameterMirrorImpl(
            r'_identifier',
            134348902,
            17,
            const prefix0.ReflectorTest(),
            -1,
            8,
            8,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_anyDatetime',
            134348902,
            19,
            const prefix0.ReflectorTest(),
            -1,
            9,
            9,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'newValue',
            67141638,
            23,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'other',
            134348806,
            26,
            const prefix0.ReflectorTest(),
            -1,
            19,
            19,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'invocation',
            134348806,
            27,
            const prefix0.ReflectorTest(),
            -1,
            20,
            20,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'item',
            67141638,
            38,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'originalItem',
            67141638,
            40,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'type',
            134348806,
            41,
            const prefix0.ReflectorTest(),
            -1,
            18,
            18,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'item',
            67141638,
            42,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'originalItem',
            67141638,
            43,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'originalItem',
            67141638,
            47,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'originalItem',
            67141638,
            48,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'item',
            67141638,
            50,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'type',
            134348806,
            51,
            const prefix0.ReflectorTest(),
            -1,
            18,
            18,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'namedParametesValues',
            151134214,
            53,
            const prefix0.ReflectorTest(),
            -1,
            21,
            22,
            null,
            const [],
            null,
            #namedParametesValues),
        r.ParameterMirrorImpl(
            r'fixedParametersValues',
            151134214,
            54,
            const prefix0.ReflectorTest(),
            -1,
            12,
            13,
            null,
            const [],
            null,
            #fixedParametersValues),
        r.ParameterMirrorImpl(
            r'namedParametesValues',
            151134214,
            54,
            const prefix0.ReflectorTest(),
            -1,
            21,
            22,
            null,
            const [],
            null,
            #namedParametesValues),
        r.ParameterMirrorImpl(
            r'getterName',
            134348806,
            56,
            const prefix0.ReflectorTest(),
            -1,
            16,
            16,
            const <int>[],
            const <Object>[const prefix2.TestClassMakeRandomText()],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_superList',
            151126118,
            58,
            const prefix0.ReflectorTest(),
            -1,
            14,
            15,
            const <int>[8],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_randomText',
            134348902,
            60,
            const prefix0.ReflectorTest(),
            -1,
            16,
            16,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_identifier',
            134348902,
            63,
            const prefix0.ReflectorTest(),
            -1,
            8,
            8,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_name',
            134348902,
            65,
            const prefix0.ReflectorTest(),
            -1,
            16,
            16,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_isAdmin',
            134348902,
            67,
            const prefix0.ReflectorTest(),
            -1,
            17,
            17,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'_age',
            134348902,
            69,
            const prefix0.ReflectorTest(),
            -1,
            8,
            8,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'originalItem',
            67141638,
            72,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'originalItem',
            67141638,
            73,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'item',
            67141638,
            74,
            const prefix0.ReflectorTest(),
            -1,
            -1,
            -1,
            const <int>[],
            const [],
            null,
            null),
        r.ParameterMirrorImpl(
            r'type',
            134348806,
            75,
            const prefix0.ReflectorTest(),
            -1,
            18,
            18,
            const <int>[],
            const [],
            null,
            null)
      ],
      <Type>[
        prefix1.TestClass,
        prefix1.TestClassType,
        prefix2.TestClassMakeIntList,
        prefix2.TestClassMakeRandomText,
        prefix2.SecondTestClassGenerator,
        prefix2.SecondTestClass,
        prefix3.ThirdTestClass,
        const r.FakeType(r'.dart.core.Object with .IValueGenerator'),
        int,
        DateTime,
        const m.TypeValue<List<prefix1.TestClassType>>().type,
        List,
        const m.TypeValue<List<dynamic>>().type,
        List,
        const m.TypeValue<List<int>>().type,
        List,
        String,
        bool,
        Type,
        Object,
        Invocation,
        const m.TypeValue<Map<String, dynamic>>().type,
        Map
      ],
      8,
      {
        r'==': (dynamic instance) => (x) => instance == x,
        r'toString': (dynamic instance) => instance.toString,
        r'noSuchMethod': (dynamic instance) => instance.noSuchMethod,
        r'hashCode': (dynamic instance) => instance.hashCode,
        r'runtimeType': (dynamic instance) => instance.runtimeType,
        r'getter': (dynamic instance) => instance.getter,
        r'identifier': (dynamic instance) => instance.identifier,
        r'anyDatetime': (dynamic instance) => instance.anyDatetime,
        r'whatIDo': (dynamic instance) => instance.whatIDo,
        r'type': (dynamic instance) => instance.type,
        r'name': (dynamic instance) => instance.name,
        r'index': (dynamic instance) => instance.index,
        r'isCompatible': (dynamic instance) => instance.isCompatible,
        r'generateEmptryObject': (dynamic instance) =>
            instance.generateEmptryObject,
        r'convertObject': (dynamic instance) => instance.convertObject,
        r'isTypeCompatible': (dynamic instance) => instance.isTypeCompatible,
        r'serializeToMap': (dynamic instance) => instance.serializeToMap,
        r'cloneObject': (dynamic instance) => instance.cloneObject,
        r'annotations': (dynamic instance) => instance.annotations,
        r'generateByMap': (dynamic instance) => instance.generateByMap,
        r'generateByMethod': (dynamic instance) => instance.generateByMethod,
        r'getterPerson': (dynamic instance) => instance.getterPerson,
        r'superList': (dynamic instance) => instance.superList,
        r'randomText': (dynamic instance) => instance.randomText,
        r'isAdmin': (dynamic instance) => instance.isAdmin,
        r'age': (dynamic instance) => instance.age
      },
      {
        r'identifier=': (dynamic instance, value) =>
            instance.identifier = value,
        r'anyDatetime=': (dynamic instance, value) =>
            instance.anyDatetime = value,
        r'name=': (dynamic instance, value) => instance.name = value,
        r'superList=': (dynamic instance, value) => instance.superList = value,
        r'randomText=': (dynamic instance, value) =>
            instance.randomText = value,
        r'isAdmin=': (dynamic instance, value) => instance.isAdmin = value,
        r'age=': (dynamic instance, value) => instance.age = value
      },
      <m.LibraryMirror>[
        r.LibraryMirrorImpl(
            r'',
            Uri.parse('asset:maxi_library/test/entities/test_class.dart'),
            const prefix0.ReflectorTest(),
            const <int>[],
            {},
            {},
            const [],
            null),
        r.LibraryMirrorImpl(
            r'',
            Uri.parse(
                'asset:maxi_library/test/entities/second_test_class.dart'),
            const prefix0.ReflectorTest(),
            const <int>[],
            {},
            {},
            const [],
            null),
        r.LibraryMirrorImpl(
            r'',
            Uri.parse('asset:maxi_library/test/entities/third_test_class.dart'),
            const prefix0.ReflectorTest(),
            const <int>[],
            {},
            {},
            const [],
            null)
      ],
      []),
  const prefix4.BaseDecoratorReflector(): r.ReflectorData(
      <m.TypeMirror>[],
      <m.DeclarationMirror>[],
      <m.ParameterMirror>[],
      <Type>[],
      0,
      {},
      {},
      <m.LibraryMirror>[],
      [])
};

final _memberSymbolMap = null;

void initializeReflectable() {
  r.data = _data;
  r.memberSymbolMap = _memberSymbolMap;
}
