import 'package:drape_app/api.dart';
import 'package:drape_app/l10n.dart';
import 'package:drape_app/platform/platform.dart';
import 'package:drape_app/screens/compare_screen.dart';
import 'package:drape_app/screens/seller_screen.dart';
import 'package:drape_app/screens/start_screens.dart';
import 'package:drape_app/state.dart';
import 'package:drape_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'seller_readonly_test.dart' show fakeApi;

// Judges may use a phone, a tablet or a laptop: every screen must lay out without overflow at each size,
// in both languages. Any RenderFlex overflow throws and fails the test.
const sizes = {
  'phone': Size(375, 812),
  'tablet portrait': Size(820, 1180),
  'tablet landscape': Size(1180, 820),
};

Widget wrap(Lang lang, Widget child) =>
    MaterialApp(theme: drapeTheme(), home: Directionality(textDirection: S(lang).dir, child: Scaffold(body: child)));

void main() {
  for (final MapEntry(key: name, value: size) in sizes.entries) {
    for (final lang in Lang.values) {
      testWidgets('landing fits a $name in ${lang.name}', (tester) async {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(wrap(lang, LandingScreen(app: AppState(lang: lang)..live = false)));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('compare pair fits a $name in ${lang.name}', (tester) async {
        await tester.binding.setSurfaceSize(size);
        final s = S(lang);
        Colorway cw(String id, Verdict v) => Colorway(id: id, name: 'Emerald green', hex: '#1f7a55', image: '', verdict: v);
        await tester.pumpWidget(wrap(
          lang,
          SingleChildScrollView(child: ComparePairView(s: s, pick: CompareSide(colorway: cw('a', Verdict.yours)), off: CompareSide(colorway: cw('b', Verdict.avoid)))),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('seller sign-in fits a $name', (tester) async {
      await tester.binding.setSurfaceSize(size);
      Platform.writeStore('drape.sellerKey', null);
      await tester.pumpWidget(MaterialApp(theme: drapeTheme(), home: SellerScreen(api: DrapeApi())));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Sign in to your store'), findsOneWidget);
    });

    testWidgets('seller console and product editor fit a $name', (tester) async {
      await tester.binding.setSurfaceSize(size);
      Platform.writeStore('drape.sellerKey', 'sk_test');
      await tester.pumpWidget(MaterialApp(theme: drapeTheme(), home: SellerScreen(api: fakeApi('owner'))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Classic satin abaya'));
      await tester.tap(find.text('Classic satin abaya'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Save changes'), findsOneWidget);
    });
  }
}
