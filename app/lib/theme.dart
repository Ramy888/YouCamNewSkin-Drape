// Visual system: a pale sage "fitting-room paper" ground, deep green-black ink, mulberry for action,
// and brass for metal. Reem Kufi (display, covers Arabic and Latin) is used sparingly for headings;
// IBM Plex Sans Arabic carries body text in both languages.
import 'package:flutter/material.dart';

abstract final class Tone {
  static const paper = Color(0xFFF1F2EC);
  static const paperDeep = Color(0xFFE3E7DE);
  static const ink = Color(0xFF1D2723);
  static const inkSoft = Color(0xFF46544D); // 7.6:1 on paper
  static const line = Color(0xFFC6CEC3);
  static const mulberry = Color(0xFF7B2D43); // 8.4:1 on paper
  static const brass = Color(0xFF7A5D24); // 5.3:1 on paper
  static const yours = Color(0xFF1F5A40);
  static const avoid = Color(0xFF8A3427);
}

const _body = 'Plex Arabic';
const _display = 'Reem Kufi';

Color hexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

/// Text colour that stays readable on a swatch of [bg].
Color onSwatch(Color bg) => bg.computeLuminance() > 0.4 ? Tone.ink : Colors.white;

ThemeData drapeTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: _body,
    colorScheme: ColorScheme.fromSeed(seedColor: Tone.mulberry, surface: Tone.paper).copyWith(
      primary: Tone.mulberry,
      onPrimary: Colors.white,
      surface: Tone.paper,
      onSurface: Tone.ink,
      outline: Tone.line,
    ),
    scaffoldBackgroundColor: Tone.paper,
  );
  final t = base.textTheme;
  return base.copyWith(
    textTheme: t.copyWith(
      displaySmall: t.displaySmall?.copyWith(fontFamily: _display, fontWeight: FontWeight.w600, color: Tone.ink, height: 1.15, fontSize: 34),
      headlineSmall: t.headlineSmall?.copyWith(fontFamily: _display, fontWeight: FontWeight.w600, color: Tone.ink, fontSize: 24),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Tone.ink, fontSize: 18),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 17, height: 1.5, color: Tone.ink),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 16, height: 1.45, color: Tone.inkSoft),
      labelLarge: t.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium: t.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.6),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Tone.paper, foregroundColor: Tone.ink, elevation: 0, scrolledUnderElevation: 0, centerTitle: false),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Tone.mulberry,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        foregroundColor: Tone.ink,
        side: const BorderSide(color: Tone.ink, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: Tone.mulberry)),
    focusColor: Tone.mulberry.withValues(alpha: 0.18),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Tone.mulberry, width: 2)),
    ),
    dividerTheme: const DividerThemeData(color: Tone.line, thickness: 1, space: 1),
  );
}
