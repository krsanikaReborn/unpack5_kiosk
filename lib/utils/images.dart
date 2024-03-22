import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

Future<img.Image> getImageBytes(String url) async {
  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return img.decodeImage(response.bodyBytes)!;
  } else {
    throw Exception('Failed to load image');
  }
}

Future<img.Image> loadImageAsset(String path) async {
  final byteData = await rootBundle.load(path);
  return img.decodeImage(byteData.buffer.asUint8List())!;
}
