import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Extra design tokens that Material's ColorScheme doesn't cover.
@immutable
class PPTheme extends ThemeExtension<PPTheme> {
  const PPTheme({
    required this.shelfTop,
    required this.shelfBottom,
    required this.shelfGlow,
    required this.plank,
    required this.glassOutline,
    required this.card,
    required this.muted,
    required this.savings,
    required this.jar,
    required this.fun,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color shelfTop;
  final Color shelfBottom;
  final Color shelfGlow;
  final Color plank;
  final Color glassOutline;
  final Color card;
  final Color muted;
  final Color savings;
  final Color jar;
  final Color fun;
  final Color success;
  final Color warning;
  final Color danger;

  static const dark = PPTheme(
    shelfTop: Color(0xFF151726),
    shelfBottom: PPColors.night,
    shelfGlow: Color(0x55FFB347),
    plank: Color(0xFF3A2C22),
    glassOutline: Color(0x88F2EFE9),
    card: PPColors.nightCard,
    muted: PPColors.mutedText,
    savings: PPColors.savingsAmber,
    jar: PPColors.jarBlue,
    fun: PPColors.funPink,
    success: PPColors.success,
    warning: PPColors.warning,
    danger: PPColors.danger,
  );

  static const light = PPTheme(
    shelfTop: Color(0xFFFFF4E2),
    shelfBottom: PPColors.cream,
    shelfGlow: Color(0x44FFC857),
    plank: Color(0xFFC79A6B),
    glassOutline: Color(0x6623212B),
    card: PPColors.creamCard,
    muted: PPColors.inkMuted,
    savings: PPColors.amberDeep,
    jar: Color(0xFF4F7FC4),
    fun: Color(0xFFD0679A),
    success: Color(0xFF2E9E66),
    warning: Color(0xFFE07B12),
    danger: Color(0xFFD64545),
  );

  @override
  PPTheme copyWith() => this;

  @override
  PPTheme lerp(ThemeExtension<PPTheme>? other, double t) {
    if (other is! PPTheme) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PPTheme(
      shelfTop: l(shelfTop, other.shelfTop),
      shelfBottom: l(shelfBottom, other.shelfBottom),
      shelfGlow: l(shelfGlow, other.shelfGlow),
      plank: l(plank, other.plank),
      glassOutline: l(glassOutline, other.glassOutline),
      card: l(card, other.card),
      muted: l(muted, other.muted),
      savings: l(savings, other.savings),
      jar: l(jar, other.jar),
      fun: l(fun, other.fun),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
    );
  }
}

extension PPThemeX on BuildContext {
  PPTheme get pp => Theme.of(this).extension<PPTheme>()!;
}

/// Poppins for headings, Inter for body, Noto Sans Devanagari for Hindi.
abstract final class PPFonts {
  static const String heading = 'Poppins';
  static const String body = 'Inter';
  static const List<String> fallback = ['NotoSansDevanagari'];
}

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final pp = isDark ? PPTheme.dark : PPTheme.light;
  final bg = isDark ? PPColors.night : PPColors.cream;
  final fg = isDark ? PPColors.offWhite : PPColors.ink;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: pp.savings,
    onPrimary: PPColors.ink,
    primaryContainer: isDark
        ? const Color(0xFF3D3016)
        : const Color(0xFFFFE8B0),
    onPrimaryContainer: fg,
    secondary: pp.jar,
    onSecondary: PPColors.ink,
    secondaryContainer: isDark
        ? const Color(0xFF1F2A3D)
        : const Color(0xFFDCE7F7),
    onSecondaryContainer: fg,
    tertiary: pp.fun,
    onTertiary: PPColors.ink,
    error: pp.danger,
    onError: Colors.white,
    surface: bg,
    onSurface: fg,
    onSurfaceVariant: pp.muted,
    surfaceContainerLowest: bg,
    surfaceContainerLow: isDark
        ? PPColors.nightRaised
        : const Color(0xFFFFFBF5),
    surfaceContainer: pp.card,
    surfaceContainerHigh: isDark
        ? const Color(0xFF242839)
        : const Color(0xFFF5EEE2),
    surfaceContainerHighest: isDark
        ? const Color(0xFF2B3044)
        : const Color(0xFFEDE4D6),
    outline: isDark ? const Color(0xFF4A4E62) : const Color(0xFFCFC6B8),
    outlineVariant: isDark ? const Color(0xFF2F3345) : const Color(0xFFE6DDCF),
  );

  TextStyle h(double size, FontWeight w) => TextStyle(
    fontFamily: PPFonts.heading,
    fontFamilyFallback: PPFonts.fallback,
    fontSize: size,
    fontWeight: w,
    color: fg,
    height: 1.2,
  );
  TextStyle b(double size, FontWeight w, {Color? color}) => TextStyle(
    fontFamily: PPFonts.body,
    fontFamilyFallback: PPFonts.fallback,
    fontSize: size,
    fontWeight: w,
    color: color ?? fg,
    height: 1.4,
  );

  final textTheme = TextTheme(
    displayLarge: h(44, FontWeight.w700),
    displayMedium: h(36, FontWeight.w700),
    displaySmall: h(30, FontWeight.w600),
    headlineLarge: h(28, FontWeight.w600),
    headlineMedium: h(24, FontWeight.w600),
    headlineSmall: h(20, FontWeight.w600),
    titleLarge: h(18, FontWeight.w600),
    titleMedium: b(16, FontWeight.w600),
    titleSmall: b(14, FontWeight.w600),
    bodyLarge: b(16, FontWeight.w400),
    bodyMedium: b(14, FontWeight.w400),
    bodySmall: b(12, FontWeight.w400, color: pp.muted),
    labelLarge: b(15, FontWeight.w600),
    labelMedium: b(13, FontWeight.w500),
    labelSmall: b(11, FontWeight.w500, color: pp.muted),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    fontFamily: PPFonts.body,
    fontFamilyFallback: PPFonts.fallback,
    textTheme: textTheme,
    extensions: [pp],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: h(20, FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: pp.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: b(16, FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        foregroundColor: fg,
        textStyle: b(15, FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: pp.savings,
        textStyle: b(15, FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: pp.savings, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: pp.savings,
      linearTrackColor: scheme.surfaceContainerHighest,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 6,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? PPColors.nightRaised : PPColors.creamCard,
      indicatorColor: scheme.primaryContainer,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(b(12, FontWeight.w600)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? PPColors.nightRaised : PPColors.creamCard,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? PPColors.nightRaised : PPColors.creamCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF2B3044) : PPColors.ink,
      contentTextStyle: b(14, FontWeight.w500, color: PPColors.offWhite),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: b(13, FontWeight.w600),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: pp.savings,
      foregroundColor: PPColors.ink,
      largeSizeConstraints: const BoxConstraints.tightFor(
        width: 72,
        height: 72,
      ),
    ),
  );
}
