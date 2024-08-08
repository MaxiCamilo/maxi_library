abstract class ClassBuilderReflection<T> {
  const ClassBuilderReflection();

  T generateByMethod({required List fixedParametersValues, required Map<String, dynamic> namedParametesValues});

  T generateByMap({required Map<String, dynamic> namedParametesValues});
}
