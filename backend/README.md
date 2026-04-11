# CryptoFlow Backend (Faz 2 — Monolitik Lambda)

Three independent TypeScript Lambda projects deployed behind the API Gateway
and DynamoDB infrastructure managed by `infrastructure/`.

| Project | Lambda function | Trigger |
|---|---|---|
| `api/` | `cryptoflow-{env}-api` | API Gateway HTTP API (`ANY /{proxy+}`) |
| `ws-handler/` | `cryptoflow-{env}-ws-handler` | API Gateway WebSocket (`$connect`, `$disconnect`, `$default`) |
| `alert-checker/` | `cryptoflow-{env}-alert-checker` | EventBridge schedule (every 1 minute) |

Each project is fully self-contained — its own `package.json`, `tsconfig.json`,
`vitest.config.ts`, and deploy script. There is no shared workspace; the small
amount of duplicated code (config loader, logger, ddb client) is intentional
and keeps deploy zips small.

## Prerequisites

- Node.js 20+
- AWS CLI configured with permissions to update the three Lambda functions
- Terraform applied at least once so the placeholder Lambdas exist

## Common commands

From this directory:

```bash
make install      # npm install for all 3 projects
make typecheck    # tsc --noEmit for all 3 projects
make test         # vitest run for all 3 projects
make build        # esbuild bundle for all 3 projects
make deploy       # build + aws lambda update-function-code for all 3
make clean        # remove dist/ and function.zip
```

Per-project:

```bash
cd api && npm test
cd api && npm run deploy dev      # explicit env (defaults to dev)
```

## Architecture decisions

- **`esbuild`** bundles each Lambda into a single file (~5x smaller than `tsc`,
  faster cold starts). `@aws-sdk/*` is marked external — the runtime ships with
  it.
- **`aws-jwt-verify`** for Cognito JWT validation (built-in JWKS cache, fewer
  moving parts than `jsonwebtoken + jwks-rsa`).
- **Thin custom router** in `api/src/router.ts` instead of Express/Fastify, to
  avoid the cold-start cost of a full framework.
- **`@aws-sdk/lib-dynamodb`** DocumentClient v3 — automatic marshalling.
- **Structured JSON logging** via `console.log` — CloudWatch indexes it
  automatically; no logger library.
- **WebSocket auth** uses a `?token=...` query parameter on `$connect` because
  custom HTTP headers are not portable across native WebSocket clients.
- **Push notifications** are stubbed in Faz 2: `register-device` writes to
  DynamoDB but `CreatePlatformEndpoint` only fires when
  `SNS_APPLE_PLATFORM_APP_ARN` / `SNS_GOOGLE_PLATFORM_APP_ARN` env vars are set
  (manual APNs/FCM platform application step still pending).

## Environment variables (injected by Terraform)

```
AWS_REGION_NAME
NODE_ENV
COGNITO_USER_POOL_ID
COGNITO_CLIENT_ID
DDB_USERS, DDB_USER_SETTINGS, DDB_HOLDINGS, DDB_TRANSACTIONS,
DDB_JOURNAL, DDB_ALERTS, DDB_WATCHLIST, DDB_DEVICE_TOKENS, DDB_WS_CONNECTIONS
SNS_NOTIFICATIONS_TOPIC
REPORTS_BUCKET
WS_API_ENDPOINT
SNS_APPLE_PLATFORM_APP_ARN     # optional, set after manual APNs setup
SNS_GOOGLE_PLATFORM_APP_ARN    # optional, set after manual FCM setup
```

## Smoke testing

After `terraform apply` and `make deploy`:

```bash
# Health check (no auth)
curl https://{REST_API_ID}.execute-api.eu-central-1.amazonaws.com/dev/health

# Authenticated request — get a Cognito access token via Hosted UI first
TOKEN=eyJ...
curl -H "Authorization: Bearer $TOKEN" \
  https://{REST_API_ID}.execute-api.eu-central-1.amazonaws.com/dev/api/v1/portfolio/holdings

# WebSocket
wscat -c "wss://{WS_API_ID}.execute-api.eu-central-1.amazonaws.com/dev?token=$TOKEN"
```

Watch CloudWatch:

```
/aws/lambda/cryptoflow-dev-api
/aws/lambda/cryptoflow-dev-ws-handler
/aws/lambda/cryptoflow-dev-alert-checker
```
