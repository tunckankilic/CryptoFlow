import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A linear RGBA colour in scene space, each channel in the `0.0..1.0` range.
///
/// Kept independent of `dart:ui` so scene models stay renderable by any
/// engine and testable without a Flutter binding.
@immutable
class SceneColor extends Equatable {
  /// Red channel, `0.0..1.0`.
  final double r;

  /// Green channel, `0.0..1.0`.
  final double g;

  /// Blue channel, `0.0..1.0`.
  final double b;

  /// Alpha channel, `0.0..1.0`.
  final double a;

  const SceneColor(this.r, this.g, this.b, [this.a = 1.0]);

  /// Creates a colour from 8-bit channel values (`0..255`).
  factory SceneColor.fromBytes(int r, int g, int b, [int a = 255]) {
    return SceneColor(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
  }

  /// Creates a copy of this colour with the given fields replaced.
  SceneColor copyWith({double? r, double? g, double? b, double? a}) {
    return SceneColor(r ?? this.r, g ?? this.g, b ?? this.b, a ?? this.a);
  }

  /// Returns this colour with its RGB channels scaled by [factor].
  ///
  /// Used to brighten the live candle without introducing a second palette.
  SceneColor scaled(double factor) {
    return SceneColor(
      (r * factor).clamp(0.0, 1.0),
      (g * factor).clamp(0.0, 1.0),
      (b * factor).clamp(0.0, 1.0),
      a,
    );
  }

  @override
  List<Object?> get props => [r, g, b, a];
}
