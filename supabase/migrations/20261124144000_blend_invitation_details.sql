alter table public.blends
  add column if not exists selected_dates date[] not null default '{}',
  add column if not exists description text;
