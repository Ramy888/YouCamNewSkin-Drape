// Compare: the same piece in two colours on the buyer's body. The palette pick sits on the
// reading-start side (left in English, right in Arabic) because Row follows the text direction.
// Verdicts describe the garment ("Lifts your colouring"), never the skin.
//
// "Not sold yet" mode: when none of a garment's colours suit her, the reading-start side shows her own try-on re-made by
// YouCam AI Fabric in a fabric from her palette, beside the colour she would settle for, and she can ask the store for it.
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
    final p = app.product;
    final pair = app.comparePair;
    if (p == null || pair == null) return const SizedBox();
    if (app.notSold && p.suggestion != null) return _NotSold(app: app, product: p, settled: pair.pick, suggestion: p.suggestion!);
    final pickJob = app.tryons[pair.pick.id];
    final offJob = pair.off == null ? null : app.tryons[pair.off!.id];
    final note = [pickJob, offJob].whereType<Job>().where((j) => j.sample && j.note != null).map((j) => j.note!).firstOrNull;
    return DrapePage(maxWidth: 904, children: [
      StepHeader(eyebrow: s.stepOf(3), title: s.compareTitle, lead: '${p.name} · ${s.compareLead}'),
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
      const SizedBox(height: 28),
      Center(
        child: FilledButton.icon(
          onPressed: pickJob?.ok == true ? () => app.completeLook() : null,
          icon: Icon(forwardIcon(context)),
          label: Text(s.completeLook),
        ),
      ),
    ]);
  }
}

class CompareSide {
  const CompareSide({required this.colorway, this.job, this.imageUrl, this.verdict, this.verdictText, this.badge, this.swatchFallback});
  final Colorway colorway;
  final Job? job;
  final String? imageUrl;

  /// Defaults: the pick "lifts", the other side "fights".
  final Verdict? verdict;
  final String? verdictText;

  /// Small label over the image, e.g. "Not sold yet".
  final String? badge;

  /// Shown in place of the image when the render isn't available: a block of the colour with this text.
  final String? swatchFallback;
}

class _NotSold extends StatelessWidget {
  const _NotSold({required this.app, required this.product, required this.settled, required this.suggestion});
  final AppState app;
  final Product product;
  final Colorway settled;
  final FabricSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final settledJob = app.tryons[settled.id];
    final recolor = app.recolorJob;
    final fabric = Colorway(id: suggestion.template, name: s.colour(suggestion.name), hex: suggestion.hex, image: '', verdict: Verdict.yours);
    final note = [settledJob, recolor].whereType<Job>().where((j) => j.sample && j.note != null).map((j) => j.note!).firstOrNull;
    // The recolour only starts once her try-on exists; until then (or if it fails) the colour itself stands in.
    final recolorFailed = recolor != null && !recolor.ok;
    final settledFailed = settledJob != null && !settledJob.ok;
    return DrapePage(maxWidth: 904, children: [
      StepHeader(eyebrow: s.stepOf(3), title: s.notSoldTitle, lead: s.notSoldLead(product.name, s.colour(suggestion.name), s.colour(suggestion.closest.name))),
      if (note != null) ...[const SizedBox(height: 10), Notice(text: app.session?.persona == true ? note : s.sampleResult)],
      const SizedBox(height: 16),
      ComparePairView(
        s: s,
        pick: CompareSide(
          colorway: fabric,
          job: recolorFailed || settledFailed ? Job.unavailable() : recolor,
          imageUrl: recolor?.image == null ? null : app.api.abs(recolor!.image!),
          verdict: Verdict.yours,
          verdictText: s.closeToYour(s.colour(suggestion.closest.name)),
          badge: s.notSoldBadge,
          swatchFallback: s.previewUnavailable,
        ),
        off: CompareSide(
          colorway: settled,
          job: settledJob,
          imageUrl: settledJob?.image == null ? null : app.api.abs(settledJob!.image!),
          verdict: Verdict.neutral,
          verdictText: s.settledLabel,
        ),
        busyText: app.busy,
        onRetry: (_) => app.renderNotSold(),
      ),
      const SizedBox(height: 28),
      if (app.askedColour)
        Notice(text: s.askedStore)
      else
        Center(
          child: FilledButton.icon(
            onPressed: app.busy == null ? app.askForColour : null,
            icon: const Icon(Icons.storefront_outlined),
            label: Text(s.askStore(s.colour(suggestion.name))),
          ),
        ),
      const SizedBox(height: 12),
      Center(
        child: OutlinedButton(
          onPressed: settledJob?.ok == true ? () => app.completeLook() : null,
          child: Text(s.completeWith(s.colour(settled.name))),
        ),
      ),
    ]);
  }
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
      _Panel(key: const ValueKey('compare-pick'), side: pick, verdictText: pick.verdictText ?? s.liftsYou, verdict: pick.verdict ?? Verdict.yours, s: s, busyText: busyText, onRetry: onRetry),
      if (off != null)
        _Panel(key: const ValueKey('compare-off'), side: off!, verdictText: off!.verdictText ?? s.fightsYou, verdict: off!.verdict ?? Verdict.avoid, s: s, busyText: busyText, onRetry: onRetry),
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
  const _Panel({super.key, required this.side, required this.verdictText, required this.verdict, required this.s, this.busyText, this.onRetry});
  final CompareSide side;
  final String verdictText;
  final Verdict verdict;
  final S s;
  final String? busyText;
  final void Function(Colorway)? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final job = side.job;
    Widget body;
    if (job == null) {
      body = Center(child: Padding(padding: const EdgeInsets.all(12), child: Progress(text: s.dressing(s.colour(side.colorway.name)))));
    } else if (job.ok && side.imageUrl != null) {
      body = Image.network(side.imageUrl!, fit: BoxFit.cover, alignment: Alignment.topCenter, semanticLabel: '${s.colour(side.colorway.name)}: $verdictText');
    } else if (side.swatchFallback != null) {
      final colour = hexColor(side.colorway.hex);
      body = ColoredBox(
        color: colour,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(side.swatchFallback!, textAlign: TextAlign.center, style: t.bodyMedium?.copyWith(color: onSwatch(colour))),
          ),
        ),
      );
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
    return DrapeCard(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(fit: StackFit.expand, children: [
              ColoredBox(color: Tone.paperDeep, child: body),
              if (side.badge != null)
                PositionedDirectional(top: 8, start: 8, child: Tag(text: side.badge!, color: Colors.white, bg: Tone.mulberry, icon: Icons.auto_awesome_outlined)),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 18, height: 18, decoration: BoxDecoration(color: hexColor(side.colorway.hex), shape: BoxShape.circle, border: Border.all(color: Colors.black.withValues(alpha: 0.12)))),
              const SizedBox(width: 8),
              Expanded(child: Text(s.colour(side.colorway.name), style: t.titleMedium)),
            ]),
            const SizedBox(height: 8),
            VerdictLabel(verdict: verdict, s: s, text: verdictText),
          ]),
        ),
      ]),
    );
  }
}
