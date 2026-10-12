// The catalogue, re-sorted by the buyer's colouring. Every product and colourway stays visible; palette
// matches come first and each colourway carries a named verdict.
import 'package:flutter/material.dart';

import '../api.dart';
import '../logic.dart';
import '../platform/platform.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.app});
  final AppState app;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

/// Drape's catalogue: every store's products (or one store's, when opened from its page), sorted by what suits her,
/// with a search bar and store filters. Checkout happens at the store that sells the piece.
class _ShopScreenState extends State<ShopScreen> {
  String _query = '';
  String? _storeId;

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final s = app.s;
    final all = sortProducts(app.session?.products ?? const []);
    final stores = <String, StoreRef>{for (final p in all) if (p.store != null) p.store!.id: p.store!};
    final q = _query.trim().toLowerCase();
    final products = [
      for (final p in all)
        if ((_storeId == null || p.store?.id == _storeId) &&
            (q.isEmpty ||
                p.name.toLowerCase().contains(q) ||
                (p.store?.name.toLowerCase().contains(q) ?? false) ||
                p.colorways.any((c) => c.name.toLowerCase().contains(q) || s.colour(c.name).contains(q))))
          p,
    ];
    final anyYours = all.any((p) => p.colorways.any((c) => c.verdict == Verdict.yours));
    return DrapePage(children: [
      StepHeader(eyebrow: s.stepOf(2), title: s.shopTitle),
      TextField(
        key: const ValueKey('shop-search'),
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(hintText: s.searchHint, prefixIcon: const Icon(Icons.search_rounded)),
      ),
      if (stores.length > 1) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ChoiceChip(label: Text(s.allStores), selected: _storeId == null, onSelected: (_) => setState(() => _storeId = null)),
          for (final st in stores.values)
            ChoiceChip(label: Text(st.name), selected: _storeId == st.id, onSelected: (on) => setState(() => _storeId = on ? st.id : null)),
        ]),
      ],
      const SizedBox(height: 16),
      if (!anyYours) ...[Notice(text: s.noneMatch), const SizedBox(height: 16)],
      if (products.isEmpty) Notice(text: s.noResults),
      for (final p in products) ...[
        _ProductRow(app: app, product: p, showStore: stores.length > 1 || app.entry.storeOrigin == null),
        const SizedBox(height: 16),
      ],
    ]);
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.app, required this.product, this.showStore = false});
  final AppState app;
  final Product product;
  final bool showStore;

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
          if (showStore && product.store != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.storefront_outlined, size: 16, color: Tone.inkSoft),
              const SizedBox(width: 6),
              Flexible(child: Text(s.soldBy(product.store!.name), style: t.bodySmall)),
            ]),
          ],
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
                        // On narrow phones the verdict drops under the name instead of breaking the word.
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [SwatchChip(name: s.colour(cw.name), hex: cw.hex, size: 26), VerdictLabel(verdict: cw.verdict, s: s)],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(forwardIcon(context, chevron: true), color: Tone.inkSoft, size: 20),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          if (product.suggestion != null) ...[
            const SizedBox(height: 8),
            _NotSoldCard(app: app, product: product, suggestion: product.suggestion!),
          ],
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            FilledButton.icon(onPressed: () => app.openCompare(product), icon: const Icon(Icons.checkroom_outlined), label: Text(s.tryOn)),
            // From Drape's own catalogue, checkout is at the store that sells it.
            if (app.entry.storeOrigin == null && product.buyUrl != null && product.store != null)
              OutlinedButton.icon(
                onPressed: () => Platform.openUrl(product.buyUrl!),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(s.buyAt(product.store!.name)),
              ),
          ]),
        ]);
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [image, const SizedBox(width: 24), Expanded(child: info)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [image, const SizedBox(height: 16), info]);
      }),
    );
  }
}

/// None of this garment's colours suit her: offer it in a fabric from her palette (YouCam AI Fabric), "not sold yet".
class _NotSoldCard extends StatelessWidget {
  const _NotSoldCard({required this.app, required this.product, required this.suggestion});
  final AppState app;
  final Product product;
  final FabricSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Tone.mulberrySoft, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.noneYoursHere, style: t.titleMedium?.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(s.closeToYour(s.colour(suggestion.closest.name)), style: t.bodySmall),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => app.openRecolor(product),
          icon: Container(width: 18, height: 18, decoration: BoxDecoration(color: hexColor(suggestion.hex), shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
          label: Text(s.seeItIn(s.colour(suggestion.name))),
        ),
      ]),
    );
  }
}

/// Swatch used inside product rows; kept here for reuse by the seller preview.
Widget colourDot(String hex, {double size = 18}) =>
    Container(width: size, height: size, decoration: BoxDecoration(color: hexColor(hex), shape: BoxShape.circle, border: Border.all(color: Tone.line)));
