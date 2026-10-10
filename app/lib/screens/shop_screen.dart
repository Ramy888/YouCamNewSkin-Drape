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
    final products = sortProducts(app.session?.products ?? const []);
    final anyYours = products.any((p) => p.colorways.any((c) => c.verdict == Verdict.yours));
    return DrapePage(children: [
      StepHeader(eyebrow: s.stepOf(2), title: s.shopTitle),
      if (!anyYours) ...[Notice(text: s.noneMatch), const SizedBox(height: 16)],
      for (final p in products) ...[
        _ProductRow(app: app, product: p),
        const SizedBox(height: 16),
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
    return DrapeCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 560;
        final image = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: wide ? 220 : double.infinity,
            height: wide ? 290 : 320,
            color: Tone.paperDeep,
            child: Image.network(app.api.abs(hero.image), fit: BoxFit.contain, color: Tone.paperDeep, colorBlendMode: BlendMode.multiply, semanticLabel: '${product.name}, ${hero.name}',
                errorBuilder: (_, _, _) => const SizedBox()),
          ),
        );
        final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(product.name, style: t.titleLarge)),
            const SizedBox(width: 12),
            Text('${product.price} ${product.currency}', style: t.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ]),
          const SizedBox(height: 12),
          for (final cw in cws)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: Tone.paper,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => app.openCompare(product, colorwayId: cw.id),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(children: [
                        Expanded(child: SwatchChip(name: cw.name, hex: cw.hex, size: 26)),
                        VerdictLabel(verdict: cw.verdict, s: s),
                        const SizedBox(width: 4),
                        Icon(forwardIcon(context, chevron: true), color: Tone.inkSoft, size: 20),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => app.openCompare(product), icon: const Icon(Icons.checkroom_outlined), label: Text(s.tryOn)),
        ]);
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [image, const SizedBox(width: 24), Expanded(child: info)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [image, const SizedBox(height: 16), info]);
      }),
    );
  }
}

/// Swatch used inside product rows; kept here for reuse by the seller preview.
Widget colourDot(String hex, {double size = 18}) =>
    Container(width: size, height: size, decoration: BoxDecoration(color: hexColor(hex), shape: BoxShape.circle, border: Border.all(color: Tone.line)));
