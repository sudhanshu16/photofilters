import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:image/image.dart' as libImage;

class PhotoFilter {
  static Future<File> applyFilter(Map<String, dynamic> params) async {
    Filter filter = params["filter"];
    File imageFile = params["image_file"];
    int width = params["width"];

    try {
      libImage.Image image = libImage.decodeImage(imageFile.readAsBytesSync());
      image = libImage.copyResize(image, width: width ?? image.width);
      Uint8List _bytes = image.getBytes();
      if (filter != null) {
        filter.apply(_bytes);
      }
      Directory dir = await getTemporaryDirectory();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          imageFile.path.split("/").last;
      File editedFile = File(
        "${dir.path}/$fileName",
      );
      editedFile.create();
      libImage.Image editedImage =
          libImage.Image.fromBytes(image.width, image.height, _bytes);
      await editedFile.writeAsBytes(
          libImage.encodeNamedImage(editedImage, editedFile.path));
      return editedFile;
    } catch (e) {
      print(e);
    }
  }
}
