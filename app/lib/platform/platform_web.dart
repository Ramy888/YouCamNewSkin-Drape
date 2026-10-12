// Browser implementation: sessionStorage, a hidden <input type=file capture>, and postMessage to the opener.
import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

String? readStore(String key) {
  try {
    return web.window.sessionStorage.getItem(key);
  } catch (_) {
    return null; // storage blocked (private mode, sandbox): fall back to memory only
  }
}

void writeStore(String key, String? value) {
  try {
    if (value == null) {
      web.window.sessionStorage.removeItem(key);
    } else {
      web.window.sessionStorage.setItem(key, value);
    }
  } catch (_) {
    // ignore: the app keeps the value in memory
  }
}

Future<Uint8List?> pickImage({bool selfie = false}) {
  final done = Completer<Uint8List?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/jpeg,image/png,image/*';
  input.setAttribute('capture', selfie ? 'user' : 'environment');
  input.onchange = ((web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      done.complete(null);
      return;
    }
    final reader = web.FileReader();
    reader.onload = ((web.Event _) {
      final buf = reader.result as JSArrayBuffer?;
      done.complete(buf?.toDart.asUint8List());
    }).toJS;
    reader.onerror = ((web.Event _) => done.complete(null)).toJS;
    reader.readAsArrayBuffer(files.item(0)!);
  }).toJS;
  input.addEventListener('cancel', ((web.Event _) {
    if (!done.isCompleted) done.complete(null);
  }).toJS);
  input.click();
  return done.future;
}

bool hasOpener() {
  try {
    final opener = web.window.opener;
    return opener != null && !(opener as web.Window).closed;
  } catch (_) {
    return false;
  }
}

bool postToOpener(Map<String, Object?> message, String targetOrigin) {
  if (targetOrigin.isEmpty || targetOrigin == '*') return false;
  try {
    final opener = web.window.opener as web.Window?;
    if (opener == null) return false;
    opener.postMessage(message.jsify(), targetOrigin.toJS);
    return true;
  } catch (_) {
    return false;
  }
}

void openUrl(String url) {
  // A plain new tab: the store page doesn't need (and shouldn't get) a handle back to Drape.
  web.window.open(url, '_blank', 'noopener');
}
