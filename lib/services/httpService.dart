import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

class HttpService {
  static final String _host = "https://xn--blleblle-n4ae.de";
  static int _versionNumber = 4;

  static Future<bool> updateAvailable() async {
    http.Response response = await http.get(_host + "/install/climbingboard/version.txt");
    int version = int.tryParse(response.body) ?? -1;
    if (version > _versionNumber) return true;

    return false;
  }

  static Future<String> refreshWallImage() async {
    var response = await http.get(_host + "/install/climbingboard/custom_moonboard.png");
    if (response.statusCode >= 400) return "error";
    var dir = await getApplicationDocumentsDirectory();
    var file = io.File(dir.path + "/moon.png");
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}
