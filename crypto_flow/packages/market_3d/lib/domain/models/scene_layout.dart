import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'scene_color.dart';

/// Colours used to build scene geometry.
///
/// Plain scene colours rather than Flutter `Color`s so the palette can be
/// unit-tested and consumed by any renderer. The presentation layer converts
/// design system colours into a palette when theming the scene (session 12).
@immutable
class ScenePalette extends Equatable {
  /// Body colour of a bullish (close >= open) candle.
  final SceneColor bullish;

  /// Body colour of a bearish (close < open) candle.
  final SceneColor bearish;

  /// Wick colour, shared by both directions.
  final SceneColor wick;

  /// Brightness multiplier applied to the still-open candle so it reads as
  /// "live" without needing a separate pair of colours.
  final double liveBrightness;

  /// Colour of the highlight applied to a selected candle.
  final SceneColor selection;

  const ScenePalette({
    required this.bullish,
    required this.bearish,
    required this.wick,
    required this.selection,
    this.liveBrightness = 1.35,
  });

  /// Default palette, roughly matching the app's chart colours.
  factory ScenePalette.standard() {
    return ScenePalette(
      bullish: SceneColor.fromBytes(38, 166, 154),
      bearish: SceneColor.fromBytes(239, 83, 80),
      wick: SceneColor.fromBytes(150, 158, 170),
      selection: SceneColor.fromBytes(255, 214, 102),
    );
  }

  /// Creates a copy of this palette with the given fields replaced.
  ScenePalette copyWith({
    SceneColor? bullish,
    SceneColor? bearish,
    SceneColor? wick,
    SceneColor? selection,
    double? liveBrightness,
  }) {
    return ScenePalette(
      bullish: bullish ?? this.bullish,
      bearish: bearish ?? this.bearish,
      wick: wick ?? this.wick,
      selection: selection ?? this.selection,
      liveBrightness: liveBrightness ?? this.liveBrightness,
    );
  }

  @override
  List<Object?> get props =>
      [bullish, bearish, wick, selection, liveBrightness];
}

/// Geometry parameters for laying out the candle city.
@immutable
class SceneLayout extends Equatable {
  /// Width of a candle body along the x axis.
  final double blockWidth;

  /// Depth of a candle body along the z axis.
  final double blockDepth;

  /// Gap between two neighbouring candles along the x axis.
  final double spacing;

  /// Wick thickness, as a ratio of [blockWidth].
  final double wickThicknessRatio;

  /// Height of the scale prices are mapped onto.
  final double sceneHeight;

  /// Headroom added above and below the price range, as a ratio of the range.
  final double pricePaddingRatio;

  /// Minimum body height, so a doji still renders as a visible slab instead of
  /// a zero-height box the renderer may cull.
  final double minBodyHeight;

  /// Colours used for the generated geometry.
  final ScenePalette palette;

  const SceneLayout({
    this.blockWidth = 0.6,
    this.blockDepth = 0.6,
    this.spacing = 0.25,
    this.wickThicknessRatio = 0.18,
    this.sceneHeight = 10.0,
    this.pricePaddingRatio = 0.08,
    this.minBodyHeight = 0.02,
    required this.palette,
  });

  /// Default layout with the standard palette.
  factory SceneLayout.standard() =>
      SceneLayout(palette: ScenePalette.standard());

  /// Distance from one candle's centre to the next.
  double get slotWidth => blockWidth + spacing;

  /// Thickness of a wick in scene units.
  double get wickThickness => blockWidth * wickThicknessRatio;

  /// Total width occupied by [count] candles.
  double totalWidthFor(int count) {
    if (count <= 0) return 0;
    return count * blockWidth + (count - 1) * spacing;
  }

  /// Creates a copy of this layout with the given fields replaced.
  SceneLayout copyWith({
    double? blockWidth,
    double? blockDepth,
    double? spacing,
    double? wickThicknessRatio,
    double? sceneHeight,
    double? pricePaddingRatio,
    double? minBodyHeight,
    ScenePalette? palette,
  }) {
    return SceneLayout(
      blockWidth: blockWidth ?? this.blockWidth,
      blockDepth: blockDepth ?? this.blockDepth,
      spacing: spacing ?? this.spacing,
      wickThicknessRatio: wickThicknessRatio ?? this.wickThicknessRatio,
      sceneHeight: sceneHeight ?? this.sceneHeight,
      pricePaddingRatio: pricePaddingRatio ?? this.pricePaddingRatio,
      minBodyHeight: minBodyHeight ?? this.minBodyHeight,
      palette: palette ?? this.palette,
    );
  }

  @override
  List<Object?> get props => [
        blockWidth,
        blockDepth,
        spacing,
        wickThicknessRatio,
        sceneHeight,
        pricePaddingRatio,
        minBodyHeight,
        palette,
      ];
}
