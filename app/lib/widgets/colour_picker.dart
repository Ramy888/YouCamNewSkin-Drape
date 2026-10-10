// Seller colour picker: a palette of named garment colours, plus hue/saturation/brightness sliders for
// anything else. Returns the hex and, for palette picks, a name the seller can keep or change.
import 'package:flutter/material.dart';

import '../theme.dart';

/// Named garment colours common in modest fashion. Names are what the buyer sees.
const garmentPalette = <(String, String)>[
  ('Black', '#1c1c1e'), ('Charcoal', '#3a3d44'), ('Grey', '#8e9196'), ('Navy', '#1f2f5a'),
  ('Sapphire', '#24479a'), ('Icy blue', '#a9c6e8'), ('Deep teal', '#1f5f63'), ('Aqua', '#4ab8b5'),
  ('Emerald', '#1f7a55'), ('Jade', '#2e8b6e'), ('Olive', '#6b7a3a'), ('Sage', '#9caf88'),
  ('Mustard', '#c99a2e'), ('Saffron', '#deaa4b'), ('Camel', '#b98a5a'), ('Taupe', '#8b7d70'),
  ('Beige', '#d8c3a5'), ('Cream', '#efe3c8'), ('Off white', '#f1ede4'), ('White', '#f7f8fa'),
  ('Terracotta', '#b8603e'), ('Rust', '#a4462a'), ('Tomato red', '#c0392b'), ('Cherry red', '#b0173a'),
  ('Burgundy', '#6d1a2b'), ('Berry', '#8e2a52'), ('Plum', '#6e3b5a'), ('Dusty rose', '#c4868e'),
  ('Blush pink', '#ed9ece'), ('Fuchsia', '#c2185b'), ('Lavender', '#b7a6d8'), ('Lilac', '#c8a2c8'),
];

String toHex(Color c) {
  String two(double v) => (v * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  return '#${two(c.r)}${two(c.g)}${two(c.b)}';
}

/// Opens the picker. Resolves to (hex, name) or null when cancelled; name is null for custom colours.
Future<(String, String?)?> pickColour(BuildContext context, {String? initialHex}) =>
    showDialog<(String, String?)>(context: context, builder: (_) => _ColourPickerDialog(initialHex: initialHex));

class _ColourPickerDialog extends StatefulWidget {
  const _ColourPickerDialog({this.initialHex});
  final String? initialHex;

  @override
  State<_ColourPickerDialog> createState() => _ColourPickerDialogState();
}

class _ColourPickerDialogState extends State<_ColourPickerDialog> {
  static final _hexRe = RegExp(r'^#[0-9a-fA-F]{6}$');
  late HSVColor _hsv = HSVColor.fromColor(_hexRe.hasMatch(widget.initialHex ?? '') ? hexColor(widget.initialHex!) : hexColor('#1f7a55'));
  late String? _name = garmentPalette.where((c) => c.$2 == widget.initialHex?.toLowerCase()).map((c) => c.$1).firstOrNull;

  void _choose((String, String) c) => setState(() {
        _hsv = HSVColor.fromColor(hexColor(c.$2));
        _name = c.$1;
      });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final colour = _hsv.toColor();
    final hex = toHex(colour);
    Widget slider(String label, double value, double max, ValueChanged<double> onChanged, List<Color> track) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.labelMedium),
            SizedBox(
              height: 44,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.black12), gradient: LinearGradient(colors: track)),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 14,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    overlayColor: Tone.mulberry.withValues(alpha: 0.12),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11, elevation: 3),
                  ),
                  child: Slider(
                    value: value,
                    max: max,
                    semanticFormatterCallback: (v) => '$label ${(v / max * 100).round()}%',
                    onChanged: (v) => setState(() {
                      onChanged(v);
                      _name = null;
                    }),
                  ),
                ),
              ]),
            ),
          ],
        );
    return Dialog(
      backgroundColor: Tone.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Text('Pick a colour', style: t.headlineSmall),
            const SizedBox(height: 4),
            Text('Choose the closest garment colour, or fine-tune it below. Drape matches buyers against this colour.', style: t.bodySmall),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in garmentPalette)
                Tooltip(
                  message: c.$1,
                  child: Semantics(
                    button: true,
                    selected: _name == c.$1,
                    label: c.$1,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _choose(c),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: hexColor(c.$2),
                          shape: BoxShape.circle,
                          border: Border.all(color: _name == c.$1 ? Tone.mulberry : Colors.black12, width: _name == c.$1 ? 3 : 1),
                        ),
                        child: _name == c.$1 ? Icon(Icons.check_rounded, color: onSwatch(hexColor(c.$2)), size: 20) : null,
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            slider('HUE', _hsv.hue, 360, (v) => _hsv = _hsv.withHue(v),
                [for (var h = 0; h <= 360; h += 60) HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor()]),
            slider('SATURATION', _hsv.saturation, 1, (v) => _hsv = _hsv.withSaturation(v),
                [_hsv.withSaturation(0).toColor(), _hsv.withSaturation(1).toColor()]),
            slider('BRIGHTNESS', _hsv.value, 1, (v) => _hsv = _hsv.withValue(v),
                [_hsv.withValue(0).toColor(), _hsv.withValue(1).toColor()]),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: colour, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_name ?? 'Custom colour', style: t.titleMedium),
                  Text(hex, style: t.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(onPressed: () => Navigator.pop(context, (hex, _name)), child: const Text('Use this colour')),
            ]),
          ]),
        ),
      ),
    );
  }
}
