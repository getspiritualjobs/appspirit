# GiftPath: Spiritual Gifts + Career Discovery

A Flutter web MVP that helps Christians take a Scripture-informed spiritual gifts assessment, understand their strongest gift alignments, explore career matches, and review job opportunities.

The product intentionally avoids claims like "God wants you to become..." or "this is God's calling." Results are framed as reflection and vocational exploration.

## Current Status

- Flutter web app scaffold with routes for Home, Assessment, Results, Careers, Opportunities, Saved, About, and Account.
- Local deterministic scoring with 56 weighted questions and the seven Romans 12 gifts.
- Structured career matching with 100+ seeded careers in `lib/data/seed_data.dart`.
- Supabase Auth with email/password, Google sign-in, anonymous guest sessions, password reset, and private saved data.
- Supabase persistence for completed assessments, all question responses, gift scores, saved results, saved careers, saved jobs, and search preferences.
- Supabase Edge Functions for live job search through Adzuna and USAJOBS, with demo fallback when providers return no matches.
- Stripe Checkout subscriptions with `$7.77/month` and `$77.77/year` plans, one free matched job, and webhook-driven subscription state.
- Cloudflare Pages deployment for `giftpath.app`.
- No orders, no followers, no social feed.

## Prerequisites

This repo uses a local Flutter SDK at:

```bash
/Users/sethswanson/.local/flutter-sdk/flutter/bin/flutter
```

Run locally:

```bash
/Users/sethswanson/.local/flutter-sdk/flutter/bin/flutter pub get
/Users/sethswanson/.local/flutter-sdk/flutter/bin/flutter run -d chrome --dart-define-from-file=.env.local
```

## Supabase

Project URL:

```text
https://nigdwvzpmgngsygkbfgd.supabase.co
```

Core setup:

1. Enable Email Auth.
2. Configure Google OAuth in Supabase Auth providers.
3. Enable Anonymous Auth.
4. Add redirect URLs for local and production:
   - `http://localhost:*`
   - `http://localhost:*/auth`
   - `https://giftpath.app`
   - `https://giftpath.app/auth`
   - `https://*.giftpath.pages.dev`
   - `https://*.giftpath.pages.dev/auth`
5. Apply migrations in `supabase/migrations`.
6. Deploy Edge Functions.
7. Set Edge Function secrets.

Useful commands:

```bash
NPM_CONFIG_CACHE=/tmp/giftpath-npm-cache npx --yes supabase@latest db push --project-ref nigdwvzpmgngsygkbfgd
NPM_CONFIG_CACHE=/tmp/giftpath-npm-cache npx --yes supabase@latest functions deploy search-jobs --project-ref nigdwvzpmgngsygkbfgd
NPM_CONFIG_CACHE=/tmp/giftpath-npm-cache npx --yes supabase@latest functions deploy create-checkout-session --project-ref nigdwvzpmgngsygkbfgd
NPM_CONFIG_CACHE=/tmp/giftpath-npm-cache npx --yes supabase@latest functions deploy stripe-webhook --project-ref nigdwvzpmgngsygkbfgd
```

Job API secrets:

```bash
supabase secrets set ADZUNA_APP_ID=...
supabase secrets set ADZUNA_APP_KEY=...
supabase secrets set USAJOBS_API_KEY=...
supabase secrets set USAJOBS_USER_AGENT=get.spiritual.jobs@gmail.com
```

Configure Supabase SMTP before real users so verification and password reset emails come from a GiftPath-controlled sender instead of a generic Supabase sender.

## Stripe Subscriptions

GiftPath uses Supabase Edge Functions to create Stripe Checkout Sessions. The Flutter client never receives the Stripe secret key.

Create subscription prices in Stripe:

- Monthly: `$7.77` recurring monthly
- Yearly: `$77.77` recurring yearly

The helper script creates an older single-price test product. V1 uses both plan-specific price IDs from the Stripe Dashboard or Stripe API.

```bash
export STRIPE_SECRET_KEY=sk_test_...
bash tooling/stripe_create_subscription_product.sh
```

Set Edge Function secrets:

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
supabase secrets set STRIPE_MONTHLY_PRICE_ID=price_...
supabase secrets set STRIPE_YEARLY_PRICE_ID=price_...
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
```

Deploy the billing functions:

```bash
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook
```

Configure the Stripe webhook endpoint to:

```text
https://nigdwvzpmgngsygkbfgd.supabase.co/functions/v1/stripe-webhook
```

Listen for:

- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_failed`

The app shows one matched job for free after the quiz and gates the rest behind a subscription checkout.

Production cutover requires separate live Stripe products/prices, live webhook secret, and live Supabase secrets.

## Cloudflare Pages

Recommended build settings:

- Framework preset: None
- Build command: `flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY`
- Build output directory: `build/web`

Cloudflare needs Flutter available in the build image. Current deploys use the local direct deploy script below.

### Direct Cloudflare Deploy

Create a local `.env.local` file. It is ignored by git.

```bash
SUPABASE_URL=https://nigdwvzpmgngsygkbfgd.supabase.co
SUPABASE_ANON_KEY=...
CLOUDFLARE_ACCOUNT_ID=efe98345b3630bd0df0f8142c5c0fb7c
CLOUDFLARE_API_TOKEN=...
CLOUDFLARE_PAGES_PROJECT=giftpath
CLOUDFLARE_DOMAIN=giftpath.app
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

Then run:

```bash
bash tooling/cloudflare_check.sh
bash tooling/cloudflare_pages_deploy.sh
```

If the Pages project deploys to `giftpath.pages.dev`, set up `www.giftpath.app`:

```bash
bash tooling/cloudflare_dns.sh
```

## Tests

```bash
flutter test
```

The first tests cover scoring normalization, reverse scoring, and career ranking.
