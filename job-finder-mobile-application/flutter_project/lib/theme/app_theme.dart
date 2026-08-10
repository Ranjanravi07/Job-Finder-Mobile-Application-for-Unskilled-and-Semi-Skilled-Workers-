import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colors = AppColorsExtension.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.slate50,
      colorScheme: ColorScheme.light(
        primary: colors.slate900,
        secondary: colors.emerald500,
        surface: colors.white,
        error: colors.red500,
        onPrimary: colors.white,
        onSecondary: colors.white,
        onSurface: colors.slate900,
        onError: colors.white,
      ),
      extensions: [colors],
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: colors.slate800,
        displayColor: colors.slate900,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.slate50,
        foregroundColor: colors.slate900,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.slate100,
        hintStyle: TextStyle(color: colors.slate400),
        labelStyle: TextStyle(color: colors.slate500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate900, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.red500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.slate900,
          foregroundColor: colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: colors.slate900),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(colors.white),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.slate200),
        ),
      ),
      iconTheme: IconThemeData(color: colors.slate600),
    );
  }

  static ThemeData get darkTheme {
    final colors = AppColorsExtension.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.slate50,
      colorScheme: ColorScheme.dark(
        primary: colors.slate900, // white in dark mode
        secondary: colors.emerald500,
        surface:
            colors.white, // slate100/slate200 mapped to dark in our extension
        error: colors.red500,
        onPrimary: colors.slate50, // black in dark mode
        onSecondary: colors.white,
        onSurface: colors.slate900,
        onError: colors.white,
      ),
      extensions: [colors],
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: colors.slate800,
        displayColor: colors.slate900,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.slate50,
        foregroundColor: colors.slate900,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.slate100, // slate100 is dark in dark mode mapping
        hintStyle: TextStyle(color: colors.slate400),
        labelStyle: TextStyle(color: colors.slate500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate200), // mapped border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.slate900, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.red500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.slate900,
          foregroundColor: colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: colors.slate900),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
              colors.white), // white is mapped to dark bg in dark mode
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.slate200),
        ),
      ),
      iconTheme: IconThemeData(color: colors.slate600),
    );
  }
}
