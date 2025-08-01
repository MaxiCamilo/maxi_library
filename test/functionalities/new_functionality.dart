import 'dart:async';

import 'package:maxi_library/maxi_library.dart';

class NewFunctionality with TextableFunctionality<String> {
  final int secondWaiting;

  const NewFunctionality({this.secondWaiting = 5});

  @override
  Future<String> runFunctionality({required InteractiveFunctionalityExecutor<Oration, String> manager}) async {
    await manager.sendItemAsync(const Oration(message: 'Vamos a probar este sistema'));

    await manager.delayed(Duration(seconds: secondWaiting));

    await manager.sendItemAsync(const Oration(message: 'Ya terminó'));
    return 'jejejeje';
  }

  @override
  void onCancel({required InteractiveFunctionalityExecutor<Oration, String> manager}) {
    super.onCancel(manager: manager);

    print('Oh rayos :(');
  }
}
