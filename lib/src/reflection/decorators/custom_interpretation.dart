import 'package:maxi_library/maxi_library.dart';

mixin CustomInterpretation {

  dynamic performInterpretation({
    required dynamic value,
    required IDeclarationReflector declaration,
  });
}
