import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'scene_color.dart';
import 'vec3.dart';

/// One candle rendered as two boxes: a body and a wick.
///
/// Everything a renderer needs to place geometry is precomputed here in scene
/// units. [index] is the stable identity of the block: it is the position of
/// the candle in the series, the key a renderer uses to update the live block
/// in place, and what a tap reports back so the UI can look up the original
/// [Candle] for the OHLC panel.
@immutable
class CandleBlock extends Equatable {
  /// Position of this candle in the series, oldest first.
  final int index;

  /// Open time of the source candle, used to correlate back to market data.
  final DateTime openTime;

  /// Centre of the body box.
  final Vec3 bodyCenter;

  /// Full extents of the body box.
  final Vec3 bodySize;

  /// Centre of the wick box.
  final Vec3 wickCenter;

  /// Full extents of the wick box.
  final Vec3 wickSize;

  /// Body colour, already brightened when [isLive].
  final SceneColor bodyColor;

  /// Wick colour.
  final SceneColor wickColor;

  /// Whether the source candle closed at or above its open.
  final bool isBullish;

  /// Whether this is the still-open candle receiving live updates.
  final bool isLive;

  const CandleBlock({
    required this.index,
    required this.openTime,
    required this.bodyCenter,
    required this.bodySize,
    required this.wickCenter,
    required this.wickSize,
    required this.bodyColor,
    required this.wickColor,
    required this.isBullish,
    required this.isLive,
  });

  /// Top of the wick — the scene height of the candle's high.
  double get top => wickCenter.y + wickSize.y / 2;

  /// Bottom of the wick — the scene height of the candle's low.
  double get bottom => wickCenter.y - wickSize.y / 2;

  /// Creates a copy of this block with the given fields replaced.
  CandleBlock copyWith({
    int? index,
    DateTime? openTime,
    Vec3? bodyCenter,
    Vec3? bodySize,
    Vec3? wickCenter,
    Vec3? wickSize,
    SceneColor? bodyColor,
    SceneColor? wickColor,
    bool? isBullish,
    bool? isLive,
  }) {
    return CandleBlock(
      index: index ?? this.index,
      openTime: openTime ?? this.openTime,
      bodyCenter: bodyCenter ?? this.bodyCenter,
      bodySize: bodySize ?? this.bodySize,
      wickCenter: wickCenter ?? this.wickCenter,
      wickSize: wickSize ?? this.wickSize,
      bodyColor: bodyColor ?? this.bodyColor,
      wickColor: wickColor ?? this.wickColor,
      isBullish: isBullish ?? this.isBullish,
      isLive: isLive ?? this.isLive,
    );
  }

  @override
  List<Object?> get props => [
        index,
        openTime,
        bodyCenter,
        bodySize,
        wickCenter,
        wickSize,
        bodyColor,
        wickColor,
        isBullish,
        isLive,
      ];
}
