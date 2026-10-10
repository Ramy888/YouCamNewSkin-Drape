import 'package:drape_app/api.dart';
import 'package:drape_app/l10n.dart';
import 'package:drape_app/screens/compare_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Colorway cw(String id, Verdict v) => Colorway(id: id, name: id, hex: '#1f7a55', image: '', verdict: v);

Widget harness(Lang lang) {
  final s = S(lang);
  return MaterialApp(
    home: Directionality(
      textDirection: s.dir,
      child: Scaffold(
        body: SizedBox(
          width: 900,
          child: ComparePairView(
            s: s,
            pick: CompareSide(colorway: cw('emerald', Verdict.yours)),
            off: CompareSide(colorway: cw('pink', Verdict.avoid)),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('English: the palette pick is on the left (reading start)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    await tester.pumpWidget(harness(Lang.en));
    final pick = tester.getCenter(find.byKey(const ValueKey('compare-pick')));
    final off = tester.getCenter(find.byKey(const ValueKey('compare-off')));
    expect(pick.dx, lessThan(off.dx));
    expect(find.text('Lifts your colouring'), findsOneWidget);
    expect(find.text('Fights your colouring'), findsOneWidget);
  });

  testWidgets('Arabic: the palette pick is on the right (reading start in RTL)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    await tester.pumpWidget(harness(Lang.ar));
    final pick = tester.getCenter(find.byKey(const ValueKey('compare-pick')));
    final off = tester.getCenter(find.byKey(const ValueKey('compare-off')));
    expect(pick.dx, greaterThan(off.dx));
    expect(find.text('يبرز ألوانك'), findsOneWidget);
  });

  testWidgets('verdict copy never talks about skin', (tester) async {
    for (final lang in Lang.values) {
      final s = S(lang);
      for (final text in [s.liftsYou, s.fightsYou, s.verdictAvoid, s.verdictYours, s.noOffPalette]) {
        expect(text.toLowerCase(), isNot(contains('skin')), reason: text);
        expect(text, isNot(contains('بشرت')), reason: text);
      }
    }
  });
}
