// The store, re-sorted by the buyer's colouring. Every product and colourway stays visible; palette
// matches come first and each colourway carries a named verdict.
import 'package:flutter/material.dart';

import '../api.dart';
import '../logic.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final products = sortProducts(app.session?.products ?? const []);
    final anyYours = products.any((p) => p.colorways.any((c) => c.verdict == Verdict.yours));
    return DrapePage(children: [
      Text(s.shopTitle, style: t.headlineSmall),
      const SizedBox(height: 12),
      if (!anyYours) ...[Notice(text: s.noneMatch), const SizedBox(height: 12)],
      for (final p in products) ...[
        _ProductRow(app: app, product: p),
        const Divider(),
      ],
    ]);
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.app, required this.product});
  final AppState app;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final cws = sortColorways(product.colorways);
    final hero = cws.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 560;
        final image = SizedBox(
          width: wide ? 200 : double.infinity,
          height: wide ? 260 : 300,
          child: ColoredBox(
            color: Colors.white,
            child: Image.network(app.api.abs(hero.image), fit: BoxFit.contain, semanticLabel: '${product.name}, ${hero.name}',
                errorBuilder: (_, _, _) => const SizedBox()),
          ),
        );
        final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: t.titleMedium),
          Text('${product.price} ${product.currency}', style: t.bodyMedium),
          const SizedBox(height: 12),
          for (final cw in cws)
            InkWell(
              onTap: () => app.openCompare(product, colorwayId: cw.id),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(children: [
                  Expanded(child: SwatchChip(name: cw.name, hex: cw.hex, size: 28)),
                  VerdictLabel(verdict: cw.verdict, s: s),
                ]),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => app.openCompare(product), child: Text(s.tryOn)),
        ]);
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [image, const SizedBox(width: 24), Expanded(child: info)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [image, const SizedBox(height: 12), info]);
      }),
    );
  }
}

/// Swatch used inside product rows; kept here for reuse by the seller preview.
Widget colourDot(String hex, {double size = 18}) =>
    Container(width: size, height: size, decoration: BoxDecoration(color: hexColor(hex), shape: BoxShape.circle, border: Border.all(color: Tone.line)));
