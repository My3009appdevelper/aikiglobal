import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'base_service.dart';

typedef GetAllLocal<L> = Future<List<L>> Function();
typedef GetPendingLocal<L> = Future<List<L>> Function();
typedef UpsertBatchLocal<C> = Future<void> Function(List<C> items);
typedef MarkSyncedLocal = Future<void> Function(String id);

typedef GetId<L> = String Function(L row);
typedef GetUpdatedAt<L> = DateTime Function(L row);
typedef GetSyncedAt<L> = DateTime? Function(L row);
typedef LocalToRemote<L> = Map<String, dynamic> Function(L row);
typedef RemoteToCompanion<C> = C Function(Map<String, dynamic> json);

class BaseSync<L, C> {
  BaseSync({
    required this.service,
    required this.idColumnRemote,
    required this.getAllLocal,
    required this.getPendingLocal,
    required this.upsertBatchLocal,
    required this.markSyncedLocal,
    required this.getId,
    required this.getUpdatedAt,
    required this.getSyncedAt,
    required this.localToRemote,
    required this.remoteToCompanion,
    String? logTag,
  }) : logTag = logTag ?? 'BaseSync.${service.table}';

  final BaseService service;
  final String idColumnRemote;
  final String logTag;
  final GetAllLocal<L> getAllLocal;
  final GetPendingLocal<L> getPendingLocal;
  final UpsertBatchLocal<C> upsertBatchLocal;
  final MarkSyncedLocal markSyncedLocal;
  final GetId<L> getId;
  final GetUpdatedAt<L> getUpdatedAt;
  final GetSyncedAt<L> getSyncedAt;
  final LocalToRemote<L> localToRemote;
  final RemoteToCompanion<C> remoteToCompanion;

  String get _updatedAtRemote => service.updatedAtColumn;

  bool _isLocalSynced(L row) {
    final syncedAt = getSyncedAt(row);
    if (syncedAt == null) {
      return false;
    }
    return !syncedAt.toUtc().isBefore(getUpdatedAt(row).toUtc());
  }

  bool _isTemporaryRemoteFailure(Object error) {
    return error is TimeoutException || error is SocketException;
  }

  Future<void> push() async {
    final pending = await getPendingLocal();
    if (pending.isEmpty) {
      return;
    }

    for (final row in pending) {
      final id = getId(row);
      try {
        await service.upsertOnline(localToRemote(row));
        await markSyncedLocal(id);
      } catch (error) {
        if (_isTemporaryRemoteFailure(error)) {
          log('push skipped id=$id error=$error', name: logTag);
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> pull() async {
    late final List<Map<String, dynamic>> heads;
    try {
      heads = await service.getHeadsOnline();
    } catch (error) {
      if (_isTemporaryRemoteFailure(error)) {
        log('pull heads skipped error=$error', name: logTag);
        return;
      }
      rethrow;
    }

    if (heads.isEmpty) {
      return;
    }

    final remoteUpdatedAtById = <String, DateTime>{};
    for (final head in heads) {
      final id = (head[idColumnRemote] ?? '').toString().trim();
      final updatedAt = head[_updatedAtRemote];

      if (id.isEmpty || updatedAt == null) {
        continue;
      }

      remoteUpdatedAtById[id] = DateTime.parse(updatedAt.toString()).toUtc();
    }

    if (remoteUpdatedAtById.isEmpty) {
      return;
    }

    final localRows = await getAllLocal();
    final localById = <String, L>{for (final row in localRows) getId(row): row};
    final idsToFetch = <String>[];

    remoteUpdatedAtById.forEach((id, remoteUpdatedAt) {
      final local = localById[id];
      if (local == null) {
        idsToFetch.add(id);
        return;
      }

      if (!_isLocalSynced(local)) {
        return;
      }

      if (remoteUpdatedAt.isAfter(getUpdatedAt(local).toUtc())) {
        idsToFetch.add(id);
      }
    });

    if (idsToFetch.isEmpty) {
      return;
    }

    late final List<Map<String, dynamic>> remoteRows;
    try {
      remoteRows = await service.getByIdsOnline(
        idsToFetch,
        filterColumn: idColumnRemote,
      );
    } catch (error) {
      if (_isTemporaryRemoteFailure(error)) {
        log('pull rows skipped error=$error', name: logTag);
        return;
      }
      rethrow;
    }

    if (remoteRows.isEmpty) {
      return;
    }

    await upsertBatchLocal(remoteRows.map(remoteToCompanion).toList());
  }

  Future<void> sync() async {
    await push();
    await pull();
  }
}
