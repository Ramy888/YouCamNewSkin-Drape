import 'package:drape_app/api.dart';
import 'package:drape_app/l10n.dart';
import 'package:drape_app/screens/reveal_screen.dart';
import 'package:drape_app/screens/shop_screen.dart';
import 'package:drape_app/state.dart';
import 'package:drape_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Session sampleSession() => Session.fromJson({
      'id': 'ses_1', 'persona': true, 'mode': 'replay', 'storeOrigin': null,
      'photos': {'face': '/persona/face.jpg', 'body': '/persona/body.jpg'},
      'palette': {
        'undertone': 'warm', 'contrast': 'high', 'metal': 'gold',
        'lip': {'name': 'Brick coral', 'hex': '#b5523b'},
        'suits': [{'id': 'emerald', 'name': 'Emerald', 'hex': '#1f7a55'}, {'id': 'olive', 'name': 'Olive', 'hex': '#6b7a3a'}],
        'avoid': [{'id': 'icy-pink', 'name': 'Icy pink', 'hex': '#f2c8d8'}],
      },
      'products': [
        {
          'id': 'abaya-classic', 'name': 'Classic satin abaya', 'category': 'full_body', 'price': 890, 'currency': 'EGP',
          'colorways': [
            {'id': 'emerald', 'name': 'Emerald', 'hex': '#1f7a55', 'image': '', 'verdict': 'yours'},
            {'id': 'lavender', 'name': 'Lavender', 'hex': '#b7a6d8', 'image': '', 'verdict': 'avoid'},
          ],
        },
      ],
      'jobs': [],
    });

Widget wrap(Lang lang, Widget child) =>
    MaterialApp(theme: drapeTheme(), home: Directionality(textDirection: S(lang).dir, child: Scaffold(body: child)));

void main() {
  // The smallest common Android width (Galaxy A-series, 360 px) is where words broke mid-way.
  for (final lang in Lang.values) {
    testWidgets('shop on a 360 px phone never breaks a colour name (${lang.name})', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 780));
      final app = AppState(lang: lang)..session = sampleSession();
      await tester.pumpWidget(wrap(lang, ShopScreen(app: app)));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final line = tester.getSize(find.text('Emerald')).height;
      expect(tester.getSize(find.text('Lavender')).height, line, reason: '"Lavender" wrapped onto a second line');
    });

    testWidgets('your colours fits a 360 px phone with both drapes side by side (${lang.name})', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 780));
      final app = AppState(lang: lang)..session = sampleSession();
      await tester.pumpWidget(wrap(lang, RevealScreen(app: app)));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final best = tester.getTopLeft(find.text('Emerald').first);
      final worst = tester.getTopLeft(find.text('Icy pink').first);
      expect((best.dy - worst.dy).abs(), lessThan(4), reason: 'best and worst drapes should be on the same row');
    });
  }
}
