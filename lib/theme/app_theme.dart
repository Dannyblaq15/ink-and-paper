import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const surface = Color(0xffffffff);
  static const darkSurface = Color(0xff000000);
  static const onSurface = Color(0xff1f1b16);
  static const darkOnSurface = Color(0xfff6f1ed);
  static const onPrimary = Color(0xffffffff);
  static const primary = Color(0xff94442e);
  static const burntOrange = Color(0xff94442e);
  static const primaryContainer = Color(0xffb35c44);
  static const outline = Color(0xff88726d);
  static const surfaceVariant = Color(0xffebe1d8);
  static const darkSurfaceVariant = Color(0xff24201e);
  static const onSurfaceVariant = Color(0xff55433e);
  static const darkOnSurfaceVariant = Color(0xffd9c9c2);
  static const surfaceContainer = Color(0xfff6ece3);
  static const darkSurfaceContainer = Color(0xff151312);
  static const surfaceContainerHighest = Color(0xffebe1d8);
  static const darkSurfaceContainerHighest = Color(0xff211d1b);
  static const surfaceContainerLowest = Color(0xffffffff);
  static const darkSurfaceContainerLowest = Color(0xff0d0c0b);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color pageBackground(BuildContext context) {
    return isDark(context) ? darkSurface : surface;
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context) ? darkOnSurface : onSurface;
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context) ? darkOnSurfaceVariant : onSurfaceVariant;
  }

  static Color container(BuildContext context) {
    return isDark(context) ? darkSurfaceContainer : surfaceContainer;
  }

  static Color containerHighest(BuildContext context) {
    return isDark(context)
        ? darkSurfaceContainerHighest
        : surfaceContainerHighest;
  }

  static Color containerLowest(BuildContext context) {
    return isDark(context)
        ? darkSurfaceContainerLowest
        : surfaceContainerLowest;
  }

  static Color variant(BuildContext context) {
    return isDark(context) ? darkSurfaceVariant : surfaceVariant;
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 28 / 18,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        labelMedium: GoogleFonts.dmSans(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.7,
          height: 20 / 14,
        ),
        labelSmall: GoogleFonts.dmSans(
          color: onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
          height: 16 / 12,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: darkSurface,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkSurface,
      textTheme:
          GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          color: darkOnSurface,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: darkOnSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: darkOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 28 / 18,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: darkOnSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        labelMedium: GoogleFonts.dmSans(
          color: darkOnSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.7,
          height: 20 / 14,
        ),
        labelSmall: GoogleFonts.dmSans(
          color: darkOnSurface,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.36,
          height: 16 / 12,
        ),
      ),
    );
  }
}
