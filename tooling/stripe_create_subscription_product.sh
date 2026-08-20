#!/usr/bin/env bash
set -euo pipefail

: "${STRIPE_SECRET_KEY:?Set STRIPE_SECRET_KEY from the Stripe Dashboard first.}"

curl -fsS https://api.stripe.com/v1/products \
  -u "${STRIPE_SECRET_KEY}:" \
  -H "Stripe-Version: 2026-02-25.preview" \
  -d "name=Basic subscription" \
  -d "description=A basic subscription to our service" \
  -d "tax_code=txcd_10103100" \
  -d "default_price_data[unit_amount]=1000" \
  -d "default_price_data[currency]=usd" \
  -d "default_price_data[recurring][interval]=month"
