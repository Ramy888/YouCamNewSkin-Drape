// Compare: the same piece in two colours on the buyer's body. The palette pick sits on the
// reading-start side (left in English, right in Arabic) because Row follows the text direction.
// Verdicts describe the garment ("Lifts your colouring"), never the skin.
import 'package:flutter/material.dart';

import '../api.dart';
import '../l10n.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final p = app.product;
    final pair = app.comparePair;
    if (p == null || pair == null) return const SizedBox();
    final pickJob = app.tryons[pair.pick.id];
    final offJob = pair.off == null ? null : app.tryons[pair.off!.id];
    final note = [pickJob, offJob].whereType<Job>().where((j) => j.sample && j.note != null).map((j) => j.note!).firstOrNull;
    return DrapePage(maxWidth: 1000, children: [
      Text(s.compareTitle, style: t.headlineSmall),
      Text(p.name, style: t.bodyLarge),
      if (note != null) ...[const SizedBox(height: 10), Notice(text: app.session?.persona == true ? note : s.sampleResult)],
      if (pair.off == null) ...[const SizedBox(height: 10), Notice(text: s.noOffPalette)],
      const SizedBox(height: 16),
      ComparePairView(
        s: s,
        pick: CompareSide(colorway: pair.pick, job: pickJob, imageUrl: pickJob?.image == null ? null : app.api.abs(pickJob!.image!)),
        off: pair.off == null
            ? null
            : CompareSide(colorway: pair.off!, job: offJob, imageUrl: offJob?.image == null ? null : app.api.abs(offJob!.image!)),
        busyText: app.busy,
        onRetry: (c) => app.renderTryon(c),
      ),
      const SizedBox(height: 24),
      FilledButton(onPressed: pickJob?.ok == true ? () => app.completeLook() : null, child: Text(s.completeLook)),
    ]);
  }
}

class CompareSide {
  const CompareSide({required this.colorway, this.job, this.imageUrl});
  final Colorway colorway;
  final Job? job;
  final String? imageUrl;
}

class ComparePairView extends StatelessWidget {
  const ComparePairView({super.key, required this.s, required this.pick, this.off, this.busyText, this.onRetry});
  final S s;
  final CompareSide pick;
  final CompareSide? off;
  final String? busyText;
  final void Function(Colorway)? onRetry;

  @override
  Widget build(BuildContext context) {
    final panels = [
      _Panel(key: const ValueKey('compare-pick'), side: pick, verdictText: s.liftsYou, good: true, s: s, busyText: busyText, onRetry: onRetry),
      if (off != null) _Panel(key: const ValueKey('compare-off'), side: off!, verdictText: s.fightsYou, good: false, s: s, busyText: busyText, onRetry: onRetry),
    ];
    return LayoutBuilder(builder: (context, c) {
      final narrow = c.maxWidth < 520 && panels.length > 1;
      final w = narrow ? (c.maxWidth - 12) / 2 : (panels.length == 1 ? 360.0 : ((c.maxWidth - 24) / 2).clamp(0, 440).toDouble());
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < panels.length; i++) ...[
            if (i > 0) SizedBox(width: narrow ? 12 : 24),
            SizedBox(width: w, child: panels[i]),
          ],
        ],
      );
    });
  }
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.side, required this.verdictText, required this.good, required this.s, this.busyText, this.onRetry});
  final CompareSide side;
  final String verdictText;
  final bool good;
  final S s;
  final String? busyText;
  final void Function(Colorway)? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final job = side.job;
    final color = good ? Tone.yours : Tone.avoid;
    Widget body;
    if (job == null) {
      body = Center(child: Padding(padding: const EdgeInsets.all(12), child: Progress(text: s.dressing(side.colorway.name))));
    } else if (job.ok && side.imageUrl != null) {
      body = Image.network(side.imageUrl!, fit: BoxFit.cover, alignment: Alignment.topCenter, semanticLabel: '${side.colorway.name}: $verdictText');
    } else {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(job.errorKind == 'unavailable' ? s.notRecorded : s.jobError(job.errorCode, job.errorMessage), textAlign: TextAlign.center, style: t.bodyMedium),
            if (job.retryable || job.errorKind != 'unavailable')
              TextButton(onPressed: onRetry == null ? null : () => onRetry!(side.colorway), child: Text(s.retry)),
          ]),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AspectRatio(aspectRatio: 3 / 4, child: ColoredBox(color: Tone.paperDeep, child: body)),
      const SizedBox(height: 10),
      Row(children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: hexColor(side.colorway.hex), shape: BoxShape.circle, border: Border.all(color: Tone.line))),
        const SizedBox(width: 8),
        Expanded(child: Text(side.colorway.name, style: t.titleMedium)),
      ]),
      Text(verdictText, style: t.labelLarge?.copyWith(color: color)),
    ]);
  }
}
