function required(name: string): string {
  const v = process.env[name];
  if (!v || v.length === 0) throw new Error(`Missing required env var: ${name}`);
  return v;
}

export const config = {
  region: required('AWS_REGION_NAME'),
  cognito: {
    userPoolId: required('COGNITO_USER_POOL_ID'),
    clientId: required('COGNITO_CLIENT_ID'),
  },
  ddb: {
    wsConnections: required('DDB_WS_CONNECTIONS'),
  },
};
