#!/usr/bin/env bash
# Build & deploy the cryptoflow-api Lambda. Usage: ./scripts/deploy.sh [env]
set -euo pipefail

ENV="${1:-dev}"
PROJECT="cryptoflow-${ENV}-api"
REGION="${AWS_REGION:-eu-central-1}"

cd "$(dirname "$0")/.."

echo "Building $PROJECT..."
npm run build

echo "Packaging..."
rm -f function.zip
(cd dist && zip -qr ../function.zip .)

echo "Deploying to $PROJECT in $REGION..."
aws lambda update-function-code \
  --function-name "$PROJECT" \
  --zip-file fileb://function.zip \
  --region "$REGION" \
  --no-cli-pager

echo "Deployed $PROJECT"
