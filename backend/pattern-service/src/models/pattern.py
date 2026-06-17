"""Pattern recognition data models."""

from enum import Enum
from pydantic import BaseModel


class PatternType(str, Enum):
    DOUBLE_TOP = "double_top"
    DOUBLE_BOTTOM = "double_bottom"
    HEAD_AND_SHOULDERS = "head_and_shoulders"
    INVERSE_HEAD_AND_SHOULDERS = "inverse_head_and_shoulders"
    ASCENDING_TRIANGLE = "ascending_triangle"
    DESCENDING_TRIANGLE = "descending_triangle"
    SYMMETRICAL_TRIANGLE = "symmetrical_triangle"
    SUPPORT = "support"
    RESISTANCE = "resistance"


class SignalDirection(str, Enum):
    BULLISH = "bullish"
    BEARISH = "bearish"
    NEUTRAL = "neutral"


class ChartPattern(BaseModel):
    pattern_type: PatternType
    symbol: str
    start_index: int
    end_index: int
    confidence: float  # 0.0 - 1.0
    direction: SignalDirection
    key_levels: list[float]
    description: str


class TradingSignal(BaseModel):
    symbol: str
    direction: SignalDirection
    pattern_type: PatternType
    entry_price: float | None = None
    stop_loss: float | None = None
    take_profit: float | None = None
    confidence: float
    description: str
