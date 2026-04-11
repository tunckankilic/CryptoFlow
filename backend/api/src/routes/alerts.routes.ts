import type { Route } from '../router';
import { ValidationError } from '../errors';
import {
  createAlert,
  listAlerts,
  updateAlert,
  deleteAlert,
} from '../services/alert.service';
import type { CreateAlertInput, UpdateAlertInput } from '../models/alert';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

export const alertsRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/alerts',
    requireAuth: true,
    handler: async (ctx) => createAlert(userId(ctx), ctx.body as CreateAlertInput),
  },
  {
    method: 'GET',
    path: '/api/v1/alerts',
    requireAuth: true,
    handler: async (ctx) => listAlerts(userId(ctx)),
  },
  {
    method: 'PUT',
    path: '/api/v1/alerts/:id',
    requireAuth: true,
    handler: async (ctx) =>
      updateAlert(userId(ctx), ctx.pathParams.id!, ctx.body as UpdateAlertInput),
  },
  {
    method: 'DELETE',
    path: '/api/v1/alerts/:id',
    requireAuth: true,
    handler: async (ctx) => {
      await deleteAlert(userId(ctx), ctx.pathParams.id!);
      return { ok: true };
    },
  },
];
