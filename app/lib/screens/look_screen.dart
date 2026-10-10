// Complete the look + look card: the outfit render, matching makeup (or the lip swatch when the preview
// isn't available), the palette metal, and the bundle hand-off to the store's cart.
import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LookScreen extends StatelessWidget {
  const LookScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final ses = app.session;
    final palette = ses?.palette;
    final pair = app.comparePair;
    if (ses == null || palette == null || pair == null) return const SizedBox();
    final outfit = app.tryons[pair.pick.id]?.image;
    final showsSample = app.tryons[pair.pick.id]?.sample == true;
    final makeup = app.makeupJob;
    final makeupImage = makeup?.ok == true ? makeup!.image : null;
    final jewelry = app.jewelryJob;
    final earringImage = jewelry?.ok == true ? jewelry!.image : null;
    final product = app.product!;
    final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.matchingMakeup, style: t.titleMedium),
      const SizedBox(height: 12),
      if (app.busy != null && makeup == null) Progress(text: app.busy!),
      if (makeupImage != null)
        _Round(child: Image.network(app.api.abs(makeupImage), fit: BoxFit.cover, semanticLabel: s.matchingMakeup)),
      if (makeup != null && makeupImage == null) Notice(text: makeup.errorKind == 'unavailable' ? s.makeupUnavailable : s.jobError(makeup.errorCode, makeup.errorMessage)),
      const SizedBox(height: 14),
      Text(s.lipShade, style: t.bodySmall),
      const SizedBox(height: 6),
      SwatchChip(name: palette.lip.name, hex: palette.lip.hex, size: 26, pill: true),
      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 20),
      Text(s.metalLabel, style: t.titleMedium),
      const SizedBox(height: 8),
      Tag(text: s.metal(palette.metal), icon: Icons.diamond_outlined),
      const SizedBox(height: 12),
      if (earringImage != null) _Round(child: Image.network(app.api.abs(earringImage), fit: BoxFit.cover, semanticLabel: s.earringsInMetal)),
      if (jewelry != null && earringImage == null) Notice(text: jewelry.errorKind == 'unavailable' ? s.earringUnavailable : s.jobError(jewelry.errorCode, jewelry.errorMessage)),
    ]);
    final outfitView = outfit == null
        ? const SizedBox()
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(app.api.abs(outfit), fit: BoxFit.cover, alignment: Alignment.topCenter, semanticLabel: '${product.name}, ${pair.pick.name}'),
            ),
          );
    return DrapePage(children: [
      StepHeader(eyebrow: s.stepOf(4), title: s.lookCard, lead: s.lookLead),
      if (showsSample && app.session?.persona != true) ...[Notice(text: s.sampleResult), const SizedBox(height: 16)],
      DrapeCard(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth > 620;
          return wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 320, child: outfitView),
                  const SizedBox(width: 28),
                  Expanded(child: Padding(padding: const EdgeInsets.only(top: 4), child: details)),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [outfitView, const SizedBox(height: 20), details]);
        }),
      ),
      const SizedBox(height: 16),
      DrapeCard(
        color: Tone.mulberrySoft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.yourPick.toUpperCase(), style: t.labelMedium?.copyWith(color: Tone.mulberry, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text('${product.name} · ${pair.pick.name}', style: t.titleMedium),
                Text('${s.lipShade}: ${palette.lip.name} · ${s.metalLabel}: ${s.metal(palette.metal)}', style: t.bodyMedium),
              ]),
            ),
            const SizedBox(width: 12),
            Text('${product.price} ${product.currency}', style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ]),
          const SizedBox(height: 20),
          if (app.addedAtStore) Notice(text: s.addedAtStore)
          else if (app.demoOrderPlaced) Notice(text: s.orderPlaced, fix: s.demoCheckout)
          else ...[
            FilledButton.icon(onPressed: app.addToCart, icon: const Icon(Icons.shopping_bag_outlined), label: Text(s.addBundle)),
            if (app.entry.storeOrigin == null) ...[const SizedBox(height: 8), Text(s.demoCheckout, style: t.bodySmall, textAlign: TextAlign.center)],
          ],
        ]),
      ),
      const SizedBox(height: 20),
      Center(child: TextButton.icon(onPressed: app.deletePhotos, icon: const Icon(Icons.delete_outline_rounded, size: 18), label: Text(s.deletePhotos))),
    ]);
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: 168,
        height: 168,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Tone.line, width: 4)),
        child: ClipOval(child: child),
      );
}
