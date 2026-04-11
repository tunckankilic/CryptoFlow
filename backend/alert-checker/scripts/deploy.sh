#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-dev}"
PROJECT="cryptoflow-${ENV}-alert-checker"
REGION="${AWS_REGION:-eu-central-1}"
cd "$(dirname "$0")/.."
npm run build
rm -f function.zip
(cd dist && zip -qr ../function.zip .)
aws lambda update-function-code \
  --function-name "$PROJECT" \
  --zip-file fileb://function.zip \
  --region "$REGION" \
  --no-cli-pager
echo "Deployed $PROJECT"
