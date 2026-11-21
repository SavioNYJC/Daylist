begin;

create unique index if not exists profiles_username_lower_key
on public.profiles (lower(btrim(username)))
where username is not null;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (user_id, username)
  values (
    new.id,
    nullif(btrim(new.raw_user_meta_data ->> 'username'), '')
  );

  return new;
end;
$$;

create or replace function public.is_username_available(candidate_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select nullif(btrim(candidate_username), '') is not null
    and not exists (
      select 1
      from public.profiles
      where lower(btrim(username)) = lower(btrim(candidate_username))
    );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text) to anon, authenticated;

commit;
