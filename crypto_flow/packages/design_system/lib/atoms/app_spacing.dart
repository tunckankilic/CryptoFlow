import 'package:flutter/material.dart';

/// Spacing constants for consistent layout
class AppSpacing {
  AppSpacing._();

  // Base spacing scale (multiples of 4)
  /// Extra small spacing (4px)
  static const double xs = 4.0;

  /// Small spacing (8px)
  static const double sm = 8.0;

  /// Medium spacing (16px)
  static const double md = 16.0;

  /// Large spacing (24px)
  static const double lg = 24.0;

  /// Extra large spacing (32px)
  static const double xl = 32.0;

  /// Extra extra large spacing (48px)
  static const double xxl = 48.0;

  /// Extra extra extra large spacing (64px)
  static const double xxxl = 64.0;

  // Component-specific spacing
  /// Padding inside cards
  static const double cardPadding = md;

  /// Padding for card content
  static const double cardContentPadding = lg;

  /// Padding inside list items
  static const double listPadding = md;

  /// Vertical spacing in list items
  static const double listItemSpacing = xs;

  /// Spacing between sections
  static const double sectionSpacing = xl;

  /// Page padding (horizontal)
  static const double pagePadding = md;

  /// Screen edge padding
  static const double screenPadding = md;

  // Icon sizes
  /// Tiny icon (16px)
  static const double iconTiny = 16.0;

  /// Small icon (20px)
  static const double iconSmall = 20.0;

  /// Medium icon (24px)
  static const double iconMedium = 24.0;

  /// Large icon (32px)
  static const double iconLarge = 32.0;

  /// Extra large icon (48px)
  static const double iconXLarge = 48.0;

  // Border Radius
  /// No radius (square corners)
  static const double radiusNone = 0.0;

  /// Small radius (4px)
  static const double radiusSmall = 4.0;

  /// Medium radius (8px)
  static const double radiusMedium = 8.0;

  /// Large radius (12px)
  static const double radiusLarge = 12.0;

  /// Extra large radius (16px)
  static const double radiusXLarge = 16.0;

  /// Circular radius (999px - effectively circular)
  static const double radiusCircular = 999.0;

  // Border Width
  /// Thin border (1px)
  static const double borderThin = 1.0;

  /// Medium border (2px)
  static const double borderMedium = 2.0;

  /// Thick border (3px)
  static const double borderThick = 3.0;

  // Chart/Graph spacing
  /// Padding around charts
  static const double chartPadding = sm;

  /// Spacing between chart elements
  static const double chartSpacing = xs;

  /// Height of sparkline charts
  static const double sparklineHeight = 40.0;

  /// Height of full candlestick charts
  static const double candlestickHeight = 300.0;

  // Button sizes
  /// Small button height
  static const double buttonSmall = 32.0;

  /// Medium button height
  static const double buttonMedium = 40.0;

  /// Large button height
  static const double buttonLarge = 48.0;

  /// Button horizontal padding
  static const double buttonPadding = md;

  // Input field sizes
  /// Input field height
  static const double inputHeight = 48.0;

  /// Input field padding
  static const double inputPadding = md;

  // App bar
  /// App bar height
  static const double appBarHeight = 56.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 60.0;

  // Coin tile dimensions
  /// Height of cryptocurrency list item
  static const double coinTileHeight = 72.0;

  /// Icon size in coin tile
  static const double coinIconSize = 40.0;

  // Order book
  /// Height of each order book row
  static const double orderBookRowHeight = 24.0;

  /// Padding in order book
  static const double orderBookPadding = sm;

  // EdgeInsets helpers
  /// All sides padding
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Horizontal padding
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  /// Vertical padding
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  /// Custom padding
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Common EdgeInsets presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
  static const EdgeInsets paddingPage = EdgeInsets.all(pagePadding);
  static const EdgeInsets paddingScreen = EdgeInsets.all(screenPadding);

  // SizedBox helpers
  /// Vertical spacing widget
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Horizontal spacing widget
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  // Common SizedBox presets
  static Widget get spaceXS => SizedBox(height: xs);
  static Widget get spaceSM => SizedBox(height: sm);
  static Widget get spaceMD => SizedBox(height: md);
  static Widget get spaceLG => SizedBox(height: lg);
  static Widget get spaceXL => SizedBox(height: xl);

  static Widget get spaceXSHorizontal => SizedBox(width: xs);
  static Widget get spaceSMHorizontal => SizedBox(width: sm);
  static Widget get spaceMDHorizontal => SizedBox(width: md);
  static Widget get spaceLGHorizontal => SizedBox(width: lg);
  static Widget get spaceXLHorizontal => SizedBox(width: xl);

  // BorderRadius helpers
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  static const BorderRadius radiusS =
      BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius radiusM =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius radiusL =
      BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius radiusXL =
      BorderRadius.all(Radius.circular(radiusXLarge));
}
