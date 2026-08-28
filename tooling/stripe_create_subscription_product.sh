#!/usr/bin/env bash
set -euo pipefail

: "${STRIPE_SECRET_KEY:?Set STRIPE_SECRET_KEY from the Stripe Dashboard first.}"

if [[ "${STRIPE_SECRET_KEY}" != sk_live_* ]]; then
  echo "Refusing to create live Stripe products with a non-live secret key."
  echo "Set STRIPE_SECRET_KEY=sk_live_... when you are ready to go live."
  exit 1
fi

curl -fsS https://api.stripe.com/v1/products \
  -u "${STRIPE_SECRET_KEY}:" \
  -H "Stripe-Version: 2026-02-25.preview" \
  -d "name=GiftPath Full Access" \
  -d "description=Full access to GiftPath career lanes, live matched jobs, saved jobs, and ongoing exploration." \
  -d "tax_code=txcd_10103100" \
  -d "default_price_data[unit_amount]=777" \
  -d "default_price_data[currency]=usd" \
  -d "default_price_data[recurring][interval]=month"
