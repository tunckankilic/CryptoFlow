import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for CryptoWave app
class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter'; // Will use Google Fonts

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Heading Styles
  /// H1 - Large headings (32px)
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// H2 - Section headings (28px)
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// H3 - Subsection headings (24px)
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.3,
  );

  /// H4 - Card titles (20px)
  static TextStyle h4 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.4,
  );

  /// H5 - Small headings (18px)
  static TextStyle h5 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.4,
  );

  /// H6 - Tiny headings (16px)
  static TextStyle h6 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.5,
  );

  // Body Styles
  /// Body1 - Primary body text (16px)
  static TextStyle body1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Body2 - Secondary body text (14px)
  static TextStyle body2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.5,
  );

  // Price Styles
  /// Large price display (28px, bold, tabular numbers)
  static TextStyle priceLarge = GoogleFonts.robotoMono(
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: -0.5,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Medium price display (20px, semibold, tabular numbers)
  static TextStyle priceMedium = GoogleFonts.robotoMono(
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Small price display (16px, medium, tabular numbers)
  static TextStyle priceSmall = GoogleFonts.robotoMono(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Caption & Label Styles
  /// Caption - Small supplementary text (12px)
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    height: 1.33,
  );

  /// Overline - Tiny uppercase labels (10px)
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 1.5,
    height: 1.6,
  );

  /// Label - Form labels (14px)
  static TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Button Styles
  /// Button text (14px, medium, uppercase)
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 1.25,
    height: 1.14,
  );

  /// Small button text (12px, medium, uppercase)
  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 1.25,
    height: 1.33,
  );

  // Percent Change Styles
  /// Percent change text (14px, semibold)
  static TextStyle percentChange = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.43,
  );

  /// Small percent change (12px, semibold)
  static TextStyle percentChangeSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.33,
  );

  // Symbol Styles
  /// Crypto symbol (uppercase, bold)
  static TextStyle symbol = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: bold,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Small symbol (12px, semibold)
  static TextStyle symbolSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: semiBold,
    letterSpacing: 0.5,
    height: 1.33,
  );

  // Chart/Technical Styles
  /// Chart labels (11px, regular)
  static TextStyle chartLabel = GoogleFonts.robotoMono(
    fontSize: 11,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.45,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // TextTheme for MaterialApp
  static TextTheme get textTheme => TextTheme(
        displayLarge: h1,
        displayMedium: h2,
        displaySmall: h3,
        headlineLarge: h3,
        headlineMedium: h4,
        headlineSmall: h5,
        titleLarge: h4,
        titleMedium: h5,
        titleSmall: h6,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
        labelLarge: button,
        labelMedium: label,
        labelSmall: overline,
      );

  // Helper method to get price style by size
  static TextStyle getPriceStyle(PriceSize size) {
    switch (size) {
      case PriceSize.large:
        return priceLarge;
      case PriceSize.medium:
        return priceMedium;
      case PriceSize.small:
        return priceSmall;
    }
  }
}

/// Price display size variants
enum PriceSize {
  small,
  medium,
  large,
}
