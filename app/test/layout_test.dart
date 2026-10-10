import 'package:drape_app/api.dart';
import 'package:drape_app/l10n.dart';
import 'package:drape_app/screens/compare_screen.dart';
import 'package:drape_app/screens/seller_screen.dart';
import 'package:drape_app/screens/start_screens.dart';
import 'package:drape_app/state.dart';
import 'package:drape_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The redesign must hold at phone width (375 px) in both languages: any RenderFlex overflow fails the test.
void main() {
  for (final lang in Lang.values) {
    testWidgets('landing fits a phone in ${lang.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      final app = AppState(lang: lang)..live = false;
      await tester.pumpWidget(MaterialApp(
        theme: drapeTheme(),
        home: Directionality(textDirection: S(lang).dir, child: Scaffold(body: LandingScreen(app: app))),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('compare pair fits a phone in ${lang.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      final s = S(lang);
      Colorway cw(String id, Verdict v) => Colorway(id: id, name: 'Emerald green', hex: '#1f7a55', image: '', verdict: v);
      await tester.pumpWidget(MaterialApp(
        theme: drapeTheme(),
        home: Directionality(
          textDirection: s.dir,
          child: Scaffold(body: SingleChildScrollView(child: ComparePairView(s: s, pick: CompareSide(colorway: cw('a', Verdict.yours)), off: CompareSide(colorway: cw('b', Verdict.avoid))))),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('seller sign-in fits a phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    await tester.pumpWidget(MaterialApp(theme: drapeTheme(), home: SellerScreen(api: DrapeApi())));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Sign in to your store'), findsOneWidget);
  });
}
