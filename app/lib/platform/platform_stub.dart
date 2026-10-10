// Non-web implementation used by unit/widget tests on the Dart VM.
import 'dart:typed_data';

final Map<String, String> _store = {};

String? readStore(String key) => _store[key];
void writeStore(String key, String? value) => value == null ? _store.remove(key) : _store[key] = value;
Future<Uint8List?> pickImage({bool selfie = false}) async => null;
bool hasOpener() => false;
bool postToOpener(Map<String, Object?> message, String targetOrigin) => false;
