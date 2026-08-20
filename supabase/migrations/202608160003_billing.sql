create table public.billing_customers (
  user_id uuid primary key references auth.users(id) on delete cascade,
  stripe_customer_id text not null unique,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.billing_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  stripe_customer_id text not null,
  stripe_subscription_id text not null unique,
  stripe_price_id text,
  status text not null,
  current_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index billing_subscriptions_user_id_idx
  on public.billing_subscriptions(user_id);
create index billing_subscriptions_status_idx
  on public.billing_subscriptions(status);

alter table public.billing_customers enable row level security;
alter table public.billing_subscriptions enable row level security;

create policy "users read own billing customer"
  on public.billing_customers for select
  using (auth.uid() = user_id);

create policy "users read own billing subscriptions"
  on public.billing_subscriptions for select
  using (auth.uid() = user_id);

create policy "service role manages billing customers"
  on public.billing_customers for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create policy "service role manages billing subscriptions"
  on public.billing_subscriptions for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
