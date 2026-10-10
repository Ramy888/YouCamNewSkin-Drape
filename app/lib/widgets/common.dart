// Small shared pieces: swatch chips (always named, never colour-only), verdict labels,
// notice/error strips, and a framed photo.
import 'package:flutter/material.dart';

import '../api.dart';
import '../l10n.dart';
import '../theme.dart';

/// A colour swatch that always carries its name, so meaning never depends on colour alone.
class SwatchChip extends StatelessWidget {
  const SwatchChip({super.key, required this.name, required this.hex, this.size = 40});
  final String name;
  final String hex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: hexColor(hex), shape: BoxShape.circle, border: Border.all(color: Tone.line)),
        ),
        const SizedBox(width: 8),
        Text(name, style: Theme.of(context).textTheme.bodyLarge),
      ]),
    );
  }
}

/// Text label for a verdict. Colour is a second cue; the words carry the meaning.
class VerdictLabel extends StatelessWidget {
  const VerdictLabel({super.key, required this.verdict, required this.s});
  final Verdict? verdict;
  final S s;

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (verdict) {
      Verdict.yours => (s.verdictYours, Tone.yours, Icons.check),
      Verdict.avoid => (s.verdictAvoid, Tone.avoid, Icons.close),
      _ => (s.verdictNeutral, Tone.inkSoft, Icons.remove),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
    ]);
  }
}

class Notice extends StatelessWidget {
  const Notice({super.key, required this.text, this.fix, this.error = false, this.action});
  final String text;
  final String? fix;
  final bool error;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final color = error ? Tone.avoid : Tone.brass;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
        decoration: BoxDecoration(border: BorderDirectional(start: BorderSide(color: color, width: 3)), color: Tone.paperDeep),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text, style: Theme.of(context).textTheme.bodyLarge),
              if (fix != null) Text(fix!, style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
          ?action,
        ]),
      ),
    );
  }
}

class Progress extends StatelessWidget {
  const Progress({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: text,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Tone.mulberry)),
        const SizedBox(width: 12),
        Flexible(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
      ]),
    );
  }
}

/// A photo cropped to an oval, framed by a band of colour (the drape around the face).
class DrapedFace extends StatelessWidget {
  const DrapedFace({super.key, required this.url, required this.drapeHex, required this.label, this.size = 150});
  final String url;
  final String drapeHex;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: label,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size,
          height: size * 1.25,
          padding: EdgeInsets.all(size * 0.13),
          decoration: BoxDecoration(color: hexColor(drapeHex), borderRadius: BorderRadius.all(Radius.elliptical(size, size * 1.25))),
          child: ClipOval(child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Tone.paperDeep))),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
      ]),
    );
  }
}

/// Keeps content to a readable width and gives every screen the same side gutter.
class DrapePage extends StatelessWidget {
  const DrapePage({super.key, required this.children, this.maxWidth = 920});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}
