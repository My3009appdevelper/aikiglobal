# Notification Event Runner Implementation Plan

> **For agentic workers:** Implement this plan inline with checkpoints. The runner must remain separate from manual dispatches and must be idempotent.

**Goal:** Ejecutar automáticamente las reglas activas de notificaciones cada minuto para publicaciones, actualizaciones, horarios y rachas, creando dispatches e inbox y enviando FCM sin duplicados.

**Architecture:** Una Edge Function interna `run-notification-events` será invocada por un único trabajo `pg_cron` cada minuto. Leerá reglas activas, determinará ocurrencias vencidas en UTC y zona local, construirá snapshots por destinatario cuando haya variables personalizadas y reutilizará el procesador FCM existente mediante un servicio de dominio compartido. `dispatch-notification-event` seguirá dedicado a envíos manuales.

**Tech Stack:** Supabase Edge Functions, Deno/TypeScript, Supabase PostgREST, pg_cron, pg_net, Vault, FCM HTTP v1, Vitest-compatible Deno tests.

## Global Constraints

- Un solo runner por minuto; tolerancia máxima de un minuto.
- `notification_dispatches` e `notifications_inbox` sólo los escribe el backend confiable.
- Firebase credentials permanecen en secretos de Supabase; nunca en Flutter.
- Todas las ocurrencias usan `idempotency_key` antes de crear un dispatch.
- La zona horaria inicial se resuelve desde el dispositivo activo más recientemente actualizado.
- Los mensajes de racha se resuelven por perfil; no se reutiliza un snapshot global para destinatarios personalizados.

### Task 1: Contratos y servicio compartido

**Files:**
- Create: `supabase/functions/notification-runtime/domain.ts`
- Create: `supabase/functions/notification-runtime/notification_dispatcher.ts`
- Modify: `supabase/functions/dispatch-notification-event/service.ts`
- Modify: `supabase/functions/dispatch-notification-event/supabase_repository.ts`
- Test: `supabase/functions/notification-runtime/domain_test.ts`

- [ ] Extraer contratos de snapshot, audiencia, dispositivo y procesamiento sin cambiar el comportamiento manual.
- [ ] Permitir `trigger_source` `scheduler` y `domain_event`, categoría `progress` y snapshots personalizados.
- [ ] Mantener la idempotencia por inserción única y la desactivación de tokens `UNREGISTERED`.
- [ ] Ejecutar pruebas manuales existentes antes y después del cambio.

### Task 2: Evaluador de reglas automáticas

**Files:**
- Create: `supabase/functions/run-notification-events/evaluator.ts`
- Create: `supabase/functions/run-notification-events/evaluator_test.ts`

- [ ] Implementar selección de reglas activas vigentes.
- [ ] Implementar `schedule.interval` y `schedule.at_time` con ventana de un minuto y UTC/IANA.
- [ ] Implementar `content.published` y `content.updated` usando `updated_at` e idempotencia.
- [ ] Implementar `progress.streak_reminder` y `progress.streak_milestone` con variables por perfil.
- [ ] Rechazar configuraciones inválidas sin detener las demás reglas.

### Task 3: Edge Function del runner

**Files:**
- Create: `supabase/functions/run-notification-events/index.ts`
- Create: `supabase/functions/run-notification-events/repository.ts`
- Create: `supabase/functions/run-notification-events/deno.json`
- Test: `supabase/functions/run-notification-events/index_test.ts`

- [ ] Autenticar el invocador con secreto interno y cliente service-role únicamente dentro de la función.
- [ ] Procesar cada ocurrencia de forma idempotente, por lotes y con límite de concurrencia.
- [ ] Responder con resumen de reglas evaluadas, dispatches creados, reutilizados y errores.
- [ ] Agregar modo `dry_run` para probar sin enviar FCM.

### Task 4: Supabase y operación

**Files:**
- Create: `docs/supabase/notification_event_runner_manual.sql`
- Modify: `docs/supabase/notification_events_dispatches_inbox_manual.sql`

- [ ] Corregir checks de categoría para incluir `progress` en dispatches e inbox.
- [ ] Crear el Cron de un minuto usando Vault y `net.http_post`.
- [ ] Documentar secretos, despliegue, verificación y apagado seguro del Cron.

### Task 5: Verificación

- [ ] Ejecutar pruebas Deno de manual dispatch y runner.
- [ ] Desplegar la función con JWT verification o autenticación interna equivalente.
- [ ] Verificar logs, una regla `schedule.at_time`, un contenido publicado y un usuario con dispositivo Android.
- [ ] Activar reglas automáticas sólo después de que el dry run y el envío real sean correctos.
