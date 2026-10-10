// Landing and photo capture.
import 'package:flutter/material.dart';

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
    return DrapePage(maxWidth: 640, children: [
      const SizedBox(height: 24),
      Text(s.landingTitle, style: t.displaySmall),
      const SizedBox(height: 16),
      Text(s.landingBody, style: t.bodyLarge),
      const SizedBox(height: 28),
      if (app.deleted) ...[Notice(text: s.deleted), const SizedBox(height: 16)],
      if (app.error != null) ...[Notice(text: app.error!, fix: app.errorFix, error: true), const SizedBox(height: 16)],
      FilledButton(onPressed: app.busy == null ? () => app.start(persona: true) : null, child: Text(s.trySample)),
      const SizedBox(height: 6),
      Text(s.sampleExplain, style: t.bodyMedium),
      const SizedBox(height: 18),
      OutlinedButton(onPressed: app.busy == null ? () => app.start(persona: false) : null, child: Text(s.usePhoto)),
      const SizedBox(height: 10),
      Text(s.privacy, style: t.bodyMedium),
    ]);
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
      Text(face ? s.faceTitle : s.bodyTitle, style: t.headlineSmall),
      const SizedBox(height: 8),
      if (!face) ...[Text(s.needBody, style: t.bodyLarge), const SizedBox(height: 4)],
      Text(face ? s.faceHint : s.bodyHint, style: t.bodyMedium),
      const SizedBox(height: 20),
      Center(child: _Guide(face: face)),
      const SizedBox(height: 20),
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
              if (p != null) await app.openCompare(p, colorwayId: app.chosenColorwayId);
            }
          },
          label: Text(s.takePhoto),
        ),
      const SizedBox(height: 12),
      Text(s.privacy, style: t.bodyMedium),
      if (face) ...[
        const SizedBox(height: 8),
        TextButton(onPressed: () => app.start(persona: true), child: Text(s.tryWithout)),
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
          border: Border.all(color: Tone.inkSoft, width: 2),
          borderRadius: face ? BorderRadius.all(Radius.elliptical(size.width, size.height)) : BorderRadius.circular(70),
        ),
        child: Icon(face ? Icons.face_outlined : Icons.accessibility_new, size: 64, color: Tone.inkSoft),
      ),
    );
  }
}
