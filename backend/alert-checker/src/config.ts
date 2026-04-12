function required(name: string): string {
  const v = process.env[name];
  if (!v || v.length === 0) throw new Error(`Missing required env var: ${name}`);
  return v;
}

function optional(name: string, fallback: string): string {
  const v = process.env[name];
  return v && v.length > 0 ? v : fallback;
}

export const config = {
  region: required('AWS_REGION_NAME'),
  ddb: {
    alerts: required('DDB_ALERTS'),
    wsConnections: required('DDB_WS_CONNECTIONS'),
    automationRules: optional('DDB_AUTOMATION_RULES', 'automation-rules'),
    watchlist: optional('DDB_WATCHLIST', 'watchlist'),
  },
  snsTopicArn: required('SNS_NOTIFICATIONS_TOPIC'),
  wsApiEndpoint: required('WS_API_ENDPOINT'),
};
