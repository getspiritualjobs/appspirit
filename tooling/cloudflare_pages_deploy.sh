#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/env.sh"

: "${CLOUDFLARE_PAGES_PROJECT:=giftpath}"

export PATH="/Users/sethswanson/.local/flutter-sdk/flutter/bin:$PATH"

flutter build web --release --no-wasm-dry-run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
  --dart-define=STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-}"

BUILD_ID="$(git rev-parse --short HEAD 2>/dev/null || date +%s)"
BUILD_ID="${BUILD_ID}" node -e "
const fs = require('fs');
const file = 'build/web/flutter_bootstrap.js';
const buildId = process.env.BUILD_ID;
let source = fs.readFileSync(file, 'utf8');
source = source.replace(/\"mainJsPath\":\"main\\.dart\\.js(?:\\?v=[^\"]*)?\"/, '\"mainJsPath\":\"main.dart.js?v=' + buildId + '\"');
fs.writeFileSync(file, source);
"

NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-/tmp/giftpath-npm-cache}" \
npx --yes wrangler@4.123.0 pages deploy build/web \
  --project-name "${CLOUDFLARE_PAGES_PROJECT}" \
  --branch main
