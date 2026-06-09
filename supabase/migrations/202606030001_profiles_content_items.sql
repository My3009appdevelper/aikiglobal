create extension if not exists pgcrypto;

do $$
begin
  create type public.profile_role as enum ('admin', 'user');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.content_type as enum (
    'course',
    'meditation',
    'sound',
    'audio',
    'event',
    'session'
  );
exception
  when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  nombre text not null default '',
  email text not null default '',
  foto_url text,
  role public.profile_role not null default 'user',
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.content_items (
  id uuid primary key default gen_random_uuid(),
  type public.content_type not null,
  title text not null,
  subtitle text,
  description text,
  cover_image_path text,
  category_id uuid,
  instructor_id uuid,
  is_published boolean not null default false,
  is_featured boolean not null default false,
  is_downloadable boolean not null default false,
  duration_seconds integer,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists profiles_auth_user_id_idx
  on public.profiles (auth_user_id);

create index if not exists content_items_type_idx
  on public.content_items (type);

create index if not exists content_items_published_idx
  on public.content_items (is_published, deleted_at);

create index if not exists content_items_featured_idx
  on public.content_items (is_featured, sort_order);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists content_items_set_updated_at on public.content_items;
create trigger content_items_set_updated_at
before update on public.content_items
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (auth_user_id, nombre, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nombre', new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.email, '')
  )
  on conflict (auth_user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where auth_user_id = auth.uid()
      and role = 'admin'
      and activo = true
  );
$$;

alter table public.profiles enable row level security;
alter table public.content_items enable row level security;

drop policy if exists "Profiles are readable by owner or admin" on public.profiles;
create policy "Profiles are readable by owner or admin"
on public.profiles
for select
to authenticated
using (auth_user_id = auth.uid() or public.is_admin());

drop policy if exists "Profiles can be created by owner" on public.profiles;
create policy "Profiles can be created by owner"
on public.profiles
for insert
to authenticated
with check (auth_user_id = auth.uid());

drop policy if exists "Profiles can be updated by owner or admin" on public.profiles;
create policy "Profiles can be updated by owner or admin"
on public.profiles
for update
to authenticated
using (auth_user_id = auth.uid() or public.is_admin())
with check (auth_user_id = auth.uid() or public.is_admin());

drop policy if exists "Published content is readable" on public.content_items;
create policy "Published content is readable"
on public.content_items
for select
to anon, authenticated
using (is_published = true and deleted_at is null);

drop policy if exists "Admins can manage content" on public.content_items;
create policy "Admins can manage content"
on public.content_items
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());
