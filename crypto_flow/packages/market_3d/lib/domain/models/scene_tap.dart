import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// The result of a tap on the scene, reported by a renderer.
///
/// Carries only the block index so the presentation layer can look the candle
/// up in its own state — no engine entity ever crosses this boundary.
@immutable
class SceneTap extends Equatable {
  /// Index of the tapped candle, or `null` when empty space was tapped.
  final int? blockIndex;

  const SceneTap(this.blockIndex);

  /// A tap that hit nothing, used to dismiss the inspect panel.
  const SceneTap.miss() : blockIndex = null;

  /// Whether the tap hit a candle.
  bool get hitBlock => blockIndex != null;

  @override
  List<Object?> get props => [blockIndex];
}
