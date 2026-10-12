import 'dart:convert';
import 'dart:io';

import 'package:drape_app/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every colour or fabric name a buyer can see, read from the backend sources (not a hand-kept list).
Set<String> shownColourNames() {
  final names = <String>{};
  final rules = jsonDecode(File('../backend/src/palette-rules.json').readAsStringSync()) as Map<String, dynamic>;
  for (final p in (rules['palettes'] as Map).values.cast<Map>()) {
    for (final k in ['suits', 'avoid']) {
      names.addAll([for (final x in (p[k] as List).cast<Map>()) '${x['name']}']);
    }
    names.add('${p['lip']['name']}');
  }
  for (final k in ['lowContrastAvoid', 'highContrastSuits']) {
    names.addAll([for (final x in (rules[k] as List).cast<Map>()) '${x['name']}']);
  }
  final seed = File('../backend/src/state.ts').readAsStringSync();
  names.addAll(RegExp(r'name: "([^"]+)", hex').allMatches(seed).map((m) => m.group(1)!));
  final fabrics = jsonDecode(File('../backend/src/fabrics.json').readAsStringSync()) as Map<String, dynamic>;
  names.addAll([for (final t in (fabrics['templates'] as List).cast<Map>()) '${t['name']}']);
  return names;
}

void main() {
  test('every colour and fabric name a buyer can see has an Arabic name', () {
    final ar = S(Lang.ar);
    final missing = [for (final n in shownColourNames()) if (ar.colour(n) == n) n];
    expect(shownColourNames().length, greaterThan(40));
    expect(missing, isEmpty, reason: 'add these to _colourAr in lib/l10n.dart: $missing');
  });

  test('English keeps the catalogue names unchanged', () {
    expect(S(Lang.en).colour('Sea Green Silk'), 'Sea Green Silk');
    expect(S(Lang.ar).colour('Sea Green Silk'), 'حرير أخضر بحري');
  });
}
