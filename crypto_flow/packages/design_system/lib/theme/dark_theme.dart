import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';

/// Optimized dark theme for cryptocurrency applications
/// Features high contrast for price changes and chart-friendly colors
class DarkTheme {
  DarkTheme._();

  /// Get optimized dark theme
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme optimized for crypto
      colorScheme: const ColorScheme.dark(
        primary: CryptoColors.chartLine,
        primaryContainer: Color(0xFF1565C0),
        secondary: CryptoColors.priceUp,
        secondaryContainer: Color(0xFF00A844),
        tertiary: CryptoColors.accent,
        tertiaryContainer: Color(0xFFF951F0),
        error: CryptoColors.priceDown,
        errorContainer: Color(0xFFD32F2F),
        surface: CryptoColors.cardBg,
        surfaceContainerHighest: CryptoColors.surfaceBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.black,
        onSurface: CryptoColors.textPrimary,
        onError: Colors.white,
        outline: CryptoColors.borderDark,
      ),

      scaffoldBackgroundColor: CryptoColors.darkBg,

      // Card theme for price cards
      cardTheme: CardThemeData(
        color: CryptoColors.cardBg,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        margin: EdgeInsets.zero,
      ),

      // Text theme using crypto-optimized typography
      textTheme: AppTypography.textTheme.apply(
        bodyColor: CryptoColors.textPrimary,
        displayColor: CryptoColors.textPrimary,
      ),

      // App bar for dark theme
      appBarTheme: AppBarTheme(
        backgroundColor: CryptoColors.cardBg,
        foregroundColor: CryptoColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h5.copyWith(
          color: CryptoColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: CryptoColors.textPrimary,
        ),
      ),

      // Bottom navigation optimized for dark
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CryptoColors.cardBg,
        selectedItemColor: CryptoColors.primary,
        unselectedItemColor: CryptoColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: CryptoColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CryptoColors.surfaceBg,
        hintStyle: AppTypography.body2.copyWith(
          color: CryptoColors.textTertiary,
        ),
        labelStyle: AppTypography.body2.copyWith(
          color: CryptoColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: CryptoColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: CryptoColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: CryptoColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: CryptoColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: CryptoColors.error, width: 2),
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CryptoColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSpacing.buttonMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CryptoColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          side: const BorderSide(color: CryptoColors.primary),
          textStyle: AppTypography.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CryptoColors.primary,
          textStyle: AppTypography.button,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: CryptoColors.textPrimary,
        size: AppSpacing.iconMedium,
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CryptoColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: CryptoColors.surfaceBg,
        selectedColor: CryptoColors.primary.withValues(alpha: 0.2),
        labelStyle: AppTypography.body2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ),
    );
  }

  /// Get AMOLED black theme for OLED displays
  static ThemeData get amoledTheme {
    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: const Color(0xFF0D0D0D),
      ),
      scaffoldBackgroundColor: CryptoColors.amoledBlack,
      cardTheme: theme.cardTheme.copyWith(
        color: const Color(0xFF0D0D0D),
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF0D0D0D),
      ),
      bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF0D0D0D),
      ),
    );
  }
}
