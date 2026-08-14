# Notification Devices Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar `notification_devices` como dominio offline-first por perfil y garantizar que una instalación activa se desactive antes del cierre de sesión.

**Architecture:** La implementación replica `user_content_states`: Drift y DAO como fuente local, `BaseService` para Supabase, `BaseSync` limitado al perfil autenticado y un `ChangeNotifier` registrado en `AppDataContainer`/`AppDataScope`. Firebase no se inicializa en esta fase; el controller recibe `installation_id`, token, plataforma, permiso y versión desde el futuro runtime Firebase.

**Tech Stack:** Flutter, Dart, Drift, Supabase Flutter, `ChangeNotifier`, `flutter_test` y SQLite en memoria.

## Global Constraints

- Mantener exactamente los campos y estados aprobados en `docs/superpowers/specs/2026-07-16-notification-devices-design.md`.
- No agregar una migración Supabase al repositorio; entregar SQL manual al usuario.
- No inventar tokens ni Firebase Installation IDs.
- No modificar comportamiento visual ni textos no relacionados.
- Preservar cambios locales existentes en archivos compartidos.
- En web, operar por servicio remoto sin Drift, como los controllers existentes.

---

### Task 1: Persistencia local y modelo

**Files:**
- Create: `lib/core/data/local/tables/notification_devices_table.dart`
- Create: `lib/core/data/local/daos/notification_devices_dao.dart`
- Create: `lib/core/data/models/app_notification_device.dart`
- Modify: `lib/core/data/local/app_database.dart`
- Generate: `lib/core/data/local/app_database.g.dart`
- Test: `test/core/data/notification_devices_dao_test.dart`

**Interfaces:**
- Produces: `NotificationDevicesTable`, `LocalNotificationDevice`, `NotificationDevicesDao`, `AppNotificationDevice`.
- DAO methods: `getByUuid`, `getByProfileAndInstallation`, `getForProfile`, `getAllForProfile`, `watchForProfile`, `upsertNotificationDevice`, `upsertNotificationDevices`, `updateRegistration`, `deactivateByProfileAndInstallation`, `getPendingSync`, `getPendingSyncForProfile`, `markSyncedByUuid`.

- [ ] **Step 1: Write failing DAO tests**

Create tests that insert a nullable token, retrieve by `(uuid_profile, installation_id)`, update registration with `synced_at = null`, and deactivate without setting `deleted_at`:

```dart
final row = await dao.getByProfileAndInstallation('profile-1', 'fid-1');
expect(row?.fcmToken, isNull);

await dao.updateRegistration(
  row!.uuidNotificationDevice,
  fcmToken: 'token-2',
  platform: 'android',
  permissionStatus: 'authorized',
  appVersion: '1.0.0+1',
  isActive: true,
  registrationRefreshedAt: refreshedAt,
);
expect((await dao.getByUuid(row.uuidNotificationDevice))?.syncedAt, isNull);

await dao.deactivateByProfileAndInstallation('profile-1', 'fid-1');
final inactive = await dao.getByUuid(row.uuidNotificationDevice);
expect(inactive?.isActive, isFalse);
expect(inactive?.deletedAt, isNull);
```

- [ ] **Step 2: Run the DAO test and confirm red**

Run: `flutter test test/core/data/notification_devices_dao_test.dart`

Expected: compilation failure because the table and DAO do not exist.

- [ ] **Step 3: Implement table, DAO and model**

The table must centralize:

```dart
const notificationDevicePlatforms = ['android', 'ios', 'web'];
const notificationPermissionStatuses = [
  'authorized',
  'denied',
  'not_determined',
  'provisional',
];
```

Use `uuidNotificationDevice` as primary key and `{uuidProfile, installationId}` as a Drift unique key. Every functional mutation sets `updatedAt` to UTC and `syncedAt` to null. `AppNotificationDevice.canReceivePush` requires active, not deleted, non-empty token and an authorized/provisional permission.

- [ ] **Step 4: Register the table and generate Drift**

Add `NotificationDevicesTable` to `@DriftDatabase`, increase `schemaVersion` from `6` to `7`, and create the table when `from < 7`.

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: generated classes `LocalNotificationDevice` and `NotificationDevicesTableCompanion` exist in `app_database.g.dart`.

- [ ] **Step 5: Run DAO tests**

Run: `flutter test test/core/data/notification_devices_dao_test.dart`

Expected: all tests pass.

### Task 2: Servicio remoto, mappers y sync por perfil

**Files:**
- Create: `lib/core/data/remote/services/notification_devices_remote_service.dart`
- Create: `lib/core/data/sync/notification_devices_sync_service.dart`
- Modify: `lib/core/data/remote/supabase_tables.dart`
- Modify: `lib/core/data/sync/sync_mappers.dart`
- Test: `test/core/data/notification_devices_mappers_test.dart`

**Interfaces:**
- Produces: `NotificationDevicesRemoteService`, `NotificationDevicesSyncService`, `notificationDeviceToRemote`, `notificationDeviceRemoteToCompanion`, `notificationDeviceRemoteToApp`.
- Remote methods: `getForProfileOnline`, `getByProfileAndInstallationOnline`, `updateRegistrationOnline`, `deactivateOnline`.
- Sync methods: `pullForProfile`, `syncForProfile`.

- [ ] **Step 1: Write failing mapper tests**

Verify that remote JSON accepts null token/version/refresh date, preserves normalized fields, and marks pulled rows as synchronized:

```dart
final companion = notificationDeviceRemoteToCompanion(remoteJson);
expect(companion.fcmToken.value, isNull);
expect(companion.appVersion.value, isNull);
expect(companion.registrationRefreshedAt.value, isNull);
expect(companion.syncedAt.value, isNotNull);
```

- [ ] **Step 2: Run mapper tests and confirm red**

Run: `flutter test test/core/data/notification_devices_mappers_test.dart`

Expected: compilation failure because the mappers do not exist.

- [ ] **Step 3: Implement service, mappers and profile-scoped sync**

`notificationDeviceToRemote` sends all business/audit fields except the local `synced_at` marker. `notificationDeviceRemoteToCompanion` sets local `syncedAt` to `DateTime.now().toUtc()`. The profile-scoped sync must use `getAllForProfile` and `getPendingSyncForProfile`, never a global pull for ordinary user flows.

- [ ] **Step 4: Run mapper and DAO tests**

Run: `flutter test test/core/data/notification_devices_mappers_test.dart test/core/data/notification_devices_dao_test.dart`

Expected: all tests pass.

### Task 3: Controller de instalaciones

**Files:**
- Create: `lib/core/data/providers/notification_devices_controller.dart`
- Test: `test/core/data/notification_devices_controller_test.dart`

**Interfaces:**
- Consumes: DAO, remote service, sync service and notification device mappers.
- Produces: `watchForProfile`, `loadForProfile`, `registerCurrentInstallation`, `deactivateCurrentInstallation`, `syncWithRemote`, `pullFromRemote`, `clear`.

- [ ] **Step 1: Write failing controller tests**

Test the local path with SQLite memory:

```dart
controller.watchForProfile('profile-1');
await controller.registerCurrentInstallation(
  installationId: 'fid-1',
  fcmToken: null,
  platform: 'android',
  permissionStatus: 'not_determined',
  appVersion: '1.0.0+1',
  registrationRefreshedAt: null,
);

final originalUuid = controller.currentInstallation?.uuidNotificationDevice;
await controller.registerCurrentInstallation(
  installationId: 'fid-1',
  fcmToken: 'token-1',
  platform: 'android',
  permissionStatus: 'authorized',
  appVersion: '1.0.0+1',
  registrationRefreshedAt: DateTime.utc(2026, 7, 16),
);
expect(controller.currentInstallation?.uuidNotificationDevice, originalUuid);
expect(controller.currentInstallation?.canReceivePush, isTrue);
```

Also verify invalid platform/status throw `ArgumentError` and deactivation sets `isActive` false.

- [ ] **Step 2: Run controller tests and confirm red**

Run: `flutter test test/core/data/notification_devices_controller_test.dart`

Expected: compilation failure because the controller does not exist.

- [ ] **Step 3: Implement controller**

Generate UUID v4 locally following existing controllers. Store `_activeProfileUuid` and `_activeInstallationId`. Reuse a matching row, reactivate it, and set `syncedAt` null. In remote-only mode, use `upsertOnline` and reload the profile. `deactivateCurrentInstallation(requireRemoteConfirmation: true)` must throw if remote confirmation fails while an active non-empty token exists.

- [ ] **Step 4: Run controller tests**

Run: `flutter test test/core/data/notification_devices_controller_test.dart`

Expected: all tests pass.

### Task 4: Central wiring and logout ordering

**Files:**
- Modify: `lib/core/data/providers/current_profile_controller.dart`
- Modify: `lib/core/data/providers/app_data_container.dart`
- Modify: `lib/core/data/providers/app_data_scope.dart`
- Test: `test/core/data/current_profile_logout_lifecycle_test.dart`

**Interfaces:**
- `CurrentProfileController` accepts optional `Future<void> Function()? beforeSignOut`.
- `AppDataContainer` exposes DAO, remote service, sync service and `NotificationDevicesController`.
- `AppDataScope.notificationDevices(context)` returns the centralized controller.

- [ ] **Step 1: Write failing logout ordering test**

Subclass `AuthRemoteService` with an overridden `signOut` that appends `remote-sign-out` to a list. Inject `beforeSignOut` that appends `deactivate-device`:

```dart
await controller.signOut();
expect(events, ['deactivate-device', 'remote-sign-out']);
```

Add a failure case where `beforeSignOut` throws and assert that remote sign-out is never called.

- [ ] **Step 2: Run lifecycle test and confirm red**

Run: `flutter test test/core/data/current_profile_logout_lifecycle_test.dart`

Expected: compilation failure because `beforeSignOut` is not accepted.

- [ ] **Step 3: Implement lifecycle hook and dependency wiring**

Call `beforeSignOut` before `authService.signOut` in both explicit logout and startup enforcement. Construct notification device dependencies in `AppDataContainer`; when the current profile changes, watch or clear notification devices alongside the existing profile-owned controllers. Inject a closure que invoque `notificationDevicesController.deactivateCurrentInstallation(requireRemoteConfirmation: true)` en `CurrentProfileController`.

Do not clear profile state inside the catch path before rethrowing a failed pre-logout callback; the session must remain available for retry.

- [ ] **Step 4: Run focused tests**

Run: `flutter test test/core/data/notification_devices_dao_test.dart test/core/data/notification_devices_mappers_test.dart test/core/data/notification_devices_controller_test.dart test/core/data/current_profile_logout_lifecycle_test.dart`

Expected: all tests pass.

### Task 5: Verification and Supabase handoff

**Files:**
- Verify all modified and generated Dart files.
- Do not create a Supabase migration file.

**Interfaces:**
- Produces: validated Flutter implementation and SQL commands in the final response.

- [ ] **Step 1: Format changed Dart files**

Run `dart format` only on the new notification files, their tests and the central files touched by this feature.

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`

Expected: no new errors or warnings attributable to this feature.

- [ ] **Step 3: Run full test suite**

Run: `flutter test -r expanded`

Expected: all tests pass.

- [ ] **Step 4: Review diff scope**

Run: `git diff --check` and inspect `git status --short`. Confirm no unrelated file was modified or reverted.

- [ ] **Step 5: Deliver manual Supabase SQL**

Provide idempotent SQL containing `pgcrypto`, table, FK, checks, trigger, unique constraints/indexes, regular indexes, RLS and owner/admin policies. Explain that the table must exist before enabling registration and that Firebase configuration remains a separate step.
