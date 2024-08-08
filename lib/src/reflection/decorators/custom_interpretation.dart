import 'package:maxi_library/maxi_library.dart';

abstract class CustomInterpretation {
  const CustomInterpretation();

  dynamic performInterpretation({
    required dynamic value,
    required IDeclarationReflector declaration,
  });
}
