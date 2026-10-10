// Small shared pieces: swatch chips (always named, never colour-only), verdict labels,
// notice/error strips, and a framed photo.
import 'package:flutter/material.dart';

import '../api.dart';
import '../l10n.dart';
import '../theme.dart';

/// A colour swatch that always carries its name, so meaning never depends on colour alone.
class SwatchChip extends StatelessWidget {
  const SwatchChip({super.key, required this.name, required this.hex, this.size = 40, this.pill = false});
  final String name;
  final String hex;
  final double size;
  /// Draw the swatch and name inside a bordered pill (palette lists); plain otherwise (rows, cards).
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final row = Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: hexColor(hex),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
      ),
      const SizedBox(width: 10),
      Flexible(child: Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
    ]);
    return Semantics(
      label: name,
      child: pill
          ? Container(
              padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 16, 6),
              decoration: BoxDecoration(color: Tone.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: Tone.line)),
              child: row,
            )
          : row,
    );
  }
}

/// Text label for a verdict on a tinted pill. Colour is a second cue; the words carry the meaning.
class VerdictLabel extends StatelessWidget {
  const VerdictLabel({super.key, required this.verdict, required this.s, this.text});
  final Verdict? verdict;
  final S s;
  /// Overrides the default verdict word (e.g. "Lifts your colouring" on Compare).
  final String? text;

  @override
  Widget build(BuildContext context) {
    final (word, color, bg, icon) = switch (verdict) {
      Verdict.yours => (s.verdictYours, Tone.yours, Tone.yoursSoft, Icons.check_rounded),
      Verdict.avoid => (s.verdictAvoid, Tone.avoid, Tone.avoidSoft, Icons.close_rounded),
      _ => (s.verdictNeutral, Tone.inkSoft, Tone.paperDeep, Icons.remove_rounded),
    };
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 12, 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(child: Text(text ?? word, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, letterSpacing: 0.2, fontSize: 14))),
      ]),
    );
  }
}

/// White card with a hairline border and soft shadow: the basic container on every screen.
class DrapeCard extends StatelessWidget {
  const DrapeCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.color = Tone.surface, this.expand = false});
  final Widget child;
  /// Fill the parent's height (equal-height tiles).
  final bool expand;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      height: expand ? double.infinity : null,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), border: Border.all(color: Tone.line), boxShadow: cardShadow),
      child: child,
    );
  }
}

/// Eyebrow + headline + optional lead, the opening of every buyer screen.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, this.eyebrow, required this.title, this.lead, this.trailing});
  final String? eyebrow;
  final String title;
  final String? lead;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: t.labelMedium?.copyWith(color: Tone.mulberry, letterSpacing: 1.4)),
          const SizedBox(height: 8),
        ],
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(title, style: t.headlineSmall?.copyWith(fontSize: 30))),
          ?trailing,
        ]),
        if (lead != null) ...[const SizedBox(height: 8), Text(lead!, style: t.bodyLarge?.copyWith(color: Tone.inkSoft))],
      ]),
    );
  }
}

/// Small label pill, e.g. "Sample person" or "Live".
class Tag extends StatelessWidget {
  const Tag({super.key, required this.text, this.color = Tone.brass, this.bg = const Color(0xFFF4ECDC), this.icon});
  final String text;
  final Color color;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
        Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, letterSpacing: 0.3)),
      ]),
    );
  }
}

/// The Drape mark: an aubergine tile with a drape fold, plus the wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.suffix, this.onDark = false});
  final String? suffix;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ink = onDark ? Colors.white : Tone.ink;
    return Semantics(
      label: suffix == null ? 'Drape' : 'Drape $suffix',
      child: ExcludeSemantics(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: onDark ? Colors.white : Tone.mulberry, borderRadius: BorderRadius.circular(8)),
            child: CustomPaint(painter: _FoldPainter(onDark ? Tone.mulberry : Colors.white)),
          ),
          const SizedBox(width: 10),
          Text('Drape', style: t.headlineSmall?.copyWith(fontSize: 22, color: ink)),
          if (suffix != null) ...[
            const SizedBox(width: 10),
            Container(width: 1, height: 18, color: onDark ? Colors.white24 : Tone.line),
            const SizedBox(width: 10),
            Flexible(child: Text(suffix!, overflow: TextOverflow.ellipsis, maxLines: 1, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: onDark ? Colors.white70 : Tone.inkSoft, fontSize: 16))),
          ],
        ]),
      ),
    );
  }
}

class _FoldPainter extends CustomPainter {
  _FoldPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // A hood outline with one fold: reads as fabric framing a face.
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.28, s.height * 0.80)
        ..cubicTo(s.width * 0.22, s.height * 0.45, s.width * 0.30, s.height * 0.20, s.width * 0.50, s.height * 0.20)
        ..cubicTo(s.width * 0.70, s.height * 0.20, s.width * 0.78, s.height * 0.45, s.width * 0.72, s.height * 0.80),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.42, s.height * 0.80)
        ..quadraticBezierTo(s.width * 0.40, s.height * 0.52, s.width * 0.50, s.height * 0.40),
      p,
    );
  }

  @override
  bool shouldRepaint(_FoldPainter old) => old.color != color;
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
    final bg = error ? Tone.avoidSoft : const Color(0xFFF6F0E4);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(error ? Icons.error_outline_rounded : Icons.info_outline_rounded, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
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

/// The face photo inside a hijab-shaped drape of [drapeHex]: hood over the head, a wrap under the chin
/// and fabric falling to the shoulders, so the colour sits next to the face the way a hijab would.
class DrapedFace extends StatelessWidget {
  const DrapedFace({super.key, required this.url, required this.drapeHex, required this.label, this.size = 150, this.showLabel = true});
  final String url;
  final String drapeHex;
  final String label;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final w = size * 1.3, h = size * 1.6;
    final face = HijabGeometry.face(Size(w, h));
    final colour = hexColor(drapeHex);
    return Semantics(
      image: true,
      label: label,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: w,
          height: h,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _HijabPainter(colour, front: false))),
            Positioned.fromRect(
              rect: face,
              child: ClipOval(child: Image.network(url, fit: BoxFit.cover, alignment: const Alignment(0, -0.2), errorBuilder: (_, _, _) => const ColoredBox(color: Tone.paperDeep))),
            ),
            Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _HijabPainter(colour, front: true)))),
          ]),
        ),
        if (showLabel) ...[const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)],
      ]),
    );
  }
}

/// Shared proportions of the hijab drape, relative to the painted box.
class HijabGeometry {
  static Rect face(Size s) => Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.40), width: s.width * 0.54, height: s.height * 0.48);

  static Path back(Size s) {
    double x(double v) => v * s.width;
    double y(double v) => v * s.height;
    return Path()
      ..moveTo(x(0.5), y(0.03))
      ..cubicTo(x(0.92), y(0.03), x(0.97), y(0.42), x(0.86), y(0.64))
      ..cubicTo(x(0.96), y(0.74), x(1.0), y(0.86), x(1.0), y(0.99))
      ..quadraticBezierTo(x(0.5), y(0.95), x(0.0), y(0.99))
      ..cubicTo(x(0.0), y(0.86), x(0.04), y(0.74), x(0.14), y(0.64))
      ..cubicTo(x(0.03), y(0.42), x(0.08), y(0.03), x(0.5), y(0.03))
      ..close();
  }

  /// The wrap that passes under the chin, drawn in front of the photo's lower edge.
  static Path chinWrap(Size s) {
    double x(double v) => v * s.width;
    double y(double v) => v * s.height;
    // A soft band that starts and ends behind the face edge and dips under the chin.
    return Path()
      ..moveTo(x(0.25), y(0.56))
      ..cubicTo(x(0.30), y(0.70), x(0.70), y(0.70), x(0.75), y(0.56))
      ..cubicTo(x(0.76), y(0.62), x(0.72), y(0.72), x(0.5), y(0.73))
      ..cubicTo(x(0.28), y(0.72), x(0.24), y(0.62), x(0.25), y(0.56))
      ..close();
  }
}

class _HijabPainter extends CustomPainter {
  _HijabPainter(this.colour, {required this.front});
  final Color colour;
  final bool front;

  Color _shade(double dl) {
    final hsl = HSLColor.fromColor(colour);
    return hsl.withLightness((hsl.lightness + dl).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!front) {
      final back = HijabGeometry.back(size);
      canvas.drawPath(back, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_shade(0.04), colour, _shade(-0.08)]).createShader(Offset.zero & size));
      // A few soft folds so it reads as fabric, not a flat shape.
      final fold = Paint()
        ..color = _shade(-0.14).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012
        ..strokeCap = StrokeCap.round;
      for (final (x0, x1) in [(0.18, 0.08), (0.30, 0.24), (0.70, 0.76), (0.82, 0.92)]) {
        canvas.drawPath(
          Path()
            ..moveTo(size.width * x0, size.height * 0.70)
            ..quadraticBezierTo(size.width * (x0 + x1) / 2, size.height * 0.84, size.width * x1, size.height * 0.97),
          fold,
        );
      }
      // Inner edge around the face: the fabric's shadow.
      canvas.drawOval(HijabGeometry.face(size).inflate(size.width * 0.012), Paint()..color = _shade(-0.18));
      return;
    }
    final wrap = HijabGeometry.chinWrap(size);
    canvas.drawPath(wrap, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_shade(-0.06), _shade(0.03)]).createShader(Offset.zero & size));
    canvas.drawPath(wrap, Paint()..color = _shade(-0.2).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_HijabPainter old) => old.colour != colour || old.front != front;
}

/// Keeps content to a readable width and gives every screen the same side gutter.
class DrapePage extends StatelessWidget {
  const DrapePage({super.key, required this.children, this.maxWidth = 920});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

/// A "forward" arrow that points the reading direction (right in English, left in Arabic).
IconData forwardIcon(BuildContext context, {bool chevron = false}) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  if (chevron) return rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
  return rtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded;
}
