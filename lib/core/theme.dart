import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildGiftPathTheme() {
  const seed = Color(0xFF1E3025);
  const gold = Color(0xFFB7882E);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: seed,
    secondary: gold,
    tertiary: const Color(0xFF6E7F68),
    surface: const Color(0xFFFFFCF7),
  );

  final textTheme = GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.newsreader(
        fontSize: 64, fontWeight: FontWeight.w700, height: 0.96),
    displayMedium: GoogleFonts.newsreader(
        fontSize: 46, fontWeight: FontWeight.w700, height: 1.02),
    headlineMedium:
        GoogleFonts.newsreader(fontSize: 34, fontWeight: FontWeight.w700),
    titleLarge: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w700),
    bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.55),
  );

  return ThemeData(
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFFF6F0E6),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFFFFFCF7).withValues(alpha: .94),
      foregroundColor: const Color(0xFF17221D),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF17221D),
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: seed.withValues(alpha: 0.10)),
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
        side: BorderSide(color: seed.withValues(alpha: 0.28)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: seed.withValues(alpha: .24)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: seed, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: seed.withValues(alpha: .14)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: seed,
      unselectedLabelColor: Color(0xFF4C5852),
      indicatorColor: seed,
      labelStyle: TextStyle(fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: seed,
      linearTrackColor: seed.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(999),
    ),
    useMaterial3: true,
  );
}
