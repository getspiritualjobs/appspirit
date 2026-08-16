# GiftPath: Spiritual Gifts + Career Discovery

A Flutter web MVP that helps Christians take a Scripture-informed spiritual gifts assessment, understand their strongest gift alignments, explore career matches, and review job opportunities.

The product intentionally avoids claims like "God wants you to become..." or "this is God's calling." Results are framed as reflection and vocational exploration.

## Current Status

- Flutter web app scaffold with routes for Home, Assessment, Results, Careers, Opportunities, Saved, About, and Account.
- Local deterministic scoring with 56 weighted questions and the seven Romans 12 gifts.
- Structured career matching with 100+ seeded careers in `lib/data/seed_data.dart`.
- Demo job cards so Opportunities works before external APIs are configured.
- Supabase schema and Edge Function starter for future persistence and live job APIs.
- No orders, no followers, no social feed.

## Prerequisites

Flutter is not currently installed on this machine. Install Flutter first:

```bash
brew install --cask flutter
flutter doctor
```

Then run:

```bash
flutter pub get
flutter run -d chrome
```

With Supabase later:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY"
```

## Supabase Later

When you create the Supabase account/project:

1. Enable Email Auth.
2. Configure Google OAuth in Supabase Auth providers.
3. Apply migrations in `supabase/migrations`.
4. Deploy `supabase/functions/search-jobs`.
5. Set Edge Function secrets:

```bash
supabase secrets set ADZUNA_APP_ID=...
supabase secrets set ADZUNA_APP_KEY=...
supabase secrets set USAJOBS_API_KEY=...
supabase secrets set USAJOBS_USER_AGENT=you@example.com
```

The Flutter app works without Supabase by using in-memory local state and demo jobs.

## Cloudflare Pages

Recommended build settings:

- Framework preset: None
- Build command: `flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY`
- Build output directory: `build/web`

Cloudflare needs Flutter available in the build image. The simplest path is a GitHub Action that builds Flutter web and publishes the artifact, or configuring Cloudflare with a build image that installs Flutter before the build command.

### Direct Cloudflare Deploy

Create a local `.env.local` file. It is ignored by git.

```bash
SUPABASE_URL=https://nigdwvzpmgngsygkbfgd.supabase.co
SUPABASE_ANON_KEY=...
CLOUDFLARE_ACCOUNT_ID=efe98345b3630bd0df0f8142c5c0fb7c
CLOUDFLARE_API_TOKEN=...
CLOUDFLARE_PAGES_PROJECT=giftpath
CLOUDFLARE_DOMAIN=giftpath.app
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
