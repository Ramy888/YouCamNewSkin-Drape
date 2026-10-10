// "Your colours": the best drape vs the worst drape around the face, named swatches, metal, and the
// warmer/cooler override. The hijab-frame fallback is a coloured oval band around the face crop.
import 'package:flutter/material.dart';

import '../api.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final ses = app.session;
    final palette = ses?.palette;
    if (palette == null) {
      return DrapePage(maxWidth: 560, children: [
        const SizedBox(height: 40),
        if (app.busy != null) Center(child: Progress(text: app.busy!)),
        if (app.error != null)
          Notice(
            text: app.error!,
            fix: app.errorFix,
            error: true,
            action: TextButton(onPressed: () => app.go(FlowStep.face), child: Text(s.retry)),
          ),
      ]);
    }
    final face = app.api.abs(ses!.facePhoto ?? '/persona/face.jpg');
    final best = palette.suits.first;
    final worst = palette.avoid.isNotEmpty ? palette.avoid.first : null;
    final job = app.readingJob;
    return DrapePage(children: [
      Row(children: [
        Expanded(child: Text(s.yourColours, style: t.headlineSmall)),
        if (ses.persona) Text(s.sampleBadge, style: t.labelMedium?.copyWith(color: Tone.brass)),
      ]),
      const SizedBox(height: 4),
      Text('${s.undertone(palette.undertone)} · ${s.contrast(palette.contrast)}', style: t.bodyLarge),
      if (job?.sample == true && job?.note != null) ...[const SizedBox(height: 10), Notice(text: job!.note!)],
      const SizedBox(height: 20),
      Wrap(alignment: WrapAlignment.center, spacing: 28, runSpacing: 20, children: [
        DrapedFace(url: face, drapeHex: best.hex, label: '${best.name} · ${s.liftsYou}'),
        if (worst != null) DrapedFace(url: face, drapeHex: worst.hex, label: '${worst.name} · ${s.fightsYou}'),
      ]),
      const SizedBox(height: 24),
      Text(s.suitsLabel, style: t.titleMedium),
      const SizedBox(height: 10),
      Wrap(spacing: 18, runSpacing: 12, children: [for (final sw in palette.suits.take(8)) SwatchChip(name: sw.name, hex: sw.hex, size: 32)]),
      if (palette.avoid.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(s.avoidLabel, style: t.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 18, runSpacing: 12, children: [for (final sw in palette.avoid) SwatchChip(name: sw.name, hex: sw.hex, size: 28)]),
      ],
      const SizedBox(height: 20),
      Row(children: [
        Text('${s.metalLabel}: ', style: t.titleMedium),
        Text(s.metal(palette.metal), style: t.titleMedium?.copyWith(color: Tone.brass)),
      ]),
      const SizedBox(height: 20),
      _Override(app: app, palette: palette),
      const SizedBox(height: 24),
      FilledButton(onPressed: () => app.go(FlowStep.shop), child: Text(s.shopColours)),
      if (app.product != null) ...[
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => app.openCompare(app.product!, colorwayId: app.chosenColorwayId),
          child: Text('${s.tryOn}: ${app.product!.name}'),
        ),
      ],
    ]);
  }
}

class _Override extends StatelessWidget {
  const _Override({required this.app, required this.palette});
  final AppState app;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final current = app.session?.override;
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 6, children: [
      Text(s.notMe, style: Theme.of(context).textTheme.bodyLarge),
      for (final (value, label) in [('warmer', s.warmer), ('cooler', s.cooler)])
        ChoiceChip(
          label: Text(label),
          selected: current == value,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: app.busy != null ? null : (on) => app.setOverride(on ? value : null),
        ),
    ]);
  }
}
