import type { Route } from '../router';
import { ValidationError } from '../errors';
import {
  createEntry,
  listEntries,
  updateEntry,
  deleteEntry,
  computeStats,
} from '../services/journal.service';
import type { CreateJournalInput, UpdateJournalInput } from '../models/journal';

function userId(ctx: { auth: { userId: string } | null }): string {
  if (!ctx.auth) throw new ValidationError('auth required');
  return ctx.auth.userId;
}

export const journalRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/journal/entries',
    requireAuth: true,
    handler: async (ctx) => createEntry(userId(ctx), ctx.body as CreateJournalInput),
  },
  {
    method: 'GET',
    path: '/api/v1/journal/entries',
    requireAuth: true,
    handler: async (ctx) => listEntries(userId(ctx)),
  },
  {
    method: 'PUT',
    path: '/api/v1/journal/entries/:id',
    requireAuth: true,
    handler: async (ctx) =>
      updateEntry(userId(ctx), ctx.pathParams.id!, ctx.body as UpdateJournalInput),
  },
  {
    method: 'DELETE',
    path: '/api/v1/journal/entries/:id',
    requireAuth: true,
    handler: async (ctx) => {
      await deleteEntry(userId(ctx), ctx.pathParams.id!);
      return { ok: true };
    },
  },
  {
    method: 'GET',
    path: '/api/v1/journal/stats',
    requireAuth: true,
    handler: async (ctx) => {
      const period = (ctx.query.period as 'weekly' | 'monthly' | 'all' | undefined) ?? 'monthly';
      return computeStats(userId(ctx), period);
    },
  },
];
