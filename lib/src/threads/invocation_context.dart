import 'package:maxi_library/maxi_library.dart';

class InvocationContext extends InvocationParameters {
  final IThreadManager thread;

  const InvocationContext({required super.fixedParameters, required super.namedParameters, required this.thread});

  factory InvocationContext.fromParametes({required IThreadManager thread, required InvocationParameters parametres}) => InvocationContext(
        thread: thread,
        fixedParameters: parametres.fixedParameters,
        namedParameters: parametres.namedParameters,
      );
}
