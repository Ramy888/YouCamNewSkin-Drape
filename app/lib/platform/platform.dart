// Browser features behind one small interface so the rest of the app (and the VM tests) never import
// web-only libraries directly.
import 'dart:typed_data';

import 'platform_stub.dart' if (dart.library.js_interop) 'platform_web.dart' as impl;

abstract final class Platform {
  static String? readStore(String key) => impl.readStore(key);
  static void writeStore(String key, String? value) => impl.writeStore(key, value);

  /// Opens the device file picker / camera. Returns the raw bytes, or null if the user cancelled.
  static Future<Uint8List?> pickImage({bool selfie = false}) => impl.pickImage(selfie: selfie);

  /// True when this window was opened by a store page (embed popup) that is still open.
  static bool get hasOpener => impl.hasOpener();

  /// Sends [message] to the opener window, only to [targetOrigin] (never "*").
  static bool postToOpener(Map<String, Object?> message, String targetOrigin) => impl.postToOpener(message, targetOrigin);
}
