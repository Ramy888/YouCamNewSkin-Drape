// On-device photo preparation: decode, apply EXIF orientation, shrink the long side to ≤1920 px and
// re-encode as JPEG. Re-encoding drops all metadata (GPS, camera serials) before anything is uploaded.
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const maxSide = 1920;

/// Returns JPEG bytes ready to upload, or null if the bytes are not a readable image.
Uint8List? prepareJpeg(Uint8List bytes, {int maxLongSide = maxSide}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  final longSide = image.width > image.height ? image.width : image.height;
  if (longSide > maxLongSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxLongSide, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: maxLongSide, interpolation: img.Interpolation.average);
  }
  image.exif = img.ExifData();
  return img.encodeJpg(image, quality: 88);
}
