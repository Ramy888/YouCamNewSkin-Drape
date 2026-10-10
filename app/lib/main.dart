// Drape web app. Hash routes:
//   #/                 landing (sample person or own photo)
//   #/start?pk=&product=&colorway=&origin=&lang=   entry from the store's "Try on with Drape" popup
//   #/seller           seller console
import 'package:flutter/material.dart';

import 'api.dart';
import 'l10n.dart';
import 'screens/compare_screen.dart';
import 'screens/look_screen.dart';
import 'screens/reveal_screen.dart';
import 'screens/seller_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/start_screens.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets/common.dart';

void main() => runApp(const DrapeApp());

class DrapeApp extends StatelessWidget {
  const DrapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drape',
      debugShowCheckedModeBanner: false,
      theme: drapeTheme(),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final Widget page = switch (uri.path) {
          '/seller' => SellerScreen(api: DrapeApi(), publishableKey: uri.queryParameters['pk'] ?? 'pk_demo_drape'),
          _ => BuyerShell(
              entry: uri.path == '/start' ? EntryParams.fromQuery(uri.queryParameters) : const EntryParams(),
              lang: uri.queryParameters['lang'] == 'ar' ? Lang.ar : Lang.en,
            ),
        };
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key, required this.entry, required this.lang});
  final EntryParams entry;
  final Lang lang;

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  late final AppState app = AppState(entry: widget.entry, lang: widget.lang);

  @override
  void initState() {
    super.initState();
    app.addListener(() => setState(() {}));
    app.restore();
    app.checkLive();
  }

  @override
  void dispose() {
    app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final Widget body = switch (app.step) {
      FlowStep.start => LandingScreen(app: app),
      FlowStep.face => CaptureScreen(app: app, kind: 'face'),
      FlowStep.body => CaptureScreen(app: app, kind: 'body'),
      FlowStep.reveal => RevealScreen(app: app),
      FlowStep.shop => ShopScreen(app: app),
      FlowStep.compare => CompareScreen(app: app),
      FlowStep.look => LookScreen(app: app),
    };
    final stage = switch (app.step) { FlowStep.reveal => 1, FlowStep.shop => 2, FlowStep.compare => 3, FlowStep.look => 4, _ => 0 };
    return Directionality(
      textDirection: s.dir,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          leading: app.step == FlowStep.start ? null : IconButton(tooltip: s.back, icon: const BackButtonIcon(), onPressed: app.back),
          titleSpacing: app.step == FlowStep.start ? 20 : 0,
          title: const BrandMark(),
          actions: [
            if (app.session != null && !app.session!.persona && app.step != FlowStep.start)
              TextButton.icon(onPressed: app.deletePhotos, icon: const Icon(Icons.delete_outline_rounded, size: 18), label: Text(s.deletePhotos)),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40), padding: const EdgeInsets.symmetric(horizontal: 14)),
              onPressed: app.toggleLang,
              child: Text(s.langToggle),
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: _StageBar(stage: stage)),
        ),
        body: SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: KeyedSubtree(key: ValueKey(app.step), child: body))),
      ),
    );
  }
}

/// Four thin segments under the app bar: colours, shop, compare, look.
class _StageBar extends StatelessWidget {
  const _StageBar({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    if (stage == 0) return const Divider(height: 4, thickness: 1);
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          for (var i = 1; i <= 4; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(color: i <= stage ? Tone.mulberry : Tone.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
