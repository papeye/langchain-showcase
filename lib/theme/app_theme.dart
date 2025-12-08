import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette - Monokai inspired with modern touches
  static const Color backgroundDark = Color(0xFF1a1a2e);
  static const Color backgroundCard = Color(0xFF16213e);
  static const Color surfaceColor = Color(0xFF0f3460);
  static const Color primaryAccent = Color(0xFFe94560);
  static const Color secondaryAccent = Color(0xFF00d9ff);
  static const Color tertiaryAccent = Color(0xFFa6e22e);
  static const Color warningAccent = Color(0xFFf4d03f);
  static const Color textPrimary = Color(0xFFf8f8f2);
  static const Color textSecondary = Color(0xFF8b8b9e);
  static const Color textMuted = Color(0xFF5a5a6e);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        tertiary: tertiaryAccent,
        surface: backgroundCard,
        onPrimary: textPrimary,
        onSecondary: backgroundDark,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: surfaceColor.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: surfaceColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryAccent, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: secondaryAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surfaceColor.withValues(alpha: 0.5),
        thickness: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: backgroundCard,
        selectedIconTheme: const IconThemeData(color: primaryAccent, size: 24),
        unselectedIconTheme: const IconThemeData(color: textMuted, size: 24),
        selectedLabelTextStyle: GoogleFonts.jetBrainsMono(
          color: primaryAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: GoogleFonts.jetBrainsMono(
          color: textMuted,
          fontSize: 12,
        ),
        indicatorColor: primaryAccent.withValues(alpha: 0.15),
      ),
    );
  }
}

// Gradient definitions
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppTheme.primaryAccent, Color(0xFFff6b6b)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [AppTheme.secondaryAccent, Color(0xFF00b4d8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [AppTheme.tertiaryAccent, Color(0xFF2ecc71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [AppTheme.backgroundDark, Color(0xFF0d1b2a)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

