# Content Media Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add multi-file media upload support for admin-managed content items.

**Architecture:** Add `content_media` as a first-class data entity parallel to `content_items`. Metadata syncs through Drift, DAOs, remote services, mappers, and controllers; binary files live in Supabase Storage bucket `content`.

**Tech Stack:** Flutter, Dart, Drift, Supabase Flutter, Supabase Storage, `file_picker`.

---

## File Structure

- Create `lib/core/data/models/app_content_media.dart` for app-facing media records.
- Create `lib/core/data/local/tables/content_media_table.dart` for Drift local storage.
- Create `lib/core/data/local/daos/content_media_dao.dart` for local media queries and pending sync.
- Create `lib/core/data/remote/services/content_media_remote_service.dart` for Supabase table access.
- Modify `lib/core/data/remote/services/content_media_storage_service.dart` to upload audio/video/sound files, not only covers.
- Create `lib/core/data/sync/content_media_sync_service.dart` and add mappers in `lib/core/data/sync/sync_mappers.dart`.
- Create `lib/core/data/providers/content_media_controller.dart` for UI state and admin media operations.
- Modify `lib/core/data/local/app_database.dart` to register the table and add a schema upgrade.
- Modify `lib/core/data/providers/app_data_container.dart` and `lib/core/data/providers/app_data_scope.dart` to compose/expose the controller.
- Modify `lib/features/admin/admin_content/admin_content_form_page.dart` to add the media section and publication validation.
- Modify `lib/features/explorar/content_detail_page.dart` and `lib/features/explorar/lesson_player_page.dart` only enough to show associated media titles.
- Modify `pubspec.yaml` with `file_picker`.
- Add focused tests under `test/core/data/`.

---

### Task 1: Add Media Model and Mapper Tests

**Files:**
- Create: `test/core/data/content_media_mappers_test.dart`
- Create: `lib/core/data/models/app_content_media.dart`
- Modify: `lib/core/data/sync/sync_mappers.dart`

- [ ] **Step 1: Write failing mapper tests**

```dart
import 'package:aikiglobal/core/data/sync/sync_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contentMediaRemoteToApp maps Supabase content_media columns', () {
    final appMedia = contentMediaRemoteToApp({
      'uuid_content_media': 'media-1',
      'uuid_content_item': 'content-1',
      'type': 'audio',
      'title': 'Respiracion inicial',
      'storage_path': 'content-1/media/media-1/file.mp3',
      'duration_seconds': 180,
      'sort_order': 2,
      'status': 'draft',
      'created_at': '2026-06-28T18:00:00Z',
      'updated_at': '2026-06-28T18:10:00Z',
      'deleted_at': null,
      'synced_at': null,
    });

    expect(appMedia.uuidContentMedia, 'media-1');
    expect(appMedia.uuidContentItem, 'content-1');
    expect(appMedia.tipo, 'audio');
    expect(appMedia.titulo, 'Respiracion inicial');
    expect(appMedia.storagePathSupabase, 'content-1/media/media-1/file.mp3');
    expect(appMedia.duracionSegundos, 180);
    expect(appMedia.orden, 2);
    expect(appMedia.status, 'draft');
    expect(appMedia.isPublishable, isTrue);
  });
}
```

- [ ] **Step 2: Run test and verify it fails**

Run: `flutter test test/core/data/content_media_mappers_test.dart`

Expected: FAIL because `contentMediaRemoteToApp` and `AppContentMedia` do not exist.

- [ ] **Step 3: Add `AppContentMedia` and mapper functions**

Implement `AppContentMedia` with fields matching the remote table plus `storagePathLocal`. Add `contentMediaRemoteToApp`, `contentMediaToRemote`, and `contentMediaRemoteToCompanion` in `sync_mappers.dart`.

- [ ] **Step 4: Run test and verify it passes**

Run: `flutter test test/core/data/content_media_mappers_test.dart`

Expected: PASS.

---

### Task 2: Add Drift Table, DAO, and Database Registration

**Files:**
- Create: `lib/core/data/local/tables/content_media_table.dart`
- Create: `lib/core/data/local/daos/content_media_dao.dart`
- Modify: `lib/core/data/local/app_database.dart`
- Generated: `lib/core/data/local/app_database.g.dart`

- [ ] **Step 1: Write DAO behavior test**

Create `test/core/data/content_media_dao_test.dart` covering:

```dart
test('getPublishableCountByContent ignores archived and deleted media', () async {
  final database = AppDatabase(executor: NativeDatabase.memory());
  final dao = ContentMediaDao(database);

  await dao.upsertContentMedia(ContentMediaTableCompanion.insert(
    uuidContentMedia: 'media-active',
    uuidContentItem: 'content-1',
    tipo: 'audio',
    titulo: const Value('Audio principal'),
    storagePathSupabase: 'content-1/media/media-active/file.mp3',
  ));
  await dao.upsertContentMedia(ContentMediaTableCompanion.insert(
    uuidContentMedia: 'media-archived',
    uuidContentItem: 'content-1',
    tipo: 'video',
    titulo: const Value('Video archivado'),
    storagePathSupabase: 'content-1/media/media-archived/file.mp4',
    status: const Value('archived'),
  ));

  expect(await dao.getPublishableCountByContent('content-1'), 1);
  await database.close();
});
```

- [ ] **Step 2: Run test and verify it fails**

Run: `flutter test test/core/data/content_media_dao_test.dart`

Expected: FAIL because the table and DAO do not exist.

- [ ] **Step 3: Add table and DAO**

`ContentMediaTable` maps local column names to the remote contract:

```dart
TextColumn get uuidContentMedia => text().named('uuid_content_media')();
TextColumn get uuidContentItem => text().named('uuid_content_item')();
TextColumn get tipo => text().named('type')();
TextColumn get titulo => text().named('title').nullable()();
TextColumn get storagePathSupabase => text().named('storage_path')();
TextColumn get storagePathLocal => text().named('storage_path_local').nullable()();
IntColumn get duracionSegundos => integer().named('duration_seconds').nullable()();
IntColumn get orden => integer().named('sort_order').withDefault(const Constant(0))();
TextColumn get status => text().withDefault(const Constant('draft'))();
```

The DAO must expose `watchByContent`, `getByContent`, `getPublishableCountByContent`, `getPendingSync`, `markSyncedByUuid`, `softDeleteByUuid`, and `updateMetadata`.

- [ ] **Step 4: Register table and migration**

Add `ContentMediaTable` to `@DriftDatabase`, set `schemaVersion => 2`, and add `MigrationStrategy` with `m.createTable(contentMediaTable)` when upgrading from version 1.

- [ ] **Step 5: Regenerate Drift**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: `app_database.g.dart` updates successfully.

- [ ] **Step 6: Run DAO test**

Run: `flutter test test/core/data/content_media_dao_test.dart`

Expected: PASS.

---

### Task 3: Add Remote Service and Sync

**Files:**
- Create: `lib/core/data/remote/services/content_media_remote_service.dart`
- Create: `lib/core/data/sync/content_media_sync_service.dart`
- Modify: `lib/core/data/remote/supabase_tables.dart`
- Modify: `lib/core/data/sync/sync_mappers.dart`

- [ ] **Step 1: Add service constant**

Add `static const contentMedia = 'content_media';`.

- [ ] **Step 2: Implement `ContentMediaRemoteService`**

It extends `BaseService` with `table: SupabaseTables.contentMedia`, `idColumn: 'uuid_content_media'`, `headSelect: 'uuid_content_media, updated_at'`, and `onConflict: 'uuid_content_media'`.

Add queries for media by content:

```dart
Future<List<Map<String, dynamic>>> getByContentOnline(String uuidContentItem) {
  return selectPaginated(
    '*',
    apply: (query) => query
        .eq('uuid_content_item', uuidContentItem.trim())
        .isFilter('deleted_at', null)
        .neq('status', 'archived'),
    orderByColumn: 'sort_order',
  );
}
```

- [ ] **Step 3: Implement `ContentMediaSyncService`**

Mirror `ContentItemsSyncService`, using `LocalContentMedia`, `ContentMediaTableCompanion`, `contentMediaToRemote`, and `contentMediaRemoteToCompanion`.

- [ ] **Step 4: Run static validation**

Run: `flutter analyze`

Expected: no new analyzer errors from service/sync additions.

---

### Task 4: Extend Storage Uploads for Media Files

**Files:**
- Modify: `lib/core/data/remote/services/content_media_storage_service.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

Run: `flutter pub add file_picker`

Expected: `pubspec.yaml` and `pubspec.lock` update.

- [ ] **Step 2: Add media upload method**

Add `uploadMedia` that accepts `uuidContentItem`, `uuidContentMedia`, bytes, file name, and content type. Store files at:

```text
<uuid_content_item>/media/<uuid_content_media>/<timestamp>.<ext>
```

Support extensions and MIME types for MP4/MOV/M4V, MP3/M4A/AAC/WAV/OGG.

- [ ] **Step 3: Keep cover behavior unchanged**

Run existing widget tests after this task.

Run: `flutter test test/widget_test.dart`

Expected: PASS.

---

### Task 5: Add ContentMediaController and Composition

**Files:**
- Create: `lib/core/data/providers/content_media_controller.dart`
- Modify: `lib/core/data/providers/app_data_container.dart`
- Modify: `lib/core/data/providers/app_data_scope.dart`

- [ ] **Step 1: Write controller validation test**

Create `test/core/data/content_media_controller_test.dart` for a pure validation helper:

```dart
test('isValidMediaType accepts only supported media types', () {
  expect(ContentMediaController.isValidMediaType('video'), isTrue);
  expect(ContentMediaController.isValidMediaType('audio'), isTrue);
  expect(ContentMediaController.isValidMediaType('ambient_sound'), isTrue);
  expect(ContentMediaController.isValidMediaType('pdf'), isFalse);
});
```

- [ ] **Step 2: Run test and verify it fails**

Run: `flutter test test/core/data/content_media_controller_test.dart`

Expected: FAIL because `ContentMediaController` does not exist.

- [ ] **Step 3: Implement controller**

Expose:

- `watchForContent(String uuidContentItem)`
- `loadForContent(String uuidContentItem)`
- `hasPublishableMedia(String uuidContentItem)`
- `addMedia(...)`
- `archiveMedia(String uuidContentMedia, {bool syncAfterUpdate = false})`
- `syncWithRemote()`
- `pullFromRemote()`

- [ ] **Step 4: Compose controller**

Create DAO/service/sync/controller in `AppDataContainer`, dispose it, and expose it via `AppDataScope.contentMedia(context)`.

- [ ] **Step 5: Run controller test**

Run: `flutter test test/core/data/content_media_controller_test.dart`

Expected: PASS.

---

### Task 6: Add Admin Form Media Section

**Files:**
- Modify: `lib/features/admin/admin_content/admin_content_form_page.dart`

- [ ] **Step 1: Add UI state**

Add form-level `String _uuidContentItem`, initialized from the existing item or a generated UUID from `ContentItemsController`.

- [ ] **Step 2: Add media section**

Show "Archivos del contenido", current media list, and an "Agregar archivo" action. Each media row shows icon, title, type, duration, order, and remove action.

- [ ] **Step 3: Add file picker flow**

When the user taps "Agregar archivo":

1. Validate title if this is a new content draft.
2. Save or upsert the parent content as `draft` without popping.
3. Ask for media type and media title.
4. Pick file using `file_picker`.
5. Call `ContentMediaController.addMedia`.

- [ ] **Step 4: Add publish validation**

Before `_save('published')`, call `contentMediaController.hasPublishableMedia(_uuidContentItem)`. If false, set `_errorMessage` to `Agrega al menos un archivo antes de publicar.` and stop.

- [ ] **Step 5: Preserve existing copy**

Do not rewrite existing labels except adding the new media section and validation text.

---

### Task 7: Show Media in Detail and Player

**Files:**
- Modify: `lib/features/explorar/content_detail_page.dart`
- Modify: `lib/features/explorar/lesson_player_page.dart`

- [ ] **Step 1: Load media by content id**

When `item.uuidContentItem` exists, use `AppDataScope.contentMedia(context)` to watch/load associated media.

- [ ] **Step 2: Replace fallback lesson titles when media exists**

Display media titles ordered by `sort_order`. Keep the current static lesson content only when no media exists.

- [ ] **Step 3: Keep playback visual if real playback is not implemented**

Do not introduce partial audio/video playback controls unless they are fully wired.

---

### Task 8: Verification

**Files:**
- All modified files.

- [ ] **Step 1: Run generated code**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: success.

- [ ] **Step 2: Run focused tests**

Run:

```powershell
flutter test test/core/data/content_media_mappers_test.dart
flutter test test/core/data/content_media_dao_test.dart
flutter test test/core/data/content_media_controller_test.dart
flutter test test/widget_test.dart
```

Expected: all pass.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze`

Expected: no new errors.

- [ ] **Step 4: Manual validation**

Validate in the app:

- Create a draft content item without media.
- Try to publish without media and confirm it is blocked.
- Add one audio file with a title.
- Publish successfully.
- Edit the content and confirm the media remains listed.
- Archive media and confirm publishing is blocked again when no active media remains.
