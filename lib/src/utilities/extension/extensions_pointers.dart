import 'package:maxi_library/maxi_library.dart';

extension ExtensionExternalPerceptiveVariable<T> on UniqueSharedPoint<IPerceptiveVariable<T>> {
  PerceptiveVariableReference<T> get asPerceptibleVariable {
    return PerceptiveVariableReference<T>(
      valueGetter: () => execute(function: (item, para) => item.value),
      received: getStream(function: (item, para) => item.notifyChange),
    );
  }
}
