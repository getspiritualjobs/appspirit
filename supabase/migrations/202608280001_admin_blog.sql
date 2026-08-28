create table if not exists public.blog_admins (
  email text primary key,
  created_at timestamptz not null default now()
);

alter table public.blog_admins enable row level security;

drop policy if exists "Blog admins can read their own access marker" on public.blog_admins;
create policy "Blog admins can read their own access marker"
  on public.blog_admins for select
  to authenticated
  using (email = auth.jwt() ->> 'email');

insert into public.blog_admins (email)
values ('get.spiritual.jobs@gmail.com')
on conflict (email) do nothing;

create or replace function public.is_blog_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.blog_admins
    where email = auth.jwt() ->> 'email'
  );
$$;

grant execute on function public.is_blog_admin() to authenticated;

create table if not exists public.blog_posts (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  excerpt text not null,
  eyebrow text not null default 'Journal',
  read_time text not null default '3 min read',
  content_markdown text not null,
  status text not null default 'draft' check (status in ('draft', 'published')),
  published_at timestamptz,
  author_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists blog_posts_status_published_at_idx
  on public.blog_posts (status, published_at desc);

create index if not exists blog_posts_slug_idx
  on public.blog_posts (slug);

alter table public.blog_posts enable row level security;

drop policy if exists "Anyone can read published blog posts" on public.blog_posts;
create policy "Anyone can read published blog posts"
  on public.blog_posts for select
  to anon, authenticated
  using (status = 'published');

drop policy if exists "Blog admins can read all blog posts" on public.blog_posts;
create policy "Blog admins can read all blog posts"
  on public.blog_posts for select
  to authenticated
  using (public.is_blog_admin());

drop policy if exists "Blog admins can insert blog posts" on public.blog_posts;
create policy "Blog admins can insert blog posts"
  on public.blog_posts for insert
  to authenticated
  with check (public.is_blog_admin());

drop policy if exists "Blog admins can update blog posts" on public.blog_posts;
create policy "Blog admins can update blog posts"
  on public.blog_posts for update
  to authenticated
  using (public.is_blog_admin())
  with check (public.is_blog_admin());

drop policy if exists "Blog admins can delete blog posts" on public.blog_posts;
create policy "Blog admins can delete blog posts"
  on public.blog_posts for delete
  to authenticated
  using (public.is_blog_admin());

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_blog_posts_updated_at on public.blog_posts;
create trigger set_blog_posts_updated_at
  before update on public.blog_posts
  for each row execute function public.set_updated_at();

insert into public.blog_posts (
  slug,
  title,
  excerpt,
  eyebrow,
  read_time,
  content_markdown,
  status,
  published_at
)
values
  (
    'spiritual-gifts-and-career-discernment',
    'How spiritual gifts can shape career discernment',
    'A practical way to treat gifts as clues for work, service, and next steps without turning an assessment into a verdict.',
    'Discernment',
    '4 min read',
    $$## Start with patterns, not pressure

A spiritual gifts assessment should not tell you what you must do with your life. A healthier use is quieter: notice the patterns that keep showing up, then compare them with real opportunities.

GiftPath scores gifts as alignment. That means a result can give language to what you already sense, but it still belongs in conversation with Scripture, prayer, wise counsel, and lived experience.

## Ask where the gift becomes useful

Teaching may point toward classrooms, training, curriculum, coaching, or product education. Mercy may point toward care work, counseling-adjacent roles, patient support, or nonprofit service. Leadership may show up in operations, team building, ministry administration, or project ownership.

The point is not to force a direct one-to-one match. The point is to ask where a gift can become concrete enough to serve someone.

## Test one next step

A good next step is small enough to try and specific enough to teach you something. Save a career lane, open a few jobs, talk with someone in the field, or volunteer in a related setting.

Discernment gets clearer when reflection meets evidence.$$,
    'published',
    now() - interval '3 days'
  ),
  (
    'romans-12-gifts-explained',
    'The seven Romans 12 gifts, explained plainly',
    'A simple overview of prophecy, serving, teaching, encouragement, giving, leadership, and mercy.',
    'Romans 12',
    '5 min read',
    $$## Why these seven gifts

Romans 12:6-8 gives a concise list of gifts that translate well into reflection prompts. GiftPath begins here because the list is specific enough to score thoughtfully and broad enough to connect with modern work.

The New Testament includes other gift passages too. This is not an exhaustive inventory. It is a focused starting point.

## What the gifts can reveal

Serving often notices practical needs. Teaching clarifies ideas. Encouragement helps people keep going. Giving sees resources as tools for care. Leadership brings order and movement. Mercy moves toward pain with compassion. Prophecy cares about truth, conviction, and alignment.

In real life, these gifts overlap. A person may teach with mercy, lead through encouragement, or serve with unusual discernment.

## How to read your result

Your top gifts are best treated as your strongest signals, not your only gifts. Lower scores are not failures. They may simply mean those patterns were less prominent in your answers right now.

Use the language to pay attention: where do you bring life, clarity, courage, generosity, order, care, or conviction?$$,
    'published',
    now() - interval '2 days'
  ),
  (
    'one-question-at-a-time',
    'Why GiftPath asks one question at a time',
    'The quiz is designed to slow the process down so each answer is more honest and less performative.',
    'Assessment',
    '3 min read',
    $$## A quieter pace helps

Most assessments try to move quickly. GiftPath intentionally asks one question at a time because reflection benefits from a little space.

The goal is not to make the quiz feel dramatic. The goal is to reduce noise so your answers can be honest.

## Less comparison, better answers

When too many questions sit on the screen at once, it is easy to manage an image of yourself instead of answering what is true. A single prompt keeps attention on the next honest response.

That is also why results use language like alignment and signal. GiftPath is meant to help you notice, not perform.

## From answer to action

After the assessment, the path continues into gifts, career lanes, and open jobs. The question flow is only the beginning. The real value is turning reflection into a next step you can actually compare and test.$$,
    'published',
    now() - interval '1 day'
  )
on conflict (slug) do update set
  title = excluded.title,
  excerpt = excluded.excerpt,
  eyebrow = excluded.eyebrow,
  read_time = excluded.read_time,
  content_markdown = excluded.content_markdown,
  status = excluded.status,
  published_at = coalesce(public.blog_posts.published_at, excluded.published_at);
