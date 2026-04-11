// Vitest global setup — populate the env vars that ../src/config.ts requires
// so importing services in tests does not throw at module load.
process.env.AWS_REGION_NAME ??= 'eu-central-1';
process.env.NODE_ENV ??= 'test';
process.env.COGNITO_USER_POOL_ID ??= 'eu-central-1_test1234';
process.env.COGNITO_CLIENT_ID ??= 'testclientid';
process.env.DDB_USERS ??= 'users-test';
process.env.DDB_USER_SETTINGS ??= 'user-settings-test';
process.env.DDB_HOLDINGS ??= 'portfolio-holdings-test';
process.env.DDB_TRANSACTIONS ??= 'portfolio-transactions-test';
process.env.DDB_JOURNAL ??= 'journal-entries-test';
process.env.DDB_ALERTS ??= 'alerts-test';
process.env.DDB_WATCHLIST ??= 'watchlist-test';
process.env.DDB_DEVICE_TOKENS ??= 'device-tokens-test';
process.env.DDB_WS_CONNECTIONS ??= 'ws-connections-test';
process.env.SNS_NOTIFICATIONS_TOPIC ??= 'arn:aws:sns:eu-central-1:000000000000:test';
process.env.REPORTS_BUCKET ??= 'cryptoflow-reports-test';
process.env.WS_API_ENDPOINT ??= 'https://test.execute-api.eu-central-1.amazonaws.com/test';
