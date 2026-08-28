create table if not exists public.job_api_usage (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  query text,
  location text,
  remote boolean not null default false,
  salary_min integer,
  employment_type text,
  cache_hit boolean not null default false,
  http_status integer,
  result_count integer not null default 0,
  deduped_count integer,
  duration_ms integer,
  error text,
  created_at timestamptz not null default now()
);

create index if not exists job_api_usage_provider_created_at_idx
  on public.job_api_usage (provider, created_at desc);

create index if not exists job_api_usage_created_at_idx
  on public.job_api_usage (created_at desc);

alter table public.job_api_usage enable row level security;

drop policy if exists "Blog admins can read job API usage" on public.job_api_usage;
create policy "Blog admins can read job API usage"
  on public.job_api_usage for select
  to authenticated
  using (public.is_blog_admin());

drop policy if exists "Service role can manage job API usage" on public.job_api_usage;
create policy "Service role can manage job API usage"
  on public.job_api_usage for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
