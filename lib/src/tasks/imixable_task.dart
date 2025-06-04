import 'package:maxi_library/maxi_library.dart';

mixin IMixableTask {
  bool isMixable(TextableFunctionality otherTask);
  void mixTask(TextableFunctionality otherTask);
}
