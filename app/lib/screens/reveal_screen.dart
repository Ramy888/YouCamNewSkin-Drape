// "Your colours": the best drape vs the worst drape around the face, named swatches, metal, and the
// warmer/cooler override. The hijab-frame fallback is a coloured oval band around the face crop.
import 'package:flutter/material.dart';

import '../api.dart';
import '../l10n.dart';
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
      StepHeader(
        eyebrow: s.stepOf(1),
        title: s.yourColours,
        trailing: ses.persona ? Tag(text: s.sampleBadge, icon: Icons.person_outline_rounded) : null,
      ),
      Wrap(spacing: 8, runSpacing: 8, children: [
        Tag(text: s.undertone(palette.undertone), color: Tone.mulberry, bg: Tone.mulberrySoft),
        Tag(text: _cap(s.contrast(palette.contrast)), color: Tone.mulberry, bg: Tone.mulberrySoft),
        Tag(text: '${s.metalLabel}: ${s.metal(palette.metal)}', icon: Icons.diamond_outlined),
      ]),
      if (job?.sample == true && job?.note != null) ...[const SizedBox(height: 16), Notice(text: app.session?.persona == true ? job!.note! : s.sampleResult)],
      const SizedBox(height: 20),
      DrapeCard(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
        child: Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 32, runSpacing: 24, children: [
          _DrapeSide(face: face, swatch: best, verdict: Verdict.yours, text: s.liftsYou, s: s),
          if (worst != null) _DrapeSide(face: face, swatch: worst, verdict: Verdict.avoid, text: s.fightsYou, s: s),
        ]),
      ),
      const SizedBox(height: 16),
      DrapeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.suitsLabel, style: t.titleMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [for (final sw in palette.suits.take(8)) SwatchChip(name: sw.name, hex: sw.hex, size: 28, pill: true)]),
          if (palette.avoid.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(s.avoidLabel, style: t.titleMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [for (final sw in palette.avoid) SwatchChip(name: sw.name, hex: sw.hex, size: 24, pill: true)]),
          ],
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _Override(app: app, palette: palette),
        ]),
      ),
      const SizedBox(height: 24),
      Wrap(spacing: 12, runSpacing: 12, children: [
        FilledButton.icon(onPressed: () => app.go(FlowStep.shop), icon: Icon(forwardIcon(context)), label: Text(s.shopColours)),
        if (app.product != null)
          OutlinedButton(
            onPressed: () => app.openCompare(app.product!, colorwayId: app.chosenColorwayId),
            child: Text('${s.tryOn}: ${app.product!.name}'),
          ),
      ]),
    ]);
  }
}

class _DrapeSide extends StatelessWidget {
  const _DrapeSide({required this.face, required this.swatch, required this.verdict, required this.text, required this.s});
  final String face;
  final Swatch swatch;
  final Verdict verdict;
  final String text;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      DrapedFace(url: face, drapeHex: swatch.hex, label: '${swatch.name} · $text', showLabel: false),
      const SizedBox(height: 8),
      Text(swatch.name, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      VerdictLabel(verdict: verdict, s: s, text: text),
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

String _cap(String v) => v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);
