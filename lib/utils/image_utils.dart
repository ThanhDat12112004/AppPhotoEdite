import 'dart:io';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static Future<File> rotateImage(String path) async {
    return await FlutterExifRotation.rotateImage(path: path);
  }

  static Future<List<int>> compressImage(File imageFile,
      {int quality = 80}) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) throw Exception('Không thể đọc ảnh');
    return img.encodeJpg(image, quality: quality);
  }
}
