import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Slate hierarchy
  final Color slate900;
  final Color slate800;
  final Color slate700;
  final Color slate600;
  final Color slate500;
  final Color slate400;
  final Color slate300;

  final Color slate200;
  final Color slate100;
  final Color slate50;

  final Color white;

  // Emerald brand colors
  final Color emerald50;
  final Color emerald100;
  final Color emerald400;
  final Color emerald500;
  final Color emerald600;
  final Color emerald700;

  // Blue brand colors
  final Color indigo600;
  final Color blue600;
  final Color brandBlue;

  // Red error/alert colors
  final Color red50;
  final Color red200;
  final Color red500;
  final Color red600;
  final Color red700;

  final Color amber500;
  final Color amber600;
  final Color amber700;

  const AppColorsExtension({
    required this.slate900,
    required this.slate800,
    required this.slate700,
    required this.slate600,
    required this.slate500,
    required this.slate400,
    required this.slate300,
    required this.slate200,
    required this.slate100,
    required this.slate50,
    required this.white,
    required this.emerald50,
    required this.emerald100,
    required this.emerald400,
    required this.emerald500,
    required this.emerald600,
    required this.emerald700,
    required this.indigo600,
    required this.blue600,
    required this.brandBlue,
    required this.red50,
    required this.red200,
    required this.red500,
    required this.red600,
    required this.red700,
    required this.amber500,
    required this.amber600,
    required this.amber700,
  });

  @override
  AppColorsExtension copyWith({
    Color? slate900,
    Color? slate800,
    Color? slate700,
    Color? slate600,
    Color? slate500,
    Color? slate400,
    Color? slate300,
    Color? slate200,
    Color? slate100,
    Color? slate50,
    Color? white,
    Color? emerald50,
    Color? emerald100,
    Color? emerald400,
    Color? emerald500,
    Color? emerald600,
    Color? emerald700,
    Color? indigo600,
    Color? blue600,
    Color? brandBlue,
    Color? red50,
    Color? red200,
    Color? red500,
    Color? red600,
    Color? red700,
    Color? amber500,
    Color? amber600,
    Color? amber700,
  }) {
    return AppColorsExtension(
      slate900: slate900 ?? this.slate900,
      slate800: slate800 ?? this.slate800,
      slate700: slate700 ?? this.slate700,
      slate600: slate600 ?? this.slate600,
      slate500: slate500 ?? this.slate500,
      slate400: slate400 ?? this.slate400,
      slate300: slate300 ?? this.slate300,
      slate200: slate200 ?? this.slate200,
      slate100: slate100 ?? this.slate100,
      slate50: slate50 ?? this.slate50,
      white: white ?? this.white,
      emerald50: emerald50 ?? this.emerald50,
      emerald100: emerald100 ?? this.emerald100,
      emerald400: emerald400 ?? this.emerald400,
      emerald500: emerald500 ?? this.emerald500,
      emerald600: emerald600 ?? this.emerald600,
      emerald700: emerald700 ?? this.emerald700,
      indigo600: indigo600 ?? this.indigo600,
      blue600: blue600 ?? this.blue600,
      brandBlue: brandBlue ?? this.brandBlue,
      red50: red50 ?? this.red50,
      red200: red200 ?? this.red200,
      red500: red500 ?? this.red500,
      red600: red600 ?? this.red600,
      red700: red700 ?? this.red700,
      amber500: amber500 ?? this.amber500,
      amber600: amber600 ?? this.amber600,
      amber700: amber700 ?? this.amber700,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      slate900: Color.lerp(slate900, other.slate900, t)!,
      slate800: Color.lerp(slate800, other.slate800, t)!,
      slate700: Color.lerp(slate700, other.slate700, t)!,
      slate600: Color.lerp(slate600, other.slate600, t)!,
      slate500: Color.lerp(slate500, other.slate500, t)!,
      slate400: Color.lerp(slate400, other.slate400, t)!,
      slate300: Color.lerp(slate300, other.slate300, t)!,
      slate200: Color.lerp(slate200, other.slate200, t)!,
      slate100: Color.lerp(slate100, other.slate100, t)!,
      slate50: Color.lerp(slate50, other.slate50, t)!,
      white: Color.lerp(white, other.white, t)!,
      emerald50: Color.lerp(emerald50, other.emerald50, t)!,
      emerald100: Color.lerp(emerald100, other.emerald100, t)!,
      emerald400: Color.lerp(emerald400, other.emerald400, t)!,
      emerald500: Color.lerp(emerald500, other.emerald500, t)!,
      emerald600: Color.lerp(emerald600, other.emerald600, t)!,
      emerald700: Color.lerp(emerald700, other.emerald700, t)!,
      indigo600: Color.lerp(indigo600, other.indigo600, t)!,
      blue600: Color.lerp(blue600, other.blue600, t)!,
      brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
      red50: Color.lerp(red50, other.red50, t)!,
      red200: Color.lerp(red200, other.red200, t)!,
      red500: Color.lerp(red500, other.red500, t)!,
      red600: Color.lerp(red600, other.red600, t)!,
      red700: Color.lerp(red700, other.red700, t)!,
      amber500: Color.lerp(amber500, other.amber500, t)!,
      amber600: Color.lerp(amber600, other.amber600, t)!,
      amber700: Color.lerp(amber700, other.amber700, t)!,
    );
  }

  // Define light mode colors
  static const light = AppColorsExtension(
    slate900: Color(0xFF000000),
    slate800: Color(0xFF020617),
    slate700: Color(0xFF0F172A),
    slate600: Color(0xFF1E293B),
    slate500: Color(0xFF334155),
    slate400: Color(0xFF475569),
    slate300: Color(0xFF64748B),
    slate200: Color(0xFFE2E8F0),
    slate100: Color(0xFFF1F5F9),
    slate50: Color(0xFFF8FAFC),
    white: Color(0xFFFFFFFF),
    emerald50: Color(0xFFECFDF5),
    emerald100: Color(0xFFD1FAE5),
    emerald400: Color(0xFF34D399),
    emerald500: Color(0xFF10B981),
    emerald600: Color(0xFF059669),
    emerald700: Color(0xFF047857),
    indigo600: Color(0xFF4F46E5),
    blue600: Color(0xFF1A73E8),
    brandBlue: Color(0xFF005BB5),
    red50: Color(0xFFFEF2F2),
    red200: Color(0xFFFECACA),
    red500: Color(0xFFEF4444),
    red600: Color(0xFFDC2626),
    red700: Color(0xFFB91C1C),
    amber500: Color(0xFFF59E0B),
    amber600: Color(0xFFD97706),
    amber700: Color(0xFFB45309),
  );

  // Define dark mode colors based on previous logic
  static const dark = AppColorsExtension(
    slate900: Color(0xFFFFFFFF),
    slate800: Color(0xFFF8FAFC),
    slate700: Color(0xFFF1F5F9),
    slate600: Color(0xFFE2E8F0),
    slate500: Color(0xFFCBD5E1),
    slate400: Color(0xFF94A3B8),
    slate300: Color(0xFF64748B),
    slate200: Color(0xFF334155),
    slate100: Color(0xFF1E293B),
    slate50: Color(0xFF0F172A),
    white: Color(0xFF020617),
    emerald50: Color(0xFF064E3B),
    emerald100: Color(0xFF065F46),
    emerald400: Color(0xFF34D399),
    emerald500: Color(0xFF10B981),
    emerald600: Color(0xFF059669),
    emerald700: Color(0xFF047857),
    indigo600: Color(0xFF818CF8),
    blue600: Color(0xFF60A5FA),
    brandBlue: Color(0xFF3B82F6),
    red50: Color(0xFF450A0A),
    red200: Color(0xFF7F1D1D),
    red500: Color(0xFFEF4444),
    red600: Color(0xFFDC2626),
    red700: Color(0xFFB91C1C),
    amber500: Color(0xFFF59E0B),
    amber600: Color(0xFFD97706),
    amber700: Color(0xFFB45309),
  );
}

// Extension to make it easy to access colors via `context.appColors.slate900`
extension AppColorsContextX on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

// Fallback for places without context (like outside the widget tree)
// Note: This shouldn't be used inside build methods. Use context.appColors instead.
class AppColors {
  // To avoid breaking anything right away before refactoring finishes,
  // we can provide static fallbacks, but ideally everything is refactored.
  // Actually, we'll keep static getters temporarily for files we haven't refactored yet,
  // returning light colors by default, but the regex replace will fix almost everything.

  static Brightness systemBrightness = Brightness.light;
  static bool get isDark => systemBrightness == Brightness.dark;

  static Color get slate900 => isDark
      ? AppColorsExtension.dark.slate900
      : AppColorsExtension.light.slate900;
  static Color get slate800 => isDark
      ? AppColorsExtension.dark.slate800
      : AppColorsExtension.light.slate800;
  static Color get slate700 => isDark
      ? AppColorsExtension.dark.slate700
      : AppColorsExtension.light.slate700;
  static Color get slate600 => isDark
      ? AppColorsExtension.dark.slate600
      : AppColorsExtension.light.slate600;
  static Color get slate500 => isDark
      ? AppColorsExtension.dark.slate500
      : AppColorsExtension.light.slate500;
  static Color get slate400 => isDark
      ? AppColorsExtension.dark.slate400
      : AppColorsExtension.light.slate400;
  static Color get slate300 => isDark
      ? AppColorsExtension.dark.slate300
      : AppColorsExtension.light.slate300;
  static Color get slate200 => isDark
      ? AppColorsExtension.dark.slate200
      : AppColorsExtension.light.slate200;
  static Color get slate100 => isDark
      ? AppColorsExtension.dark.slate100
      : AppColorsExtension.light.slate100;
  static Color get slate50 => isDark
      ? AppColorsExtension.dark.slate50
      : AppColorsExtension.light.slate50;
  static Color get white =>
      isDark ? AppColorsExtension.dark.white : AppColorsExtension.light.white;

  static Color get emerald50 => isDark
      ? AppColorsExtension.dark.emerald50
      : AppColorsExtension.light.emerald50;
  static Color get emerald100 => isDark
      ? AppColorsExtension.dark.emerald100
      : AppColorsExtension.light.emerald100;
  static Color get emerald400 => isDark
      ? AppColorsExtension.dark.emerald400
      : AppColorsExtension.light.emerald400;
  static Color get emerald500 => isDark
      ? AppColorsExtension.dark.emerald500
      : AppColorsExtension.light.emerald500;
  static Color get emerald600 => isDark
      ? AppColorsExtension.dark.emerald600
      : AppColorsExtension.light.emerald600;
  static Color get emerald700 => isDark
      ? AppColorsExtension.dark.emerald700
      : AppColorsExtension.light.emerald700;

  static Color get indigo600 => isDark
      ? AppColorsExtension.dark.indigo600
      : AppColorsExtension.light.indigo600;
  static Color get blue600 => isDark
      ? AppColorsExtension.dark.blue600
      : AppColorsExtension.light.blue600;
  static Color get brandBlue => isDark
      ? AppColorsExtension.dark.brandBlue
      : AppColorsExtension.light.brandBlue;

  static Color get red50 =>
      isDark ? AppColorsExtension.dark.red50 : AppColorsExtension.light.red50;
  static Color get red200 =>
      isDark ? AppColorsExtension.dark.red200 : AppColorsExtension.light.red200;
  static Color get red500 =>
      isDark ? AppColorsExtension.dark.red500 : AppColorsExtension.light.red500;
  static Color get red600 =>
      isDark ? AppColorsExtension.dark.red600 : AppColorsExtension.light.red600;
  static Color get red700 =>
      isDark ? AppColorsExtension.dark.red700 : AppColorsExtension.light.red700;

  static Color get amber500 => isDark
      ? AppColorsExtension.dark.amber500
      : AppColorsExtension.light.amber500;
  static Color get amber600 => isDark
      ? AppColorsExtension.dark.amber600
      : AppColorsExtension.light.amber600;
  static Color get amber700 => isDark
      ? AppColorsExtension.dark.amber700
      : AppColorsExtension.light.amber700;
}
