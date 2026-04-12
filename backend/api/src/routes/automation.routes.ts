import type { Route, HandlerCtx } from '../router';
import { createRule, listRules, toggleRule, deleteRule } from '../services/automation.service';

async function handleCreate(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  const body = ctx.body as Record<string, unknown>;
  return createRule(userId, body as any);
}

async function handleList(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  return listRules(userId);
}

async function handleToggle(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  const { id } = ctx.pathParams;
  const body = ctx.body as Record<string, unknown>;
  const enabled = body.enabled === true;
  await toggleRule(userId, id, enabled);
  return { success: true };
}

async function handleDelete(ctx: HandlerCtx) {
  const userId = ctx.auth!.sub;
  const { id } = ctx.pathParams;
  await deleteRule(userId, id);
  return { success: true };
}

export const automationRoutes: Route[] = [
  {
    method: 'POST',
    path: '/api/v1/automation/rules',
    handler: handleCreate,
    requireAuth: true,
  },
  {
    method: 'GET',
    path: '/api/v1/automation/rules',
    handler: handleList,
    requireAuth: true,
  },
  {
    method: 'PUT',
    path: '/api/v1/automation/rules/:id',
    handler: handleToggle,
    requireAuth: true,
  },
  {
    method: 'DELETE',
    path: '/api/v1/automation/rules/:id',
    handler: handleDelete,
    requireAuth: true,
  },
];
