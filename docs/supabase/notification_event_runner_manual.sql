-- Ejecutar en el proyecto Aiki despues de desplegar la Edge Function.
-- Esta cola conserva el momento y el contenido exactos de las publicaciones.

begin;

create schema if not exists private;
create extension if not exists pg_cron;
create extension if not exists pg_net;

create table if not exists public.notification_domain_events (
  uuid_notification_domain_event uuid primary key default gen_random_uuid(),
  event_key text not null check (
    event_key in ('content.published', 'content.updated')
  ),
  source_entity_type text not null default 'content_item' check (
    source_entity_type = 'content_item'
  ),
  source_entity_uuid uuid not null references public.content_items(
    uuid_content_item
  ) on delete cascade,
  payload jsonb not null default '{}'::jsonb check (
    jsonb_typeof(payload) = 'object'
  ),
  occurred_at timestamptz not null default now(),
  processed_at timestamptz,
  attempt_count integer not null default 0 check (attempt_count >= 0),
  processing_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists set_notification_domain_events_updated_at
on public.notification_domain_events;
create trigger set_notification_domain_events_updated_at
before update on public.notification_domain_events
for each row execute function public.set_updated_at();

create index if not exists idx_notification_domain_events_pending
on public.notification_domain_events(occurred_at)
where processed_at is null;

create index if not exists idx_notification_domain_events_source
on public.notification_domain_events(source_entity_type, source_entity_uuid);

create index if not exists idx_notification_domain_events_source_uuid
on public.notification_domain_events(source_entity_uuid);

alter table public.notification_domain_events enable row level security;
revoke all on table public.notification_domain_events from anon, authenticated;
grant all privileges on table public.notification_domain_events to service_role;
drop policy if exists notification_domain_events_service_role
on public.notification_domain_events;
create policy notification_domain_events_service_role
on public.notification_domain_events
for all to service_role
using (true)
with check (true);

alter table public.notification_dispatches
  drop constraint if exists notification_dispatches_category_snapshot_check;
alter table public.notification_dispatches
  add constraint notification_dispatches_category_snapshot_check check (
    category_snapshot in (
      'content', 'events', 'schedule_changes', 'general', 'admin', 'progress'
    )
  );

alter table public.notifications_inbox
  drop constraint if exists notifications_inbox_category_check;
alter table public.notifications_inbox
  add constraint notifications_inbox_category_check check (
    category in (
      'content', 'events', 'schedule_changes', 'general', 'admin', 'progress'
    )
  );

create or replace function private.enqueue_content_notification_event()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  next_event_key text;
begin
  next_event_key := null;

  if tg_op = 'INSERT' and new.status = 'published' then
    next_event_key := 'content.published';
  elsif tg_op = 'UPDATE' and new.status = 'published' then
    if old.status is distinct from 'published' then
      next_event_key := 'content.published';
    elsif old.tipo is distinct from new.tipo
      or old.titulo is distinct from new.titulo
      or old.subtitulo is distinct from new.subtitulo
      or old.descripcion is distinct from new.descripcion
      or old.cover_path_supabase is distinct from new.cover_path_supabase
      or old.destacado is distinct from new.destacado
      or old.descargable is distinct from new.descargable
      or old.duracion_segundos is distinct from new.duracion_segundos
      or old.orden is distinct from new.orden then
      next_event_key := 'content.updated';
    end if;
  end if;

  if next_event_key is not null then
    insert into public.notification_domain_events (
      event_key,
      source_entity_uuid,
      payload,
      occurred_at
    ) values (
      next_event_key,
      new.uuid_content_item,
      jsonb_build_object(
        'content_uuid', new.uuid_content_item::text,
        'content_title', new.titulo,
        'content_subtitle', new.subtitulo,
        'content_type', new.tipo,
        'content_description', new.descripcion,
        'content_cover_path', new.cover_path_supabase,
        'content_featured', new.destacado,
        'content_downloadable', new.descargable,
        'content_duration_seconds', new.duracion_segundos,
        'content_order', new.orden,
        'uuid_content_item', new.uuid_content_item::text,
        'titulo', new.titulo,
        'subtitulo', new.subtitulo,
        'tipo', new.tipo
      ),
      coalesce(new.updated_at, now())
    );
  end if;

  return new;
end;
$$;

drop trigger if exists enqueue_content_notification_event
on public.content_items;
create trigger enqueue_content_notification_event
after insert or update on public.content_items
for each row execute function private.enqueue_content_notification_event();

commit;

notify pgrst, 'reload schema';

-- Despues de desplegar run-notification-events y crear el secreto
-- NOTIFICATION_RUNNER_SECRET, guardar en Vault los siguientes secretos:
--   project_url       = https://hpysbnoaaallpbjfyafy.supabase.co
--   runner_secret     = el mismo valor configurado en la Edge Function
--
-- select vault.create_secret('https://hpysbnoaaallpbjfyafy.supabase.co', 'project_url');
-- select vault.create_secret('...', 'runner_secret');
--
-- Crear un solo trabajo:
-- select cron.schedule(
--   'run-notification-events-every-minute',
--   '* * * * *',
--   $$
--   select net.http_post(
--     url := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url')
--       || '/functions/v1/run-notification-events',
--     headers := jsonb_build_object(
--       'Content-Type', 'application/json',
--       'x-notification-runner-secret',
--         (select decrypted_secret from vault.decrypted_secrets where name = 'runner_secret'),
--     ),
--     body := '{"source":"pg_cron"}'::jsonb
--   ) as request_id;
--   $$
-- );
