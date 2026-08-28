#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/env.sh"

: "${STRIPE_PUBLISHABLE_KEY:?Set STRIPE_PUBLISHABLE_KEY=pk_live_... in .env.local}"
: "${STRIPE_SECRET_KEY:?Set STRIPE_SECRET_KEY=sk_live_... in .env.local}"
: "${SUPABASE_URL:?Set SUPABASE_URL in .env.local}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY in .env.local}"

if [[ "${STRIPE_PUBLISHABLE_KEY}" != pk_live_* ]]; then
  echo "STRIPE_PUBLISHABLE_KEY is not live. Expected pk_live_..."
  exit 1
fi

if [[ "${STRIPE_SECRET_KEY}" != sk_live_* ]]; then
  echo "STRIPE_SECRET_KEY is not live. Expected sk_live_..."
  exit 1
fi

create_price() {
  local interval="$1"
  local amount="$2"
  local nickname="$3"

  curl -fsS https://api.stripe.com/v1/prices \
    -u "${STRIPE_SECRET_KEY}:" \
    -H "Stripe-Version: 2026-02-25.preview" \
    -d "currency=usd" \
    -d "unit_amount=${amount}" \
    -d "recurring[interval]=${interval}" \
    -d "product_data[name]=GiftPath Full Access" \
    -d "product_data[description]=Full access to GiftPath career lanes, live matched jobs, saved jobs, and ongoing exploration." \
    -d "product_data[tax_code]=txcd_10103100" \
    -d "nickname=${nickname}" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])'
}

if [[ -z "${STRIPE_MONTHLY_PRICE_ID:-}" ]]; then
  echo "Creating live monthly Stripe price..."
  STRIPE_MONTHLY_PRICE_ID="$(create_price month 777 'GiftPath monthly')"
  echo "Created monthly price."
fi

if [[ -z "${STRIPE_YEARLY_PRICE_ID:-}" ]]; then
  echo "Creating live yearly Stripe price..."
  STRIPE_YEARLY_PRICE_ID="$(create_price year 7777 'GiftPath yearly')"
  echo "Created yearly price."
fi

if [[ "${STRIPE_MONTHLY_PRICE_ID}" != price_* ]]; then
  echo "STRIPE_MONTHLY_PRICE_ID must start with price_"
  exit 1
fi

if [[ "${STRIPE_YEARLY_PRICE_ID}" != price_* ]]; then
  echo "STRIPE_YEARLY_PRICE_ID must start with price_"
  exit 1
fi

if [[ -z "${STRIPE_WEBHOOK_SECRET:-}" ]]; then
  cat <<'TEXT'
Missing STRIPE_WEBHOOK_SECRET.

Create a LIVE Stripe webhook endpoint:
  https://nigdwvzpmgngsygkbfgd.supabase.co/functions/v1/stripe-webhook

Events:
  checkout.session.completed
  customer.subscription.created
  customer.subscription.updated
  customer.subscription.deleted
  invoice.payment_succeeded
  invoice.payment_failed

Then add STRIPE_WEBHOOK_SECRET=whsec_... to .env.local and rerun this script.
TEXT
  exit 1
fi

if [[ "${STRIPE_WEBHOOK_SECRET}" != whsec_* ]]; then
  echo "STRIPE_WEBHOOK_SECRET should start with whsec_"
  exit 1
fi

echo "Updating Supabase Stripe secrets..."
npx --yes supabase@latest secrets set \
  --project-ref nigdwvzpmgngsygkbfgd \
  STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY}" \
  STRIPE_PRICE_ID="${STRIPE_MONTHLY_PRICE_ID}" \
  STRIPE_MONTHLY_PRICE_ID="${STRIPE_MONTHLY_PRICE_ID}" \
  STRIPE_YEARLY_PRICE_ID="${STRIPE_YEARLY_PRICE_ID}" \
  STRIPE_WEBHOOK_SECRET="${STRIPE_WEBHOOK_SECRET}"

echo "Deploying Stripe Edge Functions..."
npx --yes supabase@latest functions deploy create-checkout-session \
  --project-ref nigdwvzpmgngsygkbfgd
npx --yes supabase@latest functions deploy create-billing-portal \
  --project-ref nigdwvzpmgngsygkbfgd
npx --yes supabase@latest functions deploy stripe-webhook \
  --project-ref nigdwvzpmgngsygkbfgd

echo "Live Stripe server config is installed."
echo "Monthly price: ${STRIPE_MONTHLY_PRICE_ID}"
echo "Yearly price: ${STRIPE_YEARLY_PRICE_ID}"
echo "Next: deploy the Flutter app with STRIPE_PUBLISHABLE_KEY=pk_live_..."
