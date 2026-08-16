import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildGiftPathTheme() {
  const seed = Color(0xFF2D5A4A);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: seed,
    secondary: const Color(0xFFB86B4B),
    tertiary: const Color(0xFF4D6F9F),
    surface: const Color(0xFFFFFCF7),
  );

  final textTheme = GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.newsreader(fontSize: 64, fontWeight: FontWeight.w700, height: 0.96),
    displayMedium: GoogleFonts.newsreader(fontSize: 46, fontWeight: FontWeight.w700, height: 1.02),
    headlineMedium: GoogleFonts.newsreader(fontSize: 34, fontWeight: FontWeight.w700),
    titleLarge: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w700),
    bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.55),
  );

  return ThemeData(
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFFF8F5EF),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: seed.withOpacity(0.10)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: seed.withOpacity(0.28)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    ),
    useMaterial3: true,
  );
}
