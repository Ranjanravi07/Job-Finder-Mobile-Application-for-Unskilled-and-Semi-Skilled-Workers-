import 'package:flutter/material.dart';

/// Shared color palette matching the Tailwind slate / emerald theme used in
/// the React `MobileSimulator.tsx`. Now supports dynamic Light/Dark mode.
class AppColors {
  AppColors._();

  // Dynamic system brightness state
  static Brightness systemBrightness = Brightness.light;
  static bool get isDark => systemBrightness == Brightness.dark;

  // Slate hierarchy mapped for HIGH CONTRAST (Text uses 300-900, Backgrounds use 50-200)
  static Color get slate900 => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  static Color get slate800 => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF020617);
  static Color get slate700 => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color get slate600 => isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
  static Color get slate500 => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
  static Color get slate400 => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get slate300 => isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
  
  // Backgrounds and borders remain untouched to preserve layout aesthetics
  static Color get slate200 => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get slate100 => isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get slate50  => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  // Pure white inverts to darkest slate
  static Color get white => isDark ? const Color(0xFF020617) : const Color(0xFFFFFFFF);

  // Emerald brand colors (kept vibrant, slight shade adjustments for legibility)
  static Color get emerald50  => isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
  static Color get emerald100 => isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5);
  static Color get emerald400 => const Color(0xFF34D399);
  static Color get emerald500 => const Color(0xFF10B981);
  static Color get emerald600 => const Color(0xFF059669);
  static Color get emerald700 => const Color(0xFF047857);

  // Blue brand colors
  static Color get indigo600 => isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
  static Color get blue600   => isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A73E8);
  static Color get brandBlue => isDark ? const Color(0xFF3B82F6) : const Color(0xFF005BB5);

  // Red error/alert colors
  static Color get red50  => isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
  static Color get red200 => isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
  static Color get red500 => const Color(0xFFEF4444);
  static Color get red600 => const Color(0xFFDC2626);
  static Color get red700 => const Color(0xFFB91C1C);

  static Color get amber500 => const Color(0xFFF59E0B);
  static Color get amber600 => const Color(0xFFD97706);
  static Color get amber700 => const Color(0xFFB45309);
}
