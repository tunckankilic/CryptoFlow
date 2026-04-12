"""
Rule-based chart pattern detection using scipy peak/trough analysis.
No ML — purely algorithmic pattern recognition.
"""

import numpy as np
from scipy.signal import argrelextrema

from ..models.pattern import (
    ChartPattern,
    PatternType,
    SignalDirection,
    TradingSignal,
)


def find_peaks_troughs(
    prices: np.ndarray, order: int = 5
) -> tuple[np.ndarray, np.ndarray]:
    """Find local maxima (peaks) and minima (troughs) in price data."""
    peaks = argrelextrema(prices, np.greater, order=order)[0]
    troughs = argrelextrema(prices, np.less, order=order)[0]
    return peaks, troughs


def detect_double_top(
    symbol: str, prices: np.ndarray, peaks: np.ndarray, tolerance: float = 0.02
) -> list[ChartPattern]:
    """Detect double top patterns: two peaks at similar levels with a valley between."""
    patterns = []
    for i in range(len(peaks) - 1):
        p1, p2 = peaks[i], peaks[i + 1]
        price1, price2 = prices[p1], prices[p2]

        if abs(price1 - price2) / price1 <= tolerance:
            valley = prices[p1:p2].min()
            avg_peak = (price1 + price2) / 2
            if (avg_peak - valley) / avg_peak > 0.03:  # Min 3% depth
                patterns.append(
                    ChartPattern(
                        pattern_type=PatternType.DOUBLE_TOP,
                        symbol=symbol,
                        start_index=int(p1),
                        end_index=int(p2),
                        confidence=1.0 - abs(price1 - price2) / price1,
                        direction=SignalDirection.BEARISH,
                        key_levels=[float(avg_peak), float(valley)],
                        description=f"Double top at {avg_peak:.2f}, neckline at {valley:.2f}",
                    )
                )
    return patterns


def detect_double_bottom(
    symbol: str, prices: np.ndarray, troughs: np.ndarray, tolerance: float = 0.02
) -> list[ChartPattern]:
    """Detect double bottom patterns: two troughs at similar levels."""
    patterns = []
    for i in range(len(troughs) - 1):
        t1, t2 = troughs[i], troughs[i + 1]
        price1, price2 = prices[t1], prices[t2]

        if abs(price1 - price2) / price1 <= tolerance:
            peak = prices[t1:t2].max()
            avg_trough = (price1 + price2) / 2
            if (peak - avg_trough) / avg_trough > 0.03:
                patterns.append(
                    ChartPattern(
                        pattern_type=PatternType.DOUBLE_BOTTOM,
                        symbol=symbol,
                        start_index=int(t1),
                        end_index=int(t2),
                        confidence=1.0 - abs(price1 - price2) / price1,
                        direction=SignalDirection.BULLISH,
                        key_levels=[float(avg_trough), float(peak)],
                        description=f"Double bottom at {avg_trough:.2f}, neckline at {peak:.2f}",
                    )
                )
    return patterns


def detect_head_and_shoulders(
    symbol: str, prices: np.ndarray, peaks: np.ndarray, tolerance: float = 0.02
) -> list[ChartPattern]:
    """Detect head and shoulders: left shoulder, higher head, right shoulder."""
    patterns = []
    for i in range(len(peaks) - 2):
        left, head, right = peaks[i], peaks[i + 1], peaks[i + 2]
        pl, ph, pr = prices[left], prices[head], prices[right]

        # Head must be highest, shoulders roughly equal
        if ph > pl and ph > pr and abs(pl - pr) / pl <= tolerance:
            neckline = min(
                prices[left:head].min(), prices[head:right].min()
            )
            patterns.append(
                ChartPattern(
                    pattern_type=PatternType.HEAD_AND_SHOULDERS,
                    symbol=symbol,
                    start_index=int(left),
                    end_index=int(right),
                    confidence=min(1.0, (ph - max(pl, pr)) / ph * 10),
                    direction=SignalDirection.BEARISH,
                    key_levels=[float(pl), float(ph), float(pr), float(neckline)],
                    description=f"H&S: head at {ph:.2f}, shoulders at ~{(pl+pr)/2:.2f}",
                )
            )
    return patterns


def detect_triangles(
    symbol: str,
    prices: np.ndarray,
    peaks: np.ndarray,
    troughs: np.ndarray,
) -> list[ChartPattern]:
    """Detect triangle patterns: ascending, descending, symmetrical."""
    patterns = []
    if len(peaks) < 2 or len(troughs) < 2:
        return patterns

    # Check if peaks are converging with troughs
    last_peaks = peaks[-3:] if len(peaks) >= 3 else peaks
    last_troughs = troughs[-3:] if len(troughs) >= 3 else troughs

    peak_prices = prices[last_peaks]
    trough_prices = prices[last_troughs]

    peaks_declining = len(peak_prices) >= 2 and peak_prices[-1] < peak_prices[0]
    troughs_rising = len(trough_prices) >= 2 and trough_prices[-1] > trough_prices[0]
    peaks_flat = len(peak_prices) >= 2 and abs(peak_prices[-1] - peak_prices[0]) / peak_prices[0] < 0.02
    troughs_flat = len(trough_prices) >= 2 and abs(trough_prices[-1] - trough_prices[0]) / trough_prices[0] < 0.02

    start_idx = int(min(last_peaks[0], last_troughs[0]))
    end_idx = int(max(last_peaks[-1], last_troughs[-1]))

    if peaks_flat and troughs_rising:
        patterns.append(
            ChartPattern(
                pattern_type=PatternType.ASCENDING_TRIANGLE,
                symbol=symbol,
                start_index=start_idx,
                end_index=end_idx,
                confidence=0.7,
                direction=SignalDirection.BULLISH,
                key_levels=[float(peak_prices[-1]), float(trough_prices[-1])],
                description="Ascending triangle — bullish continuation",
            )
        )
    elif troughs_flat and peaks_declining:
        patterns.append(
            ChartPattern(
                pattern_type=PatternType.DESCENDING_TRIANGLE,
                symbol=symbol,
                start_index=start_idx,
                end_index=end_idx,
                confidence=0.7,
                direction=SignalDirection.BEARISH,
                key_levels=[float(peak_prices[-1]), float(trough_prices[-1])],
                description="Descending triangle — bearish continuation",
            )
        )
    elif peaks_declining and troughs_rising:
        patterns.append(
            ChartPattern(
                pattern_type=PatternType.SYMMETRICAL_TRIANGLE,
                symbol=symbol,
                start_index=start_idx,
                end_index=end_idx,
                confidence=0.6,
                direction=SignalDirection.NEUTRAL,
                key_levels=[float(peak_prices[-1]), float(trough_prices[-1])],
                description="Symmetrical triangle — breakout expected",
            )
        )

    return patterns


def detect_support_resistance(
    symbol: str, prices: np.ndarray, peaks: np.ndarray, troughs: np.ndarray
) -> list[ChartPattern]:
    """Identify key support and resistance levels."""
    patterns = []
    current_price = float(prices[-1])

    # Resistance: cluster of peaks near each other
    if len(peaks) >= 2:
        peak_prices = sorted(prices[peaks], reverse=True)
        resistance = float(np.mean(peak_prices[:3]))
        if resistance > current_price:
            patterns.append(
                ChartPattern(
                    pattern_type=PatternType.RESISTANCE,
                    symbol=symbol,
                    start_index=int(peaks[0]),
                    end_index=int(peaks[-1]),
                    confidence=0.8,
                    direction=SignalDirection.BEARISH,
                    key_levels=[resistance],
                    description=f"Resistance level at {resistance:.2f}",
                )
            )

    # Support: cluster of troughs
    if len(troughs) >= 2:
        trough_prices = sorted(prices[troughs])
        support = float(np.mean(trough_prices[:3]))
        if support < current_price:
            patterns.append(
                ChartPattern(
                    pattern_type=PatternType.SUPPORT,
                    symbol=symbol,
                    start_index=int(troughs[0]),
                    end_index=int(troughs[-1]),
                    confidence=0.8,
                    direction=SignalDirection.BULLISH,
                    key_levels=[support],
                    description=f"Support level at {support:.2f}",
                )
            )

    return patterns


def detect_all_patterns(symbol: str, close_prices: list[float]) -> list[ChartPattern]:
    """Run all pattern detectors on the given price data."""
    if len(close_prices) < 20:
        return []

    prices = np.array(close_prices)
    peaks, troughs = find_peaks_troughs(prices, order=5)

    patterns: list[ChartPattern] = []
    patterns.extend(detect_double_top(symbol, prices, peaks))
    patterns.extend(detect_double_bottom(symbol, prices, troughs))
    patterns.extend(detect_head_and_shoulders(symbol, prices, peaks))
    patterns.extend(detect_triangles(symbol, prices, peaks, troughs))
    patterns.extend(detect_support_resistance(symbol, prices, peaks, troughs))

    # Sort by confidence descending
    patterns.sort(key=lambda p: p.confidence, reverse=True)
    return patterns


def generate_signals(patterns: list[ChartPattern]) -> list[TradingSignal]:
    """Generate trading signals from detected patterns."""
    signals: list[TradingSignal] = []
    for p in patterns:
        if p.confidence < 0.5:
            continue

        signal = TradingSignal(
            symbol=p.symbol,
            direction=p.direction,
            pattern_type=p.pattern_type,
            confidence=p.confidence,
            description=p.description,
        )

        # Set entry/stop/target based on pattern type and key levels
        if p.direction == SignalDirection.BULLISH and len(p.key_levels) >= 2:
            signal.entry_price = p.key_levels[1]  # breakout level
            signal.stop_loss = p.key_levels[0] * 0.98  # below support
            signal.take_profit = p.key_levels[1] + (p.key_levels[1] - p.key_levels[0])
        elif p.direction == SignalDirection.BEARISH and len(p.key_levels) >= 2:
            signal.entry_price = p.key_levels[1]  # breakdown level
            signal.stop_loss = p.key_levels[0] * 1.02  # above resistance
            signal.take_profit = p.key_levels[1] - (p.key_levels[0] - p.key_levels[1])

        signals.append(signal)

    return signals
