// Visual system "atelier" (see DESIGN.md): warm ivory paper, white cards, near-black ink, aubergine
// for action and brand, brass for metal. Reem Kufi (display, covers Arabic and Latin) for headings;
// IBM Plex Sans Arabic carries body text in both languages.
import 'package:flutter/material.dart';

abstract final class Tone {
  static const paper = Color(0xFFF8F5F0);
  static const surface = Color(0xFFFFFFFF);
  static const paperDeep = Color(0xFFEFE9E1);
  static const ink = Color(0xFF1E1B22); // 15.6:1 on paper
  static const inkSoft = Color(0xFF5A5560); // 6.7:1 on paper
  static const line = Color(0xFFE3DBD0);
  static const mulberry = Color(0xFF5E2750); // 10.3:1 on paper
  static const mulberrySoft = Color(0xFFF3E8EF);
  static const brass = Color(0xFF7E6026); // 5.4:1 on paper
  static const yours = Color(0xFF1D6B46); // 5.6:1 on yoursSoft
  static const yoursSoft = Color(0xFFE4F1E9);
  static const avoid = Color(0xFFA0372A); // 5.7:1 on avoidSoft
  static const avoidSoft = Color(0xFFF8E6E2);
}

/// Soft two-layer card shadow.
const cardShadow = [
  BoxShadow(color: Color(0x0F1E1B22), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0D1E1B22), blurRadius: 24, offset: Offset(0, 8)),
];

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
      secondaryContainer: Tone.mulberrySoft,
      onSecondaryContainer: Tone.mulberry,
      surface: Tone.paper,
      onSurface: Tone.ink,
      outline: Tone.line,
    ),
    scaffoldBackgroundColor: Tone.paper,
  );
  final t = base.textTheme;
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  return base.copyWith(
    textTheme: t.copyWith(
      displaySmall: t.displaySmall?.copyWith(fontFamily: _display, fontWeight: FontWeight.w600, color: Tone.ink, height: 1.12, fontSize: 40),
      headlineSmall: t.headlineSmall?.copyWith(fontFamily: _display, fontWeight: FontWeight.w600, color: Tone.ink, height: 1.2, fontSize: 26),
      titleLarge: t.titleLarge?.copyWith(fontFamily: _display, fontWeight: FontWeight.w600, color: Tone.ink, fontSize: 22),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Tone.ink, fontSize: 18),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 17, height: 1.55, color: Tone.ink),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 16, height: 1.5, color: Tone.inkSoft),
      bodySmall: t.bodySmall?.copyWith(fontSize: 14, height: 1.45, color: Tone.inkSoft),
      labelLarge: t.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: t.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: Tone.inkSoft),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Tone.paper,
      foregroundColor: Tone.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Tone.mulberry,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Tone.paperDeep,
        disabledForegroundColor: Tone.inkSoft,
        textStyle: const TextStyle(fontFamily: _body, fontSize: 16, fontWeight: FontWeight.w600),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        foregroundColor: Tone.ink,
        backgroundColor: Tone.surface,
        textStyle: const TextStyle(fontFamily: _body, fontSize: 16, fontWeight: FontWeight.w600),
        side: const BorderSide(color: Tone.line, width: 1.2),
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: Tone.mulberry,
        textStyle: const TextStyle(fontFamily: _body, fontSize: 15, fontWeight: FontWeight.w600),
        shape: buttonShape,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Tone.surface,
      selectedColor: Tone.mulberrySoft,
      side: const BorderSide(color: Tone.line),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(fontFamily: _body, fontSize: 15, fontWeight: FontWeight.w500, color: Tone.ink),
      checkmarkColor: Tone.mulberry,
    ),
    focusColor: Tone.mulberry.withValues(alpha: 0.16),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Tone.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Tone.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Tone.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Tone.mulberry, width: 2)),
      labelStyle: const TextStyle(color: Tone.inkSoft),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedColor: Tone.mulberry,
      selectedTileColor: Tone.mulberrySoft,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Tone.mulberry, linearTrackColor: Tone.paperDeep),
    dividerTheme: const DividerThemeData(color: Tone.line, thickness: 1, space: 1),
  );
}
