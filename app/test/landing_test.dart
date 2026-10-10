import 'package:drape_app/l10n.dart';
import 'package:drape_app/screens/start_screens.dart';
import 'package:drape_app/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<OutlinedButton> pumpLanding(WidgetTester tester, bool? live) async {
  final app = AppState()..live = live;
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: LandingScreen(app: app))));
  return tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, S(Lang.en).usePhoto));
}

void main() {
  testWidgets('demo mode switches off "Use my photo" and says why', (tester) async {
    final button = await pumpLanding(tester, false);
    expect(button.onPressed, isNull);
    expect(find.text(S(Lang.en).liveOff), findsOneWidget);
  });

  testWidgets('live mode allows the buyer to use their own photo', (tester) async {
    final button = await pumpLanding(tester, true);
    expect(button.onPressed, isNotNull);
    expect(find.text(S(Lang.en).liveOff), findsNothing);
  });
}
