import type { Route } from '../router';
import { getPerformanceAnalytics } from '../services/analytics.service';

export const analyticsRoutes: Route[] = [
  {
    method: 'GET',
    path: '/api/v1/analytics/performance',
    requireAuth: true,
    handler: async (ctx) => {
      const period = ctx.query.period ?? 'monthly';
      return getPerformanceAnalytics(ctx.auth!.userId, period);
    },
  },
];
