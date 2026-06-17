import type { Route } from '../router';
import { ValidationError } from '../errors';
import {
  createHolding,
  listHoldings,
  updateHolding,
  deleteHolding,
  createTransaction,
  listTransactions,
  buildSummary,
} from '../services/portfolio.service';
import type {
  CreateHoldingInput,
  UpdateHoldingInput,
  CreateTransactionInput,
} from '../models/portfolio';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

export const portfolioRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/portfolio/holdings',
    requireAuth: true,
    handler: async (ctx) =>
      createHolding(userId(ctx), ctx.body as CreateHoldingInput),
  },
  {
    method: 'GET',
    path: '/api/v1/portfolio/holdings',
    requireAuth: true,
    handler: async (ctx) => listHoldings(userId(ctx)),
  },
  {
    method: 'PUT',
    path: '/api/v1/portfolio/holdings/:id',
    requireAuth: true,
    handler: async (ctx) =>
      updateHolding(userId(ctx), ctx.pathParams.id!, ctx.body as UpdateHoldingInput),
  },
  {
    method: 'DELETE',
    path: '/api/v1/portfolio/holdings/:id',
    requireAuth: true,
    handler: async (ctx) => {
      await deleteHolding(userId(ctx), ctx.pathParams.id!);
      return { ok: true };
    },
  },
  {
    method: 'POST',
    path: '/api/v1/portfolio/transactions',
    requireAuth: true,
    handler: async (ctx) =>
      createTransaction(userId(ctx), ctx.body as CreateTransactionInput),
  },
  {
    method: 'GET',
    path: '/api/v1/portfolio/transactions',
    requireAuth: true,
    handler: async (ctx) => listTransactions(userId(ctx)),
  },
  {
    method: 'GET',
    path: '/api/v1/portfolio/summary',
    requireAuth: true,
    handler: async (ctx) => buildSummary(userId(ctx)),
  },
];
