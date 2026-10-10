import 'package:drape_app/theme.dart';
import 'package:drape_app/widgets/colour_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<(String, String?)?> openAndPick(WidgetTester tester, Future<void> Function() act) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  (String, String?)? result;
  await tester.pumpWidget(MaterialApp(
    theme: drapeTheme(),
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(onPressed: () async => result = await pickColour(context, initialHex: '#000000'), child: const Text('open')),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await act();
  await tester.tap(find.text('Use this colour'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  test('every palette entry is a valid, unique hex with a name', () {
    final hexes = garmentPalette.map((c) => c.$2).toSet();
    expect(hexes.length, garmentPalette.length);
    for (final (name, hex) in garmentPalette) {
      expect(name.trim(), isNotEmpty);
      expect(RegExp(r'^#[0-9a-f]{6}$').hasMatch(hex), isTrue, reason: hex);
      expect(toHex(hexColor(hex)), hex);
    }
  });

  testWidgets('picking a palette colour returns its hex and name', (tester) async {
    final r = await openAndPick(tester, () async {
      await tester.tap(find.bySemanticsLabel('Emerald'));
      await tester.pump();
    });
    expect(r, ('#1f7a55', 'Emerald'));
  });

  testWidgets('a slider tweak becomes an unnamed custom colour', (tester) async {
    final r = await openAndPick(tester, () async {
      await tester.tap(find.bySemanticsLabel('Emerald'));
      await tester.pump();
      await tester.drag(find.byType(Slider).first, const Offset(60, 0));
      await tester.pump();
    });
    expect(r!.$2, isNull);
    expect(r.$1, isNot('#1f7a55'));
  });
}
