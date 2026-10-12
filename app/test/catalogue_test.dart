import 'package:drape_app/api.dart';
import 'package:drape_app/l10n.dart';
import 'package:drape_app/screens/shop_screen.dart';
import 'package:drape_app/state.dart';
import 'package:drape_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> product(String id, String name, String storeId, String storeName, String colour, String verdict) => {
      'id': id, 'name': name, 'category': 'full_body', 'price': 800, 'currency': 'EGP',
      'colorways': [{'id': colour.toLowerCase(), 'name': colour, 'hex': '#1f7a55', 'image': '', 'verdict': verdict}],
      'store': {'id': storeId, 'name': storeName, 'url': 'https://$storeId.example/'},
      'buyUrl': 'https://$storeId.example/$id',
    };

/// Drape's own catalogue: products from two fictional stores.
Session catalogue() => Session.fromJson({
      'id': 'ses_1', 'persona': true, 'mode': 'replay', 'storeOrigin': null,
      'photos': {'face': '/persona/face.jpg', 'body': '/persona/body.jpg'},
      'palette': {
        'undertone': 'warm', 'contrast': 'high', 'metal': 'gold', 'lip': {'name': 'Brick coral', 'hex': '#b5523b'},
        'suits': [{'id': 'emerald', 'name': 'Emerald', 'hex': '#1f7a55'}], 'avoid': [],
      },
      'products': [
        product('abaya-classic', 'Classic satin abaya', 'demo', 'Noor Modest', 'Emerald', 'yours'),
        product('kaftan-coat', 'Woven kaftan coat', 'layla', 'Layla Boutique', 'Saffron', 'yours'),
      ],
      'jobs': [],
    });

Widget wrap(Lang lang, AppState app) =>
    MaterialApp(theme: drapeTheme(), home: Directionality(textDirection: S(lang).dir, child: Scaffold(body: ShopScreen(app: app))));

void main() {
  for (final size in const [Size(360, 780), Size(820, 1180), Size(1180, 820)]) {
    for (final lang in Lang.values) {
      testWidgets('catalogue across stores fits ${size.width.toInt()} (${lang.name})', (tester) async {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(wrap(lang, AppState(lang: lang)..session = catalogue()));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(S(lang).allStores), findsOneWidget);
        expect(find.text(S(lang).buyAt('Layla Boutique')), findsOneWidget);
      });
    }
  }

  testWidgets('store filter and search narrow the catalogue', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 1600));
    await tester.pumpWidget(wrap(Lang.en, AppState()..session = catalogue()));
    await tester.pump();
    expect(find.text('Classic satin abaya'), findsOneWidget);
    expect(find.text('Woven kaftan coat'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Layla Boutique'));
    await tester.pump();
    expect(find.text('Classic satin abaya'), findsNothing);
    expect(find.text('Woven kaftan coat'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, S(Lang.en).allStores));
    await tester.enterText(find.byKey(const ValueKey('shop-search')), 'abaya');
    await tester.pump();
    expect(find.text('Classic satin abaya'), findsOneWidget);
    expect(find.text('Woven kaftan coat'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('shop-search')), 'zzz');
    await tester.pump();
    expect(find.text(S(Lang.en).noResults), findsOneWidget);
  });

  testWidgets("opened from a store's own page, there is no buy-elsewhere link", (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 1600));
    final app = AppState(entry: const EntryParams(pk: 'pk_demo_drape', storeOrigin: 'https://noor.example'))..session = catalogue();
    await tester.pumpWidget(wrap(Lang.en, app));
    await tester.pump();
    expect(find.textContaining('Buy at'), findsNothing);
  });
}
