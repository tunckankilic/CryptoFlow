import 'package:flutter/material.dart';
import 'package:market/market.dart';

/// Overlay panel showing the OHLC detail of the tapped candle.
///
/// Plain Flutter over the viewport, deliberately not a 3D label: text drawn by
/// the engine would have to fight the perspective projection for legibility,
/// and the whole point of the tap is that the same `Candle` entity feeding the
/// geometry also feeds a normal widget.
///
/// Local to this package rather than a `design_system` molecule — it is
/// specific to the 3D tab's dark viewport, and nothing else needs it yet.
class CandleInspectPanel extends StatelessWidget {
  const CandleInspectPanel({
    super.key,
    required this.symbol,
    required this.interval,
    required this.candle,
    required this.isLive,
    required this.onDismiss,
  });

  /// Trading pair the candle belongs to, e.g. `BTCUSDT`.
  final String symbol;

  /// Candle interval, e.g. `1m`.
  final String interval;

  /// The selected candle.
  final Candle candle;

  /// Whether this is the still-open candle receiving live updates.
  final bool isLive;

  /// Called when the user closes the panel.
  final VoidCallback onDismiss;

  static const Color _bullish = Color(0xFF26A69A);
  static const Color _bearish = Color(0xFFEF5350);
  static const Color _muted = Color(0xFF96A0AA);

  @override
  Widget build(BuildContext context) {
    final directionColor = candle.isBullish ? _bullish : _bearish;
    final change = candle.changePercent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF141821).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD666), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$symbol · $interval',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLive) ...[
                            const SizedBox(width: 8),
                            const _LiveDot(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(candle.openTime),
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 18),
                  color: _muted,
                  tooltip: 'Dismiss',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Metric('Open', _formatPrice(candle.open))),
                Expanded(child: _Metric('High', _formatPrice(candle.high))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Metric('Low', _formatPrice(candle.low))),
                Expanded(
                  child: _Metric(
                    'Close',
                    _formatPrice(candle.close),
                    valueColor: directionColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Metric('Volume', _formatVolume(candle.volume))),
                Expanded(
                  child: _Metric(
                    'Change',
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                    valueColor: directionColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Prices are quoted against USDT here, so two decimals reads right for BTC
  /// and still shows movement on cheaper pairs down to a cent.
  static String _formatPrice(double value) => value.toStringAsFixed(2);

  /// Base-asset volume, abbreviated — a 1m BTC candle is single-digit BTC, an
  /// hourly one can be thousands, and neither wants six decimal places.
  static String _formatVolume(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(2)}K';
    return value.toStringAsFixed(3);
  }

  /// `dd.MM HH:mm` in local time, hand-formatted rather than pulling `intl`
  /// into this package for one label.
  static String _formatTime(DateTime time) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

/// One labelled value in the panel's grid.
class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.valueColor = Colors.white});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: CandleInspectPanel._muted,
            fontSize: 10,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// The "still open" marker next to the symbol.
class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(
          width: 6,
          height: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(
          'open',
          style: TextStyle(color: Colors.greenAccent, fontSize: 11),
        ),
      ],
    );
  }
}
