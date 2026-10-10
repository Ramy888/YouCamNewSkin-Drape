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

/// The face photo inside a hijab-shaped drape of [drapeHex]: hood over the head, a wrap under the chin
/// and fabric falling to the shoulders, so the colour sits next to the face the way a hijab would.
class DrapedFace extends StatelessWidget {
  const DrapedFace({super.key, required this.url, required this.drapeHex, required this.label, this.size = 150});
  final String url;
  final String drapeHex;
  final String label;
  final double size;

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
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
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
