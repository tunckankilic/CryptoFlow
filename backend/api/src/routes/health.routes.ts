import type { Route } from '../router';

export const healthRoutes: Route[] = [
  {
    method: 'GET',
    path: '/health',
    requireAuth: false,
    handler: async () => ({
      status: 'ok',
      time: new Date().toISOString(),
    }),
  },
];
