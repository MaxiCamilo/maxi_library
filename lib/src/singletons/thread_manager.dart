import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/operators/ithread_magares_factory.dart';

mixin ThreadManager {
  static IThreadInvoker? _instance;
  static IThreadManagersFactory? _factory;

  static IThreadInvoker get instance {
    if (_instance != null) {
      return _instance!;
    }

    if(_factory == null){
      
    }
  }



}
