import 'dart:convert';

import 'package:drape_app/api.dart';
import 'package:drape_app/platform/platform.dart';
import 'package:drape_app/screens/seller_screen.dart';
import 'package:drape_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A fake backend: the ledger reports [role]; one product in the catalogue.
DrapeApi fakeApi(String role) => DrapeApi(
      base: Uri.parse('http://test'),
      client: MockClient((req) async {
        final body = switch (req.url.path) {
          '/v1/admin/ledger' => {'budget': 400, 'used': 23, 'remaining': 377, 'usedToday': 0, 'stuck': 0, 'stuckEntries': [], 'role': role},
          '/v1/admin/products' => {
              'products': [
                {
                  'id': 'abaya-classic', 'name': 'Classic satin abaya', 'category': 'full_body', 'price': 890, 'currency': 'EGP',
                  'colorways': [{'id': 'black', 'name': 'Black', 'hex': '#1c1c1e', 'image': ''}],
                },
              ],
            },
          _ => {'error': {'code': 'DRAPE_NOT_FOUND', 'message': 'no', 'fix': ''}},
        };
        return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
      }),
    );

Future<void> pumpConsole(WidgetTester tester, String role) async {
  await tester.binding.setSurfaceSize(const Size(1300, 1800));
  Platform.writeStore('drape.sellerKey', 'sk_test');
  await tester.pumpWidget(MaterialApp(theme: drapeTheme(), home: SellerScreen(api: fakeApi(role))));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Classic satin abaya'));
  await tester.pumpAndSettle();
}

bool enabled(WidgetTester tester, String label) {
  final b = tester.widget<ButtonStyleButton>(find.ancestor(of: find.text(label), matching: find.bySubtype<ButtonStyleButton>()).first);
  return b.onPressed != null;
}

void main() {
  testWidgets('judge key: console is visible but every change is switched off', (tester) async {
    await pumpConsole(tester, 'judge');
    expect(find.textContaining('View-only judge access'), findsOneWidget);
    expect(find.text('View only'), findsOneWidget);
    expect(enabled(tester, 'Save changes'), isFalse);
    expect(enabled(tester, 'Add colourway'), isFalse);
    expect(enabled(tester, 'Upload photo'), isFalse);
    expect(enabled(tester, 'New product'), isFalse);
  });

  testWidgets('owner key: the same controls work', (tester) async {
    await pumpConsole(tester, 'owner');
    expect(find.textContaining('View-only judge access'), findsNothing);
    expect(enabled(tester, 'Save changes'), isTrue);
    expect(enabled(tester, 'Add colourway'), isTrue);
    expect(enabled(tester, 'Upload photo'), isTrue);
    expect(enabled(tester, 'New product'), isTrue);
  });
}
