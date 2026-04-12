import type { Route, HandlerCtx } from '../router';
import {
  calculatePositionSize,
  getCorrelationMatrix,
  calculateVaR,
} from '../services/risk.service';

async function handlePositionSize(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  const q = ctx.query;

  const accountSize = parseFloat(q.accountSize ?? '0');
  const riskPercentage = parseFloat(q.riskPercentage ?? '1');
  const entryPrice = parseFloat(q.entryPrice ?? '0');
  const stopLossPrice = parseFloat(q.stopLossPrice ?? '0');
  const symbol = q.symbol ?? '';

  if (!symbol || accountSize <= 0 || entryPrice <= 0) {
    return {
      statusCode: 400,
      body: { error: 'symbol, accountSize, and entryPrice are required' },
    };
  }

  return calculatePositionSize(accountSize, riskPercentage, entryPrice, stopLossPrice, symbol);
}

async function handleCorrelation(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  const period = ctx.query.period ?? 'monthly';
  return getCorrelationMatrix(userId, period);
}

async function handleVaR(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  const confidence = parseFloat(ctx.query.confidence ?? '95');
  const holdingPeriodDays = parseInt(ctx.query.holdingPeriodDays ?? '1', 10);
  return calculateVaR(userId, confidence, holdingPeriodDays);
}

export const riskRoutes: Route[] = [
  {
    method: 'GET',
    path: '/api/v1/risk/position-size',
    handler: handlePositionSize,
    requireAuth: true,
  },
  {
    method: 'GET',
    path: '/api/v1/risk/correlation',
    handler: handleCorrelation,
    requireAuth: true,
  },
  {
    method: 'GET',
    path: '/api/v1/risk/var',
    handler: handleVaR,
    requireAuth: true,
  },
];
