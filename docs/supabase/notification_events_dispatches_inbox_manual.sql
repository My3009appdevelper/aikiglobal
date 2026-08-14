-- Ejecución manual en Supabase SQL Editor.
-- Prerrequisitos existentes en Aiki:
--   public.set_updated_at() returns trigger
--   public.is_admin() returns boolean

begin;

create extension if not exists pgcrypto;

create table if not exists public.notification_events (
  uuid_notification_event uuid primary key default gen_random_uuid(),
  name text not null check (btrim(name) <> ''),
  category text not null check (
    category in ('content', 'events', 'schedule_changes', 'general', 'admin', 'progress')
  ),
  title_template text not null check (btrim(title_template) <> ''),
  body_template text not null check (btrim(body_template) <> ''),
  trigger_type text not null check (
    trigger_type in ('manual', 'domain_event', 'schedule', 'progress_event')
  ),
  trigger_key text,
  execution_mode text not null check (
    execution_mode in ('once', 'per_occurrence')
  ),
  trigger_config jsonb not null default '{}'::jsonb check (
    jsonb_typeof(trigger_config) = 'object'
  ),
  audience_type text not null check (
    audience_type in ('all', 'all_users', 'all_admins')
  ),
  action_type text not null check (
    action_type in (
      'none',
      'open_content_item',
      'open_company_info',
      'open_home',
      'open_explore',
      'open_meditation'
    )
  ),
  action_payload_template jsonb not null default '{}'::jsonb check (
    jsonb_typeof(action_payload_template) = 'object'
  ),
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  status text not null default 'draft' check (
    status in ('draft', 'active', 'paused', 'completed', 'cancelled')
  ),
  uuid_created_by_profile uuid references public.profiles(uuid_profile)
    on delete set null,
  uuid_updated_by_profile uuid references public.profiles(uuid_profile)
    on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at timestamptz,
  constraint notification_events_valid_window check (
    ends_at is null or ends_at > starts_at
  ),
  constraint notification_events_valid_trigger check (
    (
      trigger_type = 'manual'
      and trigger_key is null
      and execution_mode = 'once'
    )
    or
    (
      trigger_type = 'domain_event'
      and trigger_key in (
        'content.published',
        'content.updated',
        'event.published',
        'schedule.changed'
      )
    )
    or
    (
      trigger_type = 'schedule'
      and trigger_key in ('schedule.interval', 'schedule.at_time')
      and execution_mode = 'per_occurrence'
    )
    or
    (
      trigger_type = 'progress_event'
      and trigger_key in (
        'progress.streak_reminder',
        'progress.streak_milestone'
      )
      and execution_mode = 'per_occurrence'
    )
  ),
  constraint notification_events_content_action_payload check (
    action_type <> 'open_content_item'
    or (
      action_payload_template ? 'uuid_content_item'
      and jsonb_typeof(
        action_payload_template -> 'uuid_content_item'
      ) = 'string'
      and btrim(action_payload_template ->> 'uuid_content_item') <> ''
    )
  )
);

create table if not exists public.notification_dispatches (
  uuid_notification_dispatch uuid primary key default gen_random_uuid(),
  uuid_notification_event uuid not null references public.notification_events(
    uuid_notification_event
  ) on delete restrict,
  trigger_source text not null check (
    trigger_source in ('manual', 'scheduler', 'domain_event')
  ),
  uuid_triggered_by_profile uuid references public.profiles(uuid_profile)
    on delete set null,
  source_entity_type text,
  source_entity_uuid uuid,
  idempotency_key text not null unique check (btrim(idempotency_key) <> ''),
  title_snapshot text not null check (btrim(title_snapshot) <> ''),
  body_snapshot text not null check (btrim(body_snapshot) <> ''),
  category_snapshot text not null check (
    category_snapshot in (
      'content',
      'events',
      'schedule_changes',
      'general',
      'admin',
      'progress'
    )
  ),
  audience_type_snapshot text not null check (
    audience_type_snapshot in ('all', 'all_users', 'all_admins')
  ),
  action_type_snapshot text not null check (
    action_type_snapshot in (
      'none',
      'open_content_item',
      'open_company_info',
      'open_home',
      'open_explore',
      'open_meditation'
    )
  ),
  action_payload_snapshot jsonb not null default '{}'::jsonb check (
    jsonb_typeof(action_payload_snapshot) = 'object'
  ),
  status text not null default 'pending' check (
    status in (
      'pending',
      'processing',
      'completed',
      'partial',
      'failed',
      'cancelled'
    )
  ),
  target_profile_count integer not null default 0 check (
    target_profile_count >= 0
  ),
  target_device_count integer not null default 0 check (
    target_device_count >= 0
  ),
  success_device_count integer not null default 0 check (
    success_device_count >= 0
  ),
  failure_device_count integer not null default 0 check (
    failure_device_count >= 0
  ),
  invalid_token_count integer not null default 0 check (
    invalid_token_count >= 0
  ),
  started_at timestamptz,
  completed_at timestamptz,
  error_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at timestamptz,
  constraint notification_dispatches_source_pair check (
    (source_entity_type is null) = (source_entity_uuid is null)
  ),
  constraint notification_dispatches_device_counts check (
    success_device_count + failure_device_count <= target_device_count
    and invalid_token_count <= failure_device_count
  ),
  constraint notification_dispatches_valid_duration check (
    completed_at is null
    or started_at is null
    or completed_at >= started_at
  ),
  constraint notification_dispatches_content_action_payload check (
    action_type_snapshot <> 'open_content_item'
    or (
      action_payload_snapshot ? 'uuid_content_item'
      and jsonb_typeof(
        action_payload_snapshot -> 'uuid_content_item'
      ) = 'string'
      and btrim(action_payload_snapshot ->> 'uuid_content_item') <> ''
    )
  )
);

create table if not exists public.notifications_inbox (
  uuid_notification_inbox uuid primary key default gen_random_uuid(),
  uuid_notification_dispatch uuid not null references public.notification_dispatches(
    uuid_notification_dispatch
  ) on delete cascade,
  uuid_profile uuid not null references public.profiles(uuid_profile)
    on delete cascade,
  title text not null check (btrim(title) <> ''),
  body text not null check (btrim(body) <> ''),
  category text not null check (
    category in ('content', 'events', 'schedule_changes', 'general', 'admin', 'progress')
  ),
  action_type text not null check (
    action_type in (
      'none',
      'open_content_item',
      'open_company_info',
      'open_home',
      'open_explore',
      'open_meditation'
    )
  ),
  action_payload jsonb not null default '{}'::jsonb check (
    jsonb_typeof(action_payload) = 'object'
  ),
  read_at timestamptz,
  opened_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at timestamptz,
  constraint notifications_inbox_dispatch_profile_unique unique (
    uuid_notification_dispatch,
    uuid_profile
  ),
  constraint notifications_inbox_opened_is_read check (
    opened_at is null or read_at is not null
  ),
  constraint notifications_inbox_content_action_payload check (
    action_type <> 'open_content_item'
    or (
      action_payload ? 'uuid_content_item'
      and jsonb_typeof(action_payload -> 'uuid_content_item') = 'string'
      and btrim(action_payload ->> 'uuid_content_item') <> ''
    )
  )
);

drop trigger if exists set_notification_events_updated_at
on public.notification_events;
create trigger set_notification_events_updated_at
before update on public.notification_events
for each row execute function public.set_updated_at();

drop trigger if exists set_notification_dispatches_updated_at
on public.notification_dispatches;
create trigger set_notification_dispatches_updated_at
before update on public.notification_dispatches
for each row execute function public.set_updated_at();

drop trigger if exists set_notifications_inbox_updated_at
on public.notifications_inbox;
create trigger set_notifications_inbox_updated_at
before update on public.notifications_inbox
for each row execute function public.set_updated_at();

create index if not exists idx_notification_events_status
on public.notification_events(status);
create index if not exists idx_notification_events_active_window
on public.notification_events(starts_at, ends_at)
where deleted_at is null and status = 'active';
create index if not exists idx_notification_events_trigger
on public.notification_events(trigger_type, trigger_key);
create index if not exists idx_notification_events_updated_at
on public.notification_events(updated_at);
create index if not exists idx_notification_events_deleted_at
on public.notification_events(deleted_at);

create index if not exists idx_notification_dispatches_event_created
on public.notification_dispatches(uuid_notification_event, created_at desc);
create index if not exists idx_notification_dispatches_status
on public.notification_dispatches(status);
create index if not exists idx_notification_dispatches_source
on public.notification_dispatches(source_entity_type, source_entity_uuid)
where source_entity_uuid is not null;
create index if not exists idx_notification_dispatches_created_at
on public.notification_dispatches(created_at desc);
create index if not exists idx_notification_dispatches_updated_at
on public.notification_dispatches(updated_at);
create index if not exists idx_notification_dispatches_deleted_at
on public.notification_dispatches(deleted_at);

create index if not exists idx_notifications_inbox_profile_created
on public.notifications_inbox(uuid_profile, created_at desc);
create index if not exists idx_notifications_inbox_dispatch
on public.notifications_inbox(uuid_notification_dispatch);
create index if not exists idx_notifications_inbox_unread
on public.notifications_inbox(uuid_profile, created_at desc)
where read_at is null and deleted_at is null;
create index if not exists idx_notifications_inbox_updated_at
on public.notifications_inbox(updated_at);
create index if not exists idx_notifications_inbox_deleted_at
on public.notifications_inbox(deleted_at);

alter table public.notification_events enable row level security;
alter table public.notification_dispatches enable row level security;
alter table public.notifications_inbox enable row level security;

revoke all on table public.notification_events from anon, authenticated;
revoke all on table public.notification_dispatches from anon, authenticated;
revoke all on table public.notifications_inbox from anon, authenticated;

grant select, insert, update on table public.notification_events
to authenticated;
grant select on table public.notification_dispatches to authenticated;
grant select on table public.notifications_inbox to authenticated;
grant update (read_at, opened_at) on table public.notifications_inbox
to authenticated;

grant all privileges on table public.notification_events to service_role;
grant all privileges on table public.notification_dispatches to service_role;
grant all privileges on table public.notifications_inbox to service_role;

drop policy if exists notification_events_select_admin
on public.notification_events;
create policy notification_events_select_admin
on public.notification_events
for select to authenticated
using (public.is_admin());

drop policy if exists notification_events_insert_admin
on public.notification_events;
create policy notification_events_insert_admin
on public.notification_events
for insert to authenticated
with check (public.is_admin());

drop policy if exists notification_events_update_admin
on public.notification_events;
create policy notification_events_update_admin
on public.notification_events
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists notification_dispatches_select_admin
on public.notification_dispatches;
create policy notification_dispatches_select_admin
on public.notification_dispatches
for select to authenticated
using (public.is_admin());

drop policy if exists notifications_inbox_select_owner_or_admin
on public.notifications_inbox;
create policy notifications_inbox_select_owner_or_admin
on public.notifications_inbox
for select to authenticated
using (
  public.is_admin()
  or exists (
    select 1
    from public.profiles p
    where p.uuid_profile = notifications_inbox.uuid_profile
      and p.auth_user_id = auth.uid()
      and p.deleted_at is null
  )
);

drop policy if exists notifications_inbox_update_owner_read_state
on public.notifications_inbox;
create policy notifications_inbox_update_owner_read_state
on public.notifications_inbox
for update to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.uuid_profile = notifications_inbox.uuid_profile
      and p.auth_user_id = auth.uid()
      and p.deleted_at is null
  )
)
with check (
  exists (
    select 1
    from public.profiles p
    where p.uuid_profile = notifications_inbox.uuid_profile
      and p.auth_user_id = auth.uid()
      and p.deleted_at is null
  )
);

commit;

notify pgrst, 'reload schema';
