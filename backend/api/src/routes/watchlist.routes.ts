import type { Route } from '../router';
import { ValidationError } from '../errors';
import {
  addItem,
  listItems,
  removeItem,
  reorder,
} from '../services/watchlist.service';
import type { ReorderInput } from '../models/watchlist';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

interface AddBody {
  symbol: string;
  order?: number;
}

export const watchlistRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/watchlist',
    requireAuth: true,
    handler: async (ctx) => {
      const body = ctx.body as AddBody;
      return addItem(userId(ctx), body.symbol, body.order ?? 0);
    },
  },
  {
    method: 'GET',
    path: '/api/v1/watchlist',
    requireAuth: true,
    handler: async (ctx) => listItems(userId(ctx)),
  },
  {
    method: 'PUT',
    path: '/api/v1/watchlist/reorder',
    requireAuth: true,
    handler: async (ctx) => {
      await reorder(userId(ctx), ctx.body as ReorderInput);
      return { ok: true };
    },
  },
  {
    method: 'DELETE',
    path: '/api/v1/watchlist/:symbol',
    requireAuth: true,
    handler: async (ctx) => {
      await removeItem(userId(ctx), ctx.pathParams.symbol!);
      return { ok: true };
    },
  },
];
