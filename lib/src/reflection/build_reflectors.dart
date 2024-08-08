import 'package:reflectable/reflectable_builder.dart' as builder;

mixin BuildReflectors {
  static Future<void> makeFilesReflection({String mainFileDirection = 'lib/main.dart'}) async {
    final dio = await builder.reflectableBuild([mainFileDirection]);
    print(dio);
  }
}
