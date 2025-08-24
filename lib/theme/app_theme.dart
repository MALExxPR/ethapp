import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB), // Blue 600
        primaryContainer: Color(0xFFDBEAFE), // Blue 100
        secondary: Color(0xFF059669), // Emerald 600
        secondaryContainer: Color(0xFFD1FAE5), // Emerald 100
        tertiary: Color(0xFFDC2626), // Red 600
        tertiaryContainer: Color(0xFFFEE2E2), // Red 100
        surface: Color(0xFFFFFFFF), // White
        surfaceVariant: Color(0xFFF8FAFC), // Slate 50
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onTertiary: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A), // Slate 900
        onSurfaceVariant: Color(0xFF64748B), // Slate 500
        outline: Color(0xFFE2E8F0), // Slate 200
        outlineVariant: Color(0xFFF1F5F9), // Slate 100
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF0F172A),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF475569),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF64748B),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF475569),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6), // Blue 500
        primaryContainer: Color(0xFF1E3A8A), // Blue 800
        secondary: Color(0xFF10B981), // Emerald 500
        secondaryContainer: Color(0xFF065F46), // Emerald 800
        tertiary: Color(0xFFEF4444), // Red 500
        tertiaryContainer: Color(0xFF991B1B), // Red 800
        surface: Color(0xFF0F172A), // Slate 900
        surfaceVariant: Color(0xFF1E293B), // Slate 800
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onTertiary: Color(0xFFFFFFFF),
        onSurface: Color(0xFFF8FAFC), // Slate 50
        onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
        outline: Color(0xFF334155), // Slate 700
        outlineVariant: Color(0xFF475569), // Slate 600
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8FAFC),
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8FAFC),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFF8FAFC),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF94A3B8),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF64748B),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8FAFC),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF334155),
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Custom colors for trading-specific UI
  static const Color profitGreen = Color(0xFF10B981); // Emerald 500
  static const Color lossRed = Color(0xFFEF4444); // Red 500
  static const Color warningAmber = Color(0xFFF59E0B); // Amber 500
  static const Color neutralGray = Color(0xFF6B7280); // Gray 500
  
  // Chart colors
  static const Color bullishGreen = Color(0xFF059669); // Emerald 600
  static const Color bearishRed = Color(0xFFDC2626); // Red 600
  static const Color volumeBlue = Color(0xFF3B82F6); // Blue 500
}