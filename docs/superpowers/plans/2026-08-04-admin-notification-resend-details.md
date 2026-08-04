# Admin Notification Resend And Details Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Aiki's Android notification icon, a read-only dispatch detail page with inbox analytics, and idempotent resend/retry actions for manual notifications.

**Architecture:** Keep `notification_dispatches` and `notifications_inbox` authoritative in Supabase. Extend the existing manual Edge Function contract so a new resend creates a new dispatch from the original immutable snapshot, while a failed zero-success dispatch keeps its existing retry path. Add a typed admin-only analytics query over inbox/profile rows and connect it to a dedicated Flutter detail page opened from history cards.

**Tech Stack:** Flutter/Dart, Drift, Supabase Flutter, Supabase Edge Functions, Deno/TypeScript, Firebase Cloud Messaging HTTP v1, Android resources.

## Global Constraints

- Do not add tables or migrations; reuse `notification_dispatches` source fields and existing inbox `opened_at`/`read_at`.
- `success_device_count` must be labeled as FCM accepted, never as guaranteed physical delivery.
- Preserve the original dispatch and inbox rows when resending.
- Keep local inbox synchronization scoped to the authenticated profile; admin analytics use an explicit remote query.
- Use the existing AIKI typography, colors, cards, buttons, spacing, and saving overlay.
- Preserve existing worktree changes and do not change unrelated notification or session behavior.
- Use ASCII for new code/comments unless an existing user-facing string requires Spanish UTF-8.

---

### Task 1: Commit the approved design and establish test seams

**Files:**
- Create: `docs/superpowers/specs/2026-08-04-admin-notification-resend-details-design.md`
- Create: `docs/superpowers/plans/2026-08-04-admin-notification-resend-details.md`
- Test: existing notification test folders listed below

**Interfaces:**
- Produces the approved semantics for FCM acceptance, inbox opening/reading, exact-snapshot resends, and Android icon configuration.
- No runtime behavior changes.

- [ ] **Step 1: Self-review the design and plan**
  - Confirm every design requirement maps to Tasks 2-8.
  - Search the plan for `TODO`, `TBD`, and vague placeholder instructions.
  - Confirm all later method names match the interfaces introduced in the plan.

- [ ] **Step 2: Commit only the two documentation files**
  - Stage only the design and plan paths, leaving the dirty worktree and untracked Edge Function source untouched.
  - Run:
    `git add docs/superpowers/specs/2026-08-04-admin-notification-resend-details-design.md docs/superpowers/plans/2026-08-04-admin-notification-resend-details.md`
  - Commit:
    `git commit -m "docs: plan notification resend and dispatch details"`

---

### Task 2: Extend the Edge Function request contract for idempotent resends

**Files:**
- Modify: `supabase/functions/dispatch-notification-event/domain.ts`
- Modify: `supabase/functions/dispatch-notification-event/handler.ts`
- Modify: `supabase/functions/dispatch-notification-event/service.ts`
- Modify: `supabase/functions/dispatch-notification-event/supabase_repository.ts`
- Test: `supabase/functions/dispatch-notification-event/domain_test.ts`
- Test: `supabase/functions/dispatch-notification-event/handler_test.ts`
- Test: `supabase/functions/dispatch-notification-event/service_test.ts`

**Interfaces:**
- Request JSON:
  `{ mode: "send", uuid_notification_event: UUID, request_id: UUID, source_dispatch_uuid?: UUID, retry_dispatch_uuid?: UUID }`.
- `parseDispatchRequest(value)` returns `requestId: string`, optional `sourceDispatchUuid: string | null`, and optional `retryDispatchUuid: string | null`.
- `DispatchService.send(uuidNotificationEvent, uuidAdminProfile, requestId, sourceDispatchUuid)`.
- The HTTP 202 response continues returning the new or reused dispatch UUID and adds `source_dispatch_uuid` when available.

- [ ] **Step 1: Add failing parser tests**
  - Assert a send request rejects missing/invalid `request_id`.
  - Assert a valid resend accepts `source_dispatch_uuid`.
  - Assert preview does not accept or require resend fields.

- [ ] **Step 2: Run the focused parser tests and verify failure**
  - Run:
    `deno test --allow-env --allow-net supabase/functions/dispatch-notification-event/domain_test.ts supabase/functions/dispatch-notification-event/handler_test.ts`
  - Expected: FAIL because the request currently ignores request IDs and source dispatches.

- [ ] **Step 3: Implement strict request parsing**
  - Validate both UUIDs with the existing UUID pattern.
  - Keep `preview` behavior unchanged.
  - Reject source/retry dispatch UUIDs on preview and reject requests that provide both targets with a 400 request error.

- [ ] **Step 4: Add service idempotency tests**
  - Assert two sends with the same `request_id` resolve the same dispatch.
  - Assert a completed dispatch can be resent with a new request ID and produces a new dispatch.
  - Assert a processing dispatch is reused, not duplicated.
  - Assert a failed zero-success dispatch is retried in place.
  - Assert a resend copies title/body/category/audience/action/payload from the source dispatch snapshot, not from a later edited event.

- [ ] **Step 5: Implement service and repository support**
  - Derive normal keys as `manual:{eventUuid}:{requestId}` and resend keys as `manual-resend:{sourceDispatchUuid}:{requestId}`.
  - Add `loadDispatch(uuid)` and a source-snapshot dispatch creation input.
  - Route `retry_dispatch_uuid` through the existing failed zero-success retry path so it reuses the same dispatch UUID and idempotency key.
  - For resend, validate that the source dispatch belongs to the requested event and has a terminal status `completed`, `partial`, or `failed`; use its profile audience snapshot and action snapshot.
  - Create a new dispatch with `trigger_source = "manual"`, `source_entity_type = "notification_dispatch"`, and `source_entity_uuid = source dispatch UUID`.
  - For failed zero-success dispatches with `retry_dispatch_uuid`, preserve the existing same-dispatch retry path.
  - Keep inbox creation and FCM scheduling unchanged after the new dispatch is claimed.

- [ ] **Step 6: Run focused Edge Function tests**
  - Run:
    `deno test --allow-env --allow-net supabase/functions/dispatch-notification-event/*_test.ts`
  - Expected: all tests pass, including the new resend/idempotency cases.

---

### Task 3: Add typed Flutter command and analytics models

**Files:**
- Modify: `lib/core/data/remote/services/manual_notification_dispatch_remote_service.dart`
- Modify: `lib/core/data/models/manual_notification_dispatch_result.dart`
- Create: `lib/core/data/models/notification_dispatch_analytics.dart`
- Test: `test/core/data/models/notification_dispatch_analytics_test.dart`
- Test: focused remote-service tests if the repository has existing Supabase service fakes

**Interfaces:**
- `requestManualDispatch(String uuidEvent, {required String requestId})`.
- `requestManualResend(String uuidEvent, String sourceDispatchUuid, {required String requestId})`.
- `NotificationDispatchAnalytics.fromJson(Map<String, dynamic>)`.
- `NotificationDispatchRecipient` fields: profile UUID, display name/email, `openedAt`, `readAt`.
- `NotificationDispatchAnalytics` fields: target profiles, target devices, FCM accepted, failures, invalid tokens, inbox count, opened count, unread count, read count, and recipient rows.

- [ ] **Step 1: Write failing codec tests**
  - Decode a complete analytics response.
  - Assert counts reject negative/non-integer values.
  - Assert opened/read percentages are calculated from inbox recipients and avoid division by zero.
  - Decode null profile name using email fallback.

- [ ] **Step 2: Run the model tests and verify failure**
  - Run:
    `flutter test test/core/data/models/notification_dispatch_analytics_test.dart`
  - Expected: FAIL because the model does not exist.

- [ ] **Step 3: Implement immutable typed models**
  - Keep JSON parsing defensive and immutable.
  - Calculate:
    `notOpenedCount = inboxCount - openedCount`,
    `notReadCount = inboxCount - readCount`,
    `openRate = openedCount / inboxCount` when inbox count is nonzero,
    `readRate = readCount / inboxCount` when inbox count is nonzero.
  - Expose recipient status as `read`, `opened`, or `pending`.

- [ ] **Step 4: Extend the remote command service**
  - Send the new request fields.
  - Preserve current JWT refresh/retry behavior.
  - Parse `source_dispatch_uuid` and analytics JSON through the typed models.

- [ ] **Step 5: Run focused Flutter tests**
  - Run the analytics model and existing manual dispatch result tests.
  - Expected: PASS.

---

### Task 4: Add admin-only dispatch analytics query

**Files:**
- Modify: `supabase/functions/dispatch-notification-event/handler.ts`
- Modify: `supabase/functions/dispatch-notification-event/service.ts`
- Modify: `supabase/functions/dispatch-notification-event/supabase_repository.ts`
- Test: `supabase/functions/dispatch-notification-event/handler_test.ts`
- Test: `supabase/functions/dispatch-notification-event/service_test.ts`
- Test: `supabase/functions/dispatch-notification-event/repository_contract_test.ts`

**Interfaces:**
- Request JSON:
  `{ mode: "analytics", uuid_notification_dispatch: UUID }`.
- Response JSON:
  `{ uuid_notification_dispatch, target_profile_count, target_device_count, success_device_count, failure_device_count, invalid_token_count, inbox_count, opened_count, read_count, recipients: [{ uuid_profile, display_name, email, opened_at, read_at }] }`.
- `NotificationRepository.loadDispatchAnalytics(uuidDispatch)`.

- [ ] **Step 1: Add failing analytics tests**
  - Assert analytics is authenticated/admin-only through the existing handler dependency.
  - Assert recipient counts and statuses are derived from inbox rows.
  - Assert profile names are resolved without exposing FCM tokens.

- [ ] **Step 2: Run focused Deno tests and verify failure**
  - Run:
    `deno test --allow-env --allow-net supabase/functions/dispatch-notification-event/handler_test.ts supabase/functions/dispatch-notification-event/service_test.ts supabase/functions/dispatch-notification-event/repository_contract_test.ts`
  - Expected: FAIL because analytics mode is not parsed or implemented.

- [ ] **Step 3: Implement repository analytics reads**
  - Read the dispatch aggregate from `notification_dispatches`.
  - Read inbox rows by dispatch selecting only profile UUID and `opened_at`/`read_at`.
  - Read matching profile UUID/name/email rows separately.
  - Do not select or return FCM tokens, installation IDs, or private credentials.
  - Return rows in stable profile/name order.

- [ ] **Step 4: Implement service and handler serialization**
  - Keep analytics read-only.
  - Return the dispatch aggregate plus inbox/profile tracking.
  - Reject a missing/invalid dispatch UUID with 400 and a missing dispatch with 404.

- [ ] **Step 5: Run the complete Deno suite**
  - Run:
    `deno test --allow-env --allow-net supabase/functions/dispatch-notification-event/*_test.ts`
  - Expected: PASS.

---

### Task 5: Add Flutter analytics controller methods and history navigation

**Files:**
- Modify: `lib/core/data/remote/services/manual_notification_dispatch_remote_service.dart`
- Modify: `lib/core/data/providers/notification_dispatches_controller.dart`
- Modify: `lib/features/admin/admin_notifications/admin_notifications_page.dart`
- Create: `lib/features/admin/admin_notifications/admin_notification_dispatch_detail_page.dart`
- Test: focused controller/page tests under `test/features/admin/admin_notifications/`

**Interfaces:**
- `NotificationDispatchesController.loadAnalytics(AppNotificationDispatch dispatch)` returns `Future<NotificationDispatchAnalytics>`.
- `NotificationDispatchesController.requestResend(AppNotificationDispatch dispatch)` returns `Future<ManualNotificationDispatchAcceptance>`.
- `NotificationDispatchesController.requestRetry(AppNotificationDispatch dispatch)` returns `Future<ManualNotificationDispatchAcceptance>`.
- History card accepts `VoidCallback onTap` and invokes the detail route.

- [ ] **Step 1: Write failing controller/widget tests**
  - Tapping a history card pushes the detail page with the selected dispatch.
  - Detail page shows FCM accepted and inbox/open/read metrics.
  - Completed/partial shows `Reenviar`.
  - Failed zero-success shows `Reintentar`.
  - Processing shows no enabled send action.

- [ ] **Step 2: Run focused tests and verify failure**
  - Run:
    `flutter test test/features/admin/admin_notifications`
  - Expected: FAIL because the detail route, analytics controller methods, and actions do not exist.

- [ ] **Step 3: Implement controller command methods**
  - Generate one request UUID per user action and pass the same UUID through a network retry.
  - For retry, pass the selected failed dispatch UUID as `retry_dispatch_uuid`.
  - For resend, pass the selected dispatch UUID as source.
  - Pull recent dispatches after acceptance and surface command errors to the page.

- [ ] **Step 4: Implement detail page**
  - Use `AppBackground`, `AppResponsiveContainer`, existing AIKI typography/theme tokens, and `AppSavingOverlay`.
  - Load analytics in background while rendering the selected dispatch snapshot immediately.
  - Render a summary card, KPI grid, recipient list, error summary, and action button.
  - Use precise labels: `Aceptados por FCM`, `Abrieron`, `No abiertos`, `Leídos`.
  - Keep action buttons fixed-size and disable them during command execution.
  - Show retry/resend confirmation dialog with exact snapshot and audience.

- [ ] **Step 5: Connect history cards**
  - Add `onTap` to `AdminNotificationDispatchCard`.
  - Push `AdminNotificationDispatchDetailPage` from Historial.
  - Keep configuration cards unchanged except for any shared dispatch count text.

- [ ] **Step 6: Run focused Flutter tests**
  - Expected: PASS for controller, analytics, route, button-state, and detail rendering tests.

---

### Task 6: Configure the Aiki Android notification icon

**Files:**
- Create: `android/app/src/main/res/drawable/aiki_notification.webp`
- Create or modify: `android/app/src/main/res/values/colors.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Test: Android debug build and manual device notification test

**Interfaces:**
- Firebase Messaging default icon metadata points to `@drawable/aiki_notification`.
- Firebase Messaging default color points to the Aiki brand color.
- Launcher icon remains `@mipmap/ic_launcher`.

- [ ] **Step 1: Prepare the existing Aiki mark**
  - Use `assets/images/logo.webp` as the source mark.
  - Copy it to the Android drawable resource with an Android-safe resource name.
  - Verify the resource is transparent/monochrome enough for Android's small-icon mask; do not use the wide wordmark.

- [ ] **Step 2: Add manifest metadata**
  - Add:
    `com.google.firebase.messaging.default_notification_icon` with `@drawable/aiki_notification`.
  - Add the default notification color using the existing Aiki primary color.

- [ ] **Step 3: Build Android**
  - Run:
    `flutter build apk --debug --dart-define-from-file=supabase.defines.json`
  - Expected: successful Android debug APK.

- [ ] **Step 4: Manually verify icon**
  - Install/run on Android.
  - Put the app in background and send a test notification.
  - Confirm the notification tray uses the Aiki mark and the launcher icon did not change.

---

### Task 7: Deploy and verify the Edge Function

**Files:**
- Modify: all source files under `supabase/functions/dispatch-notification-event/` touched by Tasks 2-4

**Interfaces:**
- Active function `dispatch-notification-event` supports `preview`, `analytics`, and `send`.
- Existing secrets and `verify_jwt=true` remain unchanged.

- [ ] **Step 1: Run formatting and static checks**
  - Run:
    `deno fmt supabase/functions/dispatch-notification-event`
  - Run:
    `deno check supabase/functions/dispatch-notification-event/index.ts`

- [ ] **Step 2: Run the complete Deno suite**
  - Run:
    `deno test --allow-env --allow-net supabase/functions/dispatch-notification-event/*_test.ts`
  - Expected: all tests pass.

- [ ] **Step 3: Deploy through Supabase MCP**
  - Deploy `dispatch-notification-event` to project `hpysbnoaaallpbjfyafy` with `entrypoint_path: "index.ts"`, `import_map_path: "deno.json"`, and `verify_jwt: true`.
  - Include every touched runtime source file.
  - Confirm the deployed version is `ACTIVE`.

- [ ] **Step 4: Verify read-only analytics**
  - Use an authenticated admin session to request analytics for an existing dispatch.
  - Confirm counts match `notification_dispatches` and `notifications_inbox`.
  - Confirm the response contains no FCM token or installation ID.

---

### Task 8: End-to-end validation and cleanup

**Files:**
- Modify only files required by failing focused tests or analyzer output.
- Test: all focused tests, full relevant suite, Android build

- [ ] **Step 1: Run focused Flutter tests**
  - Run:
    `flutter test test/core/data/models/notification_dispatch_analytics_test.dart test/features/admin/admin_notifications`
  - Expected: PASS.

- [ ] **Step 2: Run static analysis**
  - Run:
    `flutter analyze`
  - Expected: no new analyzer errors.

- [ ] **Step 3: Run complete Edge Function checks**
  - Run:
    `deno test --allow-env --allow-net supabase/functions/dispatch-notification-event/*_test.ts`
  - Expected: PASS.
  - Run:
    `deno check supabase/functions/dispatch-notification-event/index.ts`
  - Expected: PASS.

- [ ] **Step 4: Run Android debug build**
  - Run:
    `flutter build apk --debug --dart-define-from-file=supabase.defines.json`
  - Expected: successful build.

- [ ] **Step 5: Manual acceptance checklist**
  - Send a manual notification and confirm the Aiki icon.
  - Open Historial and tap the dispatch card.
  - Confirm inbox/open/read KPIs and recipient states.
  - Resend a completed dispatch and confirm a second dispatch card appears while the original remains unchanged.
  - Retry a failed zero-success dispatch and confirm the same dispatch is reused.
