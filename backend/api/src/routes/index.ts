import type { Route } from '../router';
import { healthRoutes } from './health.routes';
import { portfolioRoutes } from './portfolio.routes';
import { journalRoutes } from './journal.routes';
import { alertsRoutes } from './alerts.routes';
import { watchlistRoutes } from './watchlist.routes';
import { notificationsRoutes } from './notifications.routes';
import { widgetsRoutes } from './widgets.routes';
import { reportsRoutes } from './reports.routes';
import { analyticsRoutes } from './analytics.routes';
import { taxRoutes } from './tax.routes';
import { riskRoutes } from './risk.routes';
import { automationRoutes } from './automation.routes';

export const allRoutes: Route[] = [
  ...healthRoutes,
  ...portfolioRoutes,
  ...journalRoutes,
  ...alertsRoutes,
  ...watchlistRoutes,
  ...notificationsRoutes,
  ...widgetsRoutes,
  ...reportsRoutes,
  ...analyticsRoutes,
  ...taxRoutes,
  ...riskRoutes,
  ...automationRoutes,
];
