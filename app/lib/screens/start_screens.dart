// Landing and photo capture.
import 'package:flutter/material.dart';

import '../api.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final actions = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (app.deleted) ...[Notice(text: s.deleted), const SizedBox(height: 16)],
      if (app.error != null) ...[Notice(text: app.error!, fix: app.errorFix, error: true), const SizedBox(height: 16)],
      FilledButton(onPressed: app.busy == null ? () => app.start(persona: true) : null, child: Text(s.trySample)),
      const SizedBox(height: 8),
      Text(s.sampleExplain, style: t.bodySmall),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: app.busy == null && app.live == true ? () => app.start(persona: false) : null, child: Text(s.usePhoto)),
      if (app.live == false) ...[const SizedBox(height: 10), Notice(text: s.liveOff)],
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.lock_outline_rounded, size: 16, color: Tone.inkSoft),
        const SizedBox(width: 6),
        Expanded(child: Text(s.privacy, style: t.bodySmall)),
      ]),
    ]);
    final intro = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.landingEyebrow.toUpperCase(), style: t.labelMedium?.copyWith(color: Tone.mulberry, letterSpacing: 1.4)),
      const SizedBox(height: 12),
      Text(s.landingTitle, style: t.displaySmall),
      const SizedBox(height: 16),
      Text(s.landingBody, style: t.bodyLarge?.copyWith(color: Tone.inkSoft)),
      const SizedBox(height: 28),
      actions,
    ]);
    return DrapePage(maxWidth: 1040, children: [
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 760;
        final hero = _HeroCard(app: app);
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 11, child: intro), const SizedBox(width: 48), Expanded(flex: 10, child: hero)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [intro, const SizedBox(height: 32), hero]);
      }),
      const SizedBox(height: 40),
      LayoutBuilder(builder: (context, c) {
        final steps = [
          (Icons.face_retouching_natural_outlined, s.how1Title, s.how1Body),
          (Icons.compare_outlined, s.how2Title, s.how2Body),
          (Icons.shopping_bag_outlined, s.how3Title, s.how3Body),
        ];
        final cards = [
          for (var i = 0; i < steps.length; i++)
            DrapeCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Tone.mulberrySoft, borderRadius: BorderRadius.circular(10)),
                    child: Icon(steps[i].$1, color: Tone.mulberry, size: 22),
                  ),
                  const Spacer(),
                  Text('0${i + 1}', style: t.titleMedium?.copyWith(color: Tone.line, fontSize: 22)),
                ]),
                const SizedBox(height: 14),
                Text(steps[i].$2, style: t.titleMedium),
                const SizedBox(height: 4),
                Text(steps[i].$3, style: t.bodyMedium),
              ]),
            ),
        ];
        return c.maxWidth > 760
            ? IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < cards.length; i++) ...[if (i > 0) const SizedBox(width: 16), Expanded(child: cards[i])],
                ]),
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < cards.length; i++) ...[if (i > 0) const SizedBox(height: 12), cards[i]],
              ]);
      }),
      const SizedBox(height: 24),
      Center(child: Text(s.poweredBy, style: t.bodySmall)),
    ]);
  }
}

/// The product in one picture: the sample face in the colour that lifts it beside the one that fights it.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final face = app.api.abs('/persona/face.jpg');
    return DrapeCard(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Flexible(
            child: Column(children: [
              DrapedFace(url: face, drapeHex: '#1f7a55', label: '${s.verdictYours}: Emerald', size: 110, showLabel: false),
              const SizedBox(height: 10),
              VerdictLabel(verdict: Verdict.yours, s: s, text: s.liftsYou),
            ]),
          ),
          Flexible(
            child: Column(children: [
              DrapedFace(url: face, drapeHex: '#b7a6d8', label: '${s.verdictAvoid}: Lavender', size: 110, showLabel: false),
              const SizedBox(height: 10),
              VerdictLabel(verdict: Verdict.avoid, s: s, text: s.fightsYou),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Tag(text: s.sampleBadge, icon: Icons.person_outline_rounded),
      ]),
    );
  }
}

/// Face photo (first step) or full-body photo (asked at the first try-on in live sessions).
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key, required this.app, required this.kind});
  final AppState app;
  final String kind; // face | body

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final t = Theme.of(context).textTheme;
    final face = kind == 'face';
    return DrapePage(maxWidth: 560, children: [
      StepHeader(eyebrow: face ? s.how1Title : s.stepOf(3), title: face ? s.faceTitle : s.bodyTitle, lead: face ? s.faceHint : '${s.needBody} ${s.bodyHint}'),
      DrapeCard(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: _Guide(face: face)),
          const SizedBox(height: 24),
          if (app.error != null) ...[Notice(text: app.error!, fix: app.errorFix, error: true), const SizedBox(height: 12)],
          if (app.busy != null) Center(child: Progress(text: app.busy!)) else
            FilledButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: () async {
                final ok = await app.addPhoto(kind);
                if (!ok) return;
                if (face) {
                  app.go(FlowStep.reveal);
                  await app.readColours();
                } else {
                  final p = app.product;
                  if (p != null) await (app.notSold ? app.openRecolor(p) : app.openCompare(p, colorwayId: app.chosenColorwayId));
                }
              },
              label: Text(s.takePhoto),
            ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.lock_outline_rounded, size: 16, color: Tone.inkSoft),
            const SizedBox(width: 6),
            Expanded(child: Text(s.privacy, style: t.bodySmall)),
          ]),
        ]),
      ),
      if (face) ...[
        const SizedBox(height: 12),
        Center(child: TextButton(onPressed: () => app.start(persona: true), child: Text(s.tryWithout))),
      ],
    ]);
  }
}

class _Guide extends StatelessWidget {
  const _Guide({required this.face});
  final bool face;

  @override
  Widget build(BuildContext context) {
    final size = face ? const Size(180, 230) : const Size(150, 300);
    return ExcludeSemantics(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Tone.paper,
          border: Border.all(color: Tone.mulberry.withValues(alpha: 0.5), width: 2),
          borderRadius: face ? BorderRadius.all(Radius.elliptical(size.width, size.height)) : BorderRadius.circular(70),
        ),
        child: Icon(face ? Icons.face_outlined : Icons.accessibility_new, size: 64, color: Tone.mulberry.withValues(alpha: 0.6)),
      ),
    );
  }
}
