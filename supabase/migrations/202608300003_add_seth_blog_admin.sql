insert into public.blog_admins (email)
values ('sethswanson95@gmail.com')
on conflict (email) do nothing;
