create table if not exists public.legal_acceptances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  assessment_id uuid references public.assessments(id) on delete set null,
  age_confirmed boolean not null default false,
  terms_version text not null,
  privacy_version text not null,
  assessment_notice_version text not null,
  accepted_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists legal_acceptances_user_id_idx
  on public.legal_acceptances(user_id);

create index if not exists legal_acceptances_assessment_id_idx
  on public.legal_acceptances(assessment_id);

alter table public.legal_acceptances enable row level security;

drop policy if exists "users read own legal acceptances"
  on public.legal_acceptances;
create policy "users read own legal acceptances"
  on public.legal_acceptances
  for select
  using (auth.uid() = user_id);

drop policy if exists "users create own legal acceptances"
  on public.legal_acceptances;
create policy "users create own legal acceptances"
  on public.legal_acceptances
  for insert
  with check (auth.uid() = user_id and age_confirmed = true);
