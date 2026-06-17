import type { Route } from '../router';
import { ValidationError } from '../errors';
import { generateReport, listReports } from '../services/report.service';
import type { GenerateReportInput } from '../services/report.service';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

export const reportsRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/reports/generate',
    requireAuth: true,
    handler: async (ctx) =>
      generateReport(userId(ctx), ctx.body as GenerateReportInput),
  },
  {
    method: 'GET',
    path: '/api/v1/reports',
    requireAuth: true,
    handler: async (ctx) => listReports(userId(ctx)),
  },
];
