import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  /// Get light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: CryptoColors.primary,
        secondary: CryptoColors.secondary,
        tertiary: CryptoColors.accent,
        error: CryptoColors.error,
        surface: CryptoColors.lightCardBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: CryptoColors.lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: CryptoColors.lightBg,
      cardTheme: CardThemeData(
        color: CryptoColors.lightCardBg,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: CryptoColors.lightCardBg,
        foregroundColor: CryptoColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h5.copyWith(
          color: CryptoColors.lightTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CryptoColors.lightCardBg,
        selectedItemColor: CryptoColors.primary,
        unselectedItemColor: CryptoColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: CryptoColors.borderLight,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CryptoColors.lightSurfaceBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: CryptoColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: CryptoColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: CryptoColors.primary, width: 2),
        ),
      ),
    );
  }

  /// Get dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: CryptoColors.primary,
        secondary: CryptoColors.secondary,
        tertiary: CryptoColors.accent,
        error: CryptoColors.error,
        surface: CryptoColors.cardBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: CryptoColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: CryptoColors.darkBg,
      cardTheme: CardThemeData(
        color: CryptoColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: CryptoColors.cardBg,
        foregroundColor: CryptoColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h5.copyWith(
          color: CryptoColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CryptoColors.cardBg,
        selectedItemColor: CryptoColors.primary,
        unselectedItemColor: CryptoColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: CryptoColors.divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CryptoColors.surfaceBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: CryptoColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: CryptoColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: CryptoColors.primary, width: 2),
        ),
      ),
    );
  }

  /// Get AMOLED dark theme (pure black for OLED displays)
  static ThemeData get amoledTheme {
    return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(
        surface: const Color(0xFF0D0D0D),
      ),
      scaffoldBackgroundColor: CryptoColors.amoledBlack,
      cardTheme: darkTheme.cardTheme.copyWith(
        color: const Color(0xFF0D0D0D),
      ),
      appBarTheme: darkTheme.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF0D0D0D),
      ),
      bottomNavigationBarTheme: darkTheme.bottomNavigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF0D0D0D),
      ),
    );
  }
}
