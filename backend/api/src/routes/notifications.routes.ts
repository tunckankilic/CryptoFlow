import type { Route } from '../router';
import { ValidationError } from '../errors';
import {
  registerDevice,
  unregisterDevice,
  getPreferences,
  updatePreferences,
} from '../services/notification.service';
import type {
  NotificationPreferences,
} from '../models/notification';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

interface RegisterBody {
  deviceId: string;
  token: string;
  platform: 'ios' | 'android';
}

interface UnregisterBody {
  deviceId: string;
}

export const notificationsRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/notifications/register-device',
    requireAuth: true,
    handler: async (ctx) => registerDevice(userId(ctx), ctx.body as RegisterBody),
  },
  {
    method: 'DELETE',
    path: '/api/v1/notifications/unregister-device',
    requireAuth: true,
    handler: async (ctx) => {
      const body = (ctx.body ?? {}) as UnregisterBody;
      await unregisterDevice(userId(ctx), body.deviceId);
      return { ok: true };
    },
  },
  {
    method: 'GET',
    path: '/api/v1/notifications/preferences',
    requireAuth: true,
    handler: async (ctx) => getPreferences(userId(ctx)),
  },
  {
    method: 'PUT',
    path: '/api/v1/notifications/preferences',
    requireAuth: true,
    handler: async (ctx) =>
      updatePreferences(userId(ctx), ctx.body as Partial<NotificationPreferences>),
  },
];
