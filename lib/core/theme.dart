import 'package:flutter/material.dart';

abstract final class BrandTokens {
  static const forest = Color(0xFF24392C);
  static const forestDeep = Color(0xFF16261B);
  static const gold = Color(0xFFC6A046);
  static const goldBright = Color(0xFFD8B968);
  static const cream = Color(0xFFF3ECDF);
  static const creamDim = Color(0xFFEBE2D0);
  static const surface = Color(0xFFFFFCF7);
  static const ink = Color(0xFF17181A);
  static const moss = Color(0xFF53614F);
  static const mossSoft = Color(0xFF8A9484);

  /// Radius tier — buttons/inputs/chips get the small end, cards the
  /// middle, hero/CTA panels the large end. See BRAND.md.
  static const radiusSm = 12.0;
  static const radiusMd = 20.0;
  static const radiusLg = 32.0;
}

ThemeData buildGiftPathTheme() {
  const seed = BrandTokens.forest;
  const gold = BrandTokens.gold;
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: seed,
    secondary: gold,
    tertiary: BrandTokens.moss,
    surface: BrandTokens.surface,
    onSurface: BrandTokens.ink,
  );

  // Type scale from BRAND.md: Fraunces carries every heading (w500-600,
  // never the heavier cuts — the mockup's warmth comes from the lighter
  // weight), Inter carries body and UI. titleLarge matters most here:
  // card titles all over the app resolve to it, so serif-vs-sans there
  // is the difference between the app matching the landing page or not.
  final textTheme =
      Typography.material2021(platform: TargetPlatform.android).black.copyWith(
            displayLarge: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 66,
                fontWeight: FontWeight.w600,
                height: 0.95,
                letterSpacing: -1,
                color: BrandTokens.ink),
            displayMedium: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 44,
                fontWeight: FontWeight.w600,
                height: 1.04,
                letterSpacing: -.5,
                color: BrandTokens.ink),
            headlineMedium: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: BrandTokens.ink),
            headlineSmall: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: BrandTokens.ink),
            titleLarge: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: BrandTokens.ink),
            titleMedium: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: BrandTokens.ink),
            bodyLarge: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                height: 1.55,
                color: BrandTokens.moss),
            bodyMedium: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.55,
                color: BrandTokens.moss),
          );

  return ThemeData(
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: BrandTokens.cream,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: BrandTokens.surface.withValues(alpha: .96),
      foregroundColor: BrandTokens.ink,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: BrandTokens.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: seed.withValues(alpha: .16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandTokens.radiusMd),
        side: BorderSide(color: seed.withValues(alpha: 0.08)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrandTokens.radiusSm)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ).copyWith(
        // Hover/press feedback — a filled button lifts on hover and
        // settles on press, instead of sitting dead flat until clicked.
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 1.0;
          if (states.contains(WidgetState.hovered)) return 8.0;
          return 0.0;
        }),
        shadowColor:
            WidgetStatePropertyAll(BrandTokens.gold.withValues(alpha: .45)),
        animationDuration: const Duration(milliseconds: 160),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrandTokens.radiusSm)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return const BorderSide(color: seed, width: 1.5);
          }
          return BorderSide(color: seed.withValues(alpha: 0.28));
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return seed.withValues(alpha: .06);
          }
          return null;
        }),
        animationDuration: const Duration(milliseconds: 160),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrandTokens.radiusSm)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandTokens.radiusSm)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
        borderSide: BorderSide(color: seed.withValues(alpha: .20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
        borderSide: const BorderSide(color: seed, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: seed.withValues(alpha: .14)),
      backgroundColor: BrandTokens.surface,
      selectedColor: seed.withValues(alpha: .12),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: seed),
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
