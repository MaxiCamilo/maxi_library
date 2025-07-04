import 'package:maxi_library/maxi_library.dart';

mixin IAppInfo {
  String get name;
  String get serverName;

  double get version;
  double get supportedAPI;

  String get exeName;

  List<GeneratedReflectorAlbum> get reflectorsList;
}
