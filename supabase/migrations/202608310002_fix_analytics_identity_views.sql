drop view if exists public.quiz_progress_summary;
drop view if exists public.funnel_daily_summary;

create view public.funnel_daily_summary as
with daily_people as (
  select
    date_trunc('day', created_at)::date as day,
    event_name,
    coalesce(user_id::text, anonymous_session_id) as identity,
    coalesce((properties ->> 'answered_count')::int, 0) as answered_count
  from public.app_events
  where coalesce(user_id::text, anonymous_session_id) is not null
)
select
  day,
  count(*) filter (where event_name = 'assessment_progress') as quiz_progress_events,
  count(distinct identity) filter (
    where event_name = 'assessment_progress'
      and answered_count >= 1
  ) as quiz_starts,
  count(distinct identity) filter (
    where event_name = 'assessment_completed'
  ) as quiz_completions,
  count(distinct identity) filter (
    where event_name = 'account_create_completed'
  ) as account_creations,
  count(distinct identity) filter (
    where event_name = 'checkout_started'
  ) as checkout_starts,
  count(distinct identity) filter (
    where event_name = 'subscription_started'
  ) as subscription_starts
from daily_people
group by day
order by day desc;

create view public.quiz_progress_summary as
with progress_by_person as (
  select
    coalesce(user_id::text, anonymous_session_id) as identity,
    max(coalesce((properties ->> 'answered_count')::int, 0)) as answered_count
  from public.app_events
  where event_name = 'assessment_progress'
    and coalesce(user_id::text, anonymous_session_id) is not null
  group by 1
)
select
  answered_count,
  count(*) as people_count
from progress_by_person
group by 1
order by 1;
