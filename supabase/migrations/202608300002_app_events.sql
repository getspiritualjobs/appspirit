create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  event_name text not null,
  user_id uuid references auth.users(id) on delete set null,
  anonymous_session_id text,
  assessment_id uuid references public.assessments(id) on delete set null,
  properties jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists app_events_event_name_created_at_idx
  on public.app_events (event_name, created_at desc);

create index if not exists app_events_user_id_created_at_idx
  on public.app_events (user_id, created_at desc);

create index if not exists app_events_assessment_id_idx
  on public.app_events (assessment_id);

alter table public.app_events enable row level security;

drop policy if exists "Clients can insert app events" on public.app_events;
create policy "Clients can insert app events"
  on public.app_events for insert
  with check (user_id is null or auth.uid() = user_id);

drop policy if exists "Blog admins can read app events" on public.app_events;
create policy "Blog admins can read app events"
  on public.app_events for select
  using (
    exists (
      select 1
      from public.blog_admins
      where lower(blog_admins.email) = lower(auth.jwt() ->> 'email')
    )
  );

drop policy if exists "Service role can manage app events" on public.app_events;
create policy "Service role can manage app events"
  on public.app_events for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

create or replace view public.funnel_daily_summary as
select
  date_trunc('day', created_at)::date as day,
  count(*) filter (where event_name = 'assessment_progress') as quiz_progress_events,
  count(*) filter (
    where event_name = 'assessment_progress'
      and coalesce((properties ->> 'answered_count')::int, 0) >= 1
  ) as quiz_starts,
  count(*) filter (where event_name = 'assessment_completed') as quiz_completions,
  count(*) filter (where event_name = 'account_create_completed') as account_creations,
  count(*) filter (where event_name = 'checkout_started') as checkout_starts,
  count(*) filter (where event_name = 'subscription_started') as subscription_starts
from public.app_events
group by 1
order by 1 desc;

create or replace view public.quiz_progress_summary as
select
  coalesce((properties ->> 'answered_count')::int, 0) as answered_count,
  count(*) as event_count,
  count(distinct coalesce(user_id::text, anonymous_session_id)) as people_count
from public.app_events
where event_name = 'assessment_progress'
group by 1
order by 1;
