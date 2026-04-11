import type { Route } from '../router';
import { ValidationError } from '../errors';
import {
  getPortfolioSummaryWidget,
  getWatchlistSummaryWidget,
} from '../services/widget.service';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

export const widgetsRoutes: Route[] = [
  {
    method: 'GET',
    path: '/api/v1/widgets/portfolio-summary',
    requireAuth: true,
    handler: async (ctx) => getPortfolioSummaryWidget(userId(ctx)),
  },
  {
    method: 'GET',
    path: '/api/v1/widgets/watchlist-summary',
    requireAuth: true,
    handler: async (ctx) => getWatchlistSummaryWidget(userId(ctx)),
  },
];
