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
    final makeup = app.makeupJob;
    final makeupImage = makeup?.ok == true ? makeup!.image : null;
    final product = app.product!;
    return DrapePage(children: [
      Text(s.lookCard, style: t.headlineSmall),
      const SizedBox(height: 16),
      Wrap(spacing: 20, runSpacing: 20, crossAxisAlignment: WrapCrossAlignment.start, children: [
        if (outfit != null)
          SizedBox(width: 260, child: AspectRatio(aspectRatio: 3 / 4, child: Image.network(app.api.abs(outfit), fit: BoxFit.cover, alignment: Alignment.topCenter, semanticLabel: '${product.name}, ${pair.pick.name}'))),
        SizedBox(
          width: 280,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.matchingMakeup, style: t.titleMedium),
            const SizedBox(height: 8),
            if (app.busy != null && makeup == null) Progress(text: app.busy!),
            if (makeupImage != null)
              SizedBox(width: 200, height: 200, child: ClipOval(child: Image.network(app.api.abs(makeupImage), fit: BoxFit.cover, semanticLabel: s.matchingMakeup))),
            if (makeup != null && makeupImage == null) Notice(text: makeup.errorKind == 'unavailable' ? s.makeupUnavailable : makeup.errorMessage),
            const SizedBox(height: 12),
            Text(s.lipShade, style: t.bodyMedium),
            SwatchChip(name: palette.lip.name, hex: palette.lip.hex, size: 30),
            const SizedBox(height: 16),
            Text(s.metalLabel, style: t.bodyMedium),
            Text(s.metal(palette.metal), style: t.titleMedium?.copyWith(color: Tone.brass)),
          ]),
        ),
      ]),
      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Text('${product.name} · ${pair.pick.name}', style: t.bodyLarge)),
        Text('${product.price} ${product.currency}', style: t.titleMedium),
      ]),
      Text('${s.lipShade}: ${palette.lip.name} · ${s.metalLabel}: ${s.metal(palette.metal)}', style: t.bodyMedium),
      const SizedBox(height: 20),
      if (app.addedAtStore) Notice(text: s.addedAtStore)
      else if (app.demoOrderPlaced) Notice(text: s.orderPlaced, fix: s.demoCheckout)
      else ...[
        FilledButton(onPressed: app.addToCart, child: Text(s.addBundle)),
        if (app.entry.storeOrigin == null) ...[const SizedBox(height: 6), Text(s.demoCheckout, style: t.bodyMedium)],
      ],
      const SizedBox(height: 24),
      OutlinedButton(onPressed: app.deletePhotos, child: Text(s.deletePhotos)),
    ]);
  }
}
