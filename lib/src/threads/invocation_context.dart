import 'package:maxi_library/maxi_library.dart';

class InvocationContext extends InvocationParameters {
  final IThreadManager thread;
  final IThreadInvoker sender;

  const InvocationContext({required super.fixedParameters, required super.namedParameters, required this.thread, required this.sender});

  factory InvocationContext.fromParametes({required IThreadManager thread, required IThreadInvoker applicant, required InvocationParameters parametres}) => InvocationContext(
        thread: thread,
        sender: applicant,
        fixedParameters: parametres.fixedParameters,
        namedParameters: parametres.namedParameters,
      );
}
