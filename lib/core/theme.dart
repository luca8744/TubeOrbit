import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TubeOrbit minimal greyscale theme — zero distractions.
class AppTheme {
  AppTheme._();

  // ── Greyscale palette ───────────────────────────────────────────────────────
  static const Color background    = Color(0xFF111111);
  static const Color surface       = Color(0xFF191919);
  static const Color surfaceVariant= Color(0xFF222222);
  static const Color surfaceHigh   = Color(0xFF2C2C2C);

  /// Used where the old "accent" was — neutral light grey instead of purple.
  static const Color accent        = Color(0xFFB0B0B0);
  static const Color accentLight   = Color(0xFFD4D4D4);
  static const Color onAccent      = Color(0xFF111111);

  static const Color textPrimary   = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFF737373);
  static const Color divider       = Color(0xFF2A2A2A);
  static const Color error         = Color(0xFF8A8A8A); // desaturated error

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: onAccent,
        secondary: accentLight,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textSecondary,
        indicatorColor: textPrimary,
        dividerColor: divider,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dividerColor: divider,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
