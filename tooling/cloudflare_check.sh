#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/env.sh"

curl -fsS "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json"

printf "\n"
