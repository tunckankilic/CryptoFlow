import type { Route } from '../router';
import { generateTaxReport, listTaxReports } from '../services/tax.service';
import type { TaxReportInput } from '../services/tax.service';

export const taxRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/tax/generate-report',
    requireAuth: true,
    handler: async (ctx) => {
      const input = ctx.body as TaxReportInput;
      return generateTaxReport(ctx.auth!.userId, input);
    },
  },
  {
    method: 'GET',
    path: '/api/v1/tax/reports',
    requireAuth: true,
    handler: async (ctx) => {
      return listTaxReports(ctx.auth!.userId);
    },
  },
];
