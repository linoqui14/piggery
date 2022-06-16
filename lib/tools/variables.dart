import 'dart:ui';
import 'dart:io' show File, Platform, stdout;
import 'package:http/http.dart' as http;
class MyColors{
  static const Color red = Color(0xffBF1744);
  static const Color darkBlue = Color(0xff0433BF);
  static const Color grey = Color(0xff434A59);
  static const Color deadBlue = Color(0xff558ED9);
  static const Color skyBlueDead = Color(0xffA7C8F2);

}

class Constants{
  static String hostname = Platform.localHostname;
}

class Tools{
  static Future<File> downloadFile(String url, String filename) async {
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = './images';
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }


}