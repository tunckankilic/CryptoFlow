function required(name: string): string {
  const v = process.env[name];
  if (!v || v.length === 0) {
    throw new Error(`Missing required env var: ${name}`);
  }
  return v;
}

function optional(name: string): string | undefined {
  const v = process.env[name];
  return v && v.length > 0 ? v : undefined;
}

export const config = {
  region: required('AWS_REGION_NAME'),
  environment: process.env.NODE_ENV ?? 'dev',
  cognito: {
    userPoolId: required('COGNITO_USER_POOL_ID'),
    clientId: required('COGNITO_CLIENT_ID'),
  },
  ddb: {
    users: required('DDB_USERS'),
    userSettings: required('DDB_USER_SETTINGS'),
    holdings: required('DDB_HOLDINGS'),
    transactions: required('DDB_TRANSACTIONS'),
    journal: required('DDB_JOURNAL'),
    alerts: required('DDB_ALERTS'),
    watchlist: required('DDB_WATCHLIST'),
    deviceTokens: required('DDB_DEVICE_TOKENS'),
    wsConnections: required('DDB_WS_CONNECTIONS'),
    automationRules: optional('DDB_AUTOMATION_RULES') ?? 'automation-rules',
  },
  snsTopicArn: required('SNS_NOTIFICATIONS_TOPIC'),
  reportsBucket: required('REPORTS_BUCKET'),
  wsApiEndpoint: required('WS_API_ENDPOINT'),
  snsApplePlatformAppArn: required('SNS_APPLE_PLATFORM_APP_ARN'),
};

export type Config = typeof config;
