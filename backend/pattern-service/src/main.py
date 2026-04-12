"""
CryptoFlow Pattern Recognition Service — FastAPI + Mangum (AWS Lambda)

Endpoints:
  GET /api/v1/patterns/{symbol} — detected chart patterns
  GET /api/v1/patterns/{symbol}/signals — trading signals
"""

import httpx
from fastapi import FastAPI, HTTPException
from mangum import Mangum

from .models.pattern import ChartPattern, TradingSignal
from .services.pattern_detector import detect_all_patterns, generate_signals

app = FastAPI(title="CryptoFlow Pattern Service", version="1.0.0")

BINANCE_API = "https://api.binance.com"


async def fetch_klines(symbol: str, interval: str = "1d", limit: int = 200) -> list[float]:
    """Fetch close prices from Binance public API."""
    url = f"{BINANCE_API}/api/v3/klines"
    params = {"symbol": symbol, "interval": interval, "limit": limit}

    async with httpx.AsyncClient() as client:
        resp = await client.get(url, params=params)
        if resp.status_code != 200:
            raise HTTPException(status_code=502, detail=f"Binance API error: {resp.status_code}")
        data = resp.json()

    # Index 4 = close price
    return [float(k[4]) for k in data]


@app.get("/health")
async def health():
    return {"status": "ok", "service": "pattern-service"}


@app.get("/api/v1/patterns/{symbol}", response_model=list[ChartPattern])
async def get_patterns(symbol: str, interval: str = "1d", limit: int = 200):
    """Detect chart patterns for a given symbol."""
    close_prices = await fetch_klines(symbol.upper(), interval, limit)
    patterns = detect_all_patterns(symbol.upper(), close_prices)
    return patterns


@app.get("/api/v1/patterns/{symbol}/signals", response_model=list[TradingSignal])
async def get_signals(symbol: str, interval: str = "1d", limit: int = 200):
    """Generate trading signals from detected patterns."""
    close_prices = await fetch_klines(symbol.upper(), interval, limit)
    patterns = detect_all_patterns(symbol.upper(), close_prices)
    signals = generate_signals(patterns)
    return signals


# AWS Lambda handler via Mangum
handler = Mangum(app, lifespan="off")
