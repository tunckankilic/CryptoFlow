function required(name: string): string {
  const v = process.env[name];
  if (!v || v.length === 0) throw new Error(`Missing required env var: ${name}`);
  return v;
}

export const config = {
  region: required('AWS_REGION_NAME'),
  ddb: {
    alerts: required('DDB_ALERTS'),
    wsConnections: required('DDB_WS_CONNECTIONS'),
  },
  snsTopicArn: required('SNS_NOTIFICATIONS_TOPIC'),
  wsApiEndpoint: required('WS_API_ENDPOINT'),
};
