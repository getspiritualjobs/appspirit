create extension if not exists "pgcrypto";

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  name text,
  location text,
  education_level text,
  desired_salary integer,
  work_preference text,
  created_at timestamptz not null default now()
);

create table public.spiritual_gifts (
  id text primary key,
  name text not null,
  description text not null,
  biblical_description text not null,
  scripture_reference text not null
);

create table public.assessment_questions (
  id text primary key,
  question_text text not null,
  display_order integer not null unique,
  active boolean not null default true
);

create table public.question_gift_weights (
  question_id text not null references public.assessment_questions(id) on delete cascade,
  gift_id text not null references public.spiritual_gifts(id) on delete cascade,
  weight numeric(5,2) not null check (weight > 0),
  reverse_scored boolean not null default false,
  primary key (question_id, gift_id)
);

create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  anonymous_session_id text,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint assessments_identity check (user_id is not null or anonymous_session_id is not null)
);

create table public.assessment_responses (
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  question_id text not null references public.assessment_questions(id) on delete restrict,
  response integer not null check (response between 1 and 5),
  created_at timestamptz not null default now(),
  primary key (assessment_id, question_id)
);

create table public.gift_scores (
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  gift_id text not null references public.spiritual_gifts(id) on delete restrict,
  raw_score numeric(8,2) not null,
  normalized_score integer not null check (normalized_score between 0 and 100),
  primary key (assessment_id, gift_id)
);

create table public.careers (
  id text primary key,
  title text not null,
  description text not null,
  category text not null,
  salary_low integer,
  salary_high integer,
  education_requirement text,
  responsibilities jsonb not null default '[]'::jsonb,
  work_environment text,
  interests text[] not null default '{}',
  values text[] not null default '{}'
);

create table public.career_gift_weights (
  career_id text not null references public.careers(id) on delete cascade,
  gift_id text not null references public.spiritual_gifts(id) on delete cascade,
  weight integer not null check (weight between 0 and 100),
  primary key (career_id, gift_id)
);

create table public.saved_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  title text not null default 'My Spiritual Gifts',
  created_at timestamptz not null default now(),
  unique (user_id, assessment_id)
);

create table public.saved_careers (
  user_id uuid not null references auth.users(id) on delete cascade,
  career_id text not null references public.careers(id) on delete cascade,
  match_score integer not null check (match_score between 0 and 100),
  created_at timestamptz not null default now(),
  primary key (user_id, career_id)
);

create table public.saved_jobs (
  user_id uuid not null references auth.users(id) on delete cascade,
  external_job_id text not null,
  provider text not null,
  title text not null,
  company text,
  location text,
  job_url text not null,
  payload jsonb not null default '{}'::jsonb,
  saved_at timestamptz not null default now(),
  primary key (user_id, provider, external_job_id)
);

create table public.job_search_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  location text,
  remote_preference text,
  salary_min integer,
  employment_type text,
  interests text[] not null default '{}',
  values text[] not null default '{}',
  updated_at timestamptz not null default now()
);

create table public.cached_job_searches (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  cache_key text not null unique,
  response jsonb not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index assessments_user_id_idx on public.assessments(user_id);
create index assessments_anonymous_session_id_idx on public.assessments(anonymous_session_id);
create index career_category_idx on public.careers(category);
create index saved_jobs_user_id_idx on public.saved_jobs(user_id);
create index cached_job_searches_expires_at_idx on public.cached_job_searches(expires_at);

alter table public.profiles enable row level security;
alter table public.assessments enable row level security;
alter table public.assessment_responses enable row level security;
alter table public.gift_scores enable row level security;
alter table public.saved_results enable row level security;
alter table public.saved_careers enable row level security;
alter table public.saved_jobs enable row level security;
alter table public.job_search_preferences enable row level security;

alter table public.spiritual_gifts enable row level security;
alter table public.assessment_questions enable row level security;
alter table public.question_gift_weights enable row level security;
alter table public.careers enable row level security;
alter table public.career_gift_weights enable row level security;
alter table public.cached_job_searches enable row level security;

create policy "public read spiritual gifts" on public.spiritual_gifts for select using (true);
create policy "public read active questions" on public.assessment_questions for select using (active);
create policy "public read question weights" on public.question_gift_weights for select using (true);
create policy "public read careers" on public.careers for select using (true);
create policy "public read career weights" on public.career_gift_weights for select using (true);

create policy "users read own profile" on public.profiles for select using (auth.uid() = id);
create policy "users insert own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "users update own profile" on public.profiles for update using (auth.uid() = id);

create policy "users read own assessments" on public.assessments for select using (auth.uid() = user_id);
create policy "users create own assessments" on public.assessments for insert with check (auth.uid() = user_id or user_id is null);
create policy "users update own assessments" on public.assessments for update using (auth.uid() = user_id);

create policy "users read own responses" on public.assessment_responses
  for select using (exists (select 1 from public.assessments a where a.id = assessment_id and a.user_id = auth.uid()));
create policy "users create own responses" on public.assessment_responses
  for insert with check (exists (select 1 from public.assessments a where a.id = assessment_id and (a.user_id = auth.uid() or a.user_id is null)));

create policy "users read own scores" on public.gift_scores
  for select using (exists (select 1 from public.assessments a where a.id = assessment_id and a.user_id = auth.uid()));
create policy "users create own scores" on public.gift_scores
  for insert with check (exists (select 1 from public.assessments a where a.id = assessment_id and (a.user_id = auth.uid() or a.user_id is null)));

create policy "users manage own saved results" on public.saved_results for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users manage own saved careers" on public.saved_careers for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users manage own saved jobs" on public.saved_jobs for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users manage own preferences" on public.job_search_preferences for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "service role manages cache" on public.cached_job_searches for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
