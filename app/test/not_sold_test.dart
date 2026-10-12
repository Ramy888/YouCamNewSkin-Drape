import 'package:drape_app/api.dart';
import 'package:drape_app/l10n.dart';
import 'package:drape_app/platform/platform.dart';
import 'package:drape_app/screens/compare_screen.dart';
import 'package:drape_app/screens/seller_screen.dart';
import 'package:drape_app/screens/shop_screen.dart';
import 'package:drape_app/state.dart';
import 'package:drape_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'seller_readonly_test.dart' show fakeApi;

/// The sample person's view of a product none of whose colours suit her, with a palette fabric suggested.
Session notSoldSession() => Session.fromJson({
      'id': 'ses_1', 'persona': true, 'mode': 'replay', 'storeOrigin': null,
      'photos': {'face': '/persona/face.jpg', 'body': '/persona/body.jpg'},
      'palette': {
        'undertone': 'warm', 'contrast': 'high', 'metal': 'gold',
        'lip': {'name': 'Brick coral', 'hex': '#b5523b'},
        'suits': [{'id': 'teal', 'name': 'Deep teal', 'hex': '#1f5f63'}],
        'avoid': [{'id': 'icy-pink', 'name': 'Icy pink', 'hex': '#f2c8d8'}],
      },
      'products': [
        {
          'id': 'abaya-everyday', 'name': 'Everyday satin abaya', 'category': 'full_body', 'price': 750, 'currency': 'EGP',
          'colorways': [
            {'id': 'navy', 'name': 'Navy', 'hex': '#1f2f5a', 'image': '', 'verdict': 'neutral'},
            {'id': 'icy-pink', 'name': 'Icy pink', 'hex': '#f2c8d8', 'image': '', 'verdict': 'avoid'},
          ],
          'suggestion': {'template': 'full_body_sea_green_silk', 'name': 'Sea Green Silk', 'hex': '#0b6d6f', 'closest': {'id': 'teal', 'name': 'Deep teal', 'hex': '#1f5f63'}},
        },
      ],
      'jobs': [],
    });

Widget wrap(Lang lang, Widget child) =>
    MaterialApp(theme: drapeTheme(), home: Directionality(textDirection: S(lang).dir, child: Scaffold(body: child)));

AppState notSoldApp(Lang lang) => AppState(lang: lang)
  ..session = notSoldSession()
  ..productId = 'abaya-everyday'
  ..notSold = true;

void main() {
  for (final size in const [Size(360, 780), Size(820, 1180), Size(1180, 820)]) {
    for (final lang in Lang.values) {
      testWidgets('shop offers the palette fabric when no colour suits her (${size.width.toInt()} ${lang.name})', (tester) async {
        await tester.binding.setSurfaceSize(size);
        final app = notSoldApp(lang)..notSold = false;
        await tester.pumpWidget(wrap(lang, ShopScreen(app: app)));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(S(lang).seeItIn(S(lang).colour('Sea Green Silk'))), findsOneWidget);
      });

      testWidgets('not-sold compare: the fabric beside what she would buy, and the ask (${size.width.toInt()} ${lang.name})', (tester) async {
        await tester.binding.setSurfaceSize(size);
        final s = S(lang);
        await tester.pumpWidget(wrap(lang, CompareScreen(app: notSoldApp(lang))));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(s.notSoldTitle), findsOneWidget);
        expect(find.text(s.notSoldBadge), findsOneWidget);
        expect(find.text(s.askStore(s.colour('Sea Green Silk'))), findsOneWidget);
        // The fabric (her colour) sits on the reading-start side, like every approved pick.
        final pick = tester.getCenter(find.byKey(const ValueKey('compare-pick')));
        final off = tester.getCenter(find.byKey(const ValueKey('compare-off')));
        expect(lang == Lang.ar ? pick.dx > off.dx : pick.dx < off.dx, isTrue);
      });
    }
  }

  testWidgets('a failed or unrecorded preview falls back to the colour itself, and she can still ask', (tester) async {
    await tester.binding.setSurfaceSize(const Size(820, 1180));
    final app = notSoldApp(Lang.en)..recolorJob = Job.unavailable();
    await tester.pumpWidget(wrap(Lang.en, CompareScreen(app: app)));
    await tester.pump();
    expect(find.text(S(Lang.en).previewUnavailable), findsOneWidget);
    expect(find.text(S(Lang.en).askStore('Sea Green Silk')), findsOneWidget);
  });

  for (final role in ['owner', 'judge']) {
    testWidgets('colour demand panel for the $role, with add-as-colourway ${role == 'owner' ? 'on' : 'off'}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1300, 2400));
      Platform.writeStore('drape.sellerKey', 'sk_test');
      await tester.pumpWidget(MaterialApp(theme: drapeTheme(), home: SellerScreen(api: fakeApi(role))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Colour demand'), findsOneWidget);
      expect(find.text('Sea Green Silk'), findsOneWidget);
      expect(find.text('2 buyers · 1 demo'), findsOneWidget);
      final add = tester.widget<ButtonStyleButton>(find.ancestor(of: find.text('Add as colourway'), matching: find.bySubtype<ButtonStyleButton>()).first);
      expect(add.onPressed != null, role == 'owner');
      if (role == 'owner') {
        await tester.tap(find.text('Add as colourway'));
        await tester.pumpAndSettle();
        // The editor gains a colourway row with the requested colour's name and hex: no buyer image is carried over.
        expect(find.widgetWithText(TextField, 'Sea Green Silk'), findsOneWidget);
        expect(find.widgetWithText(TextField, '#0b6d6f'), findsOneWidget);
      }
    });
  }
}
