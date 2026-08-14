import 'dart:async';
import 'dart:developer';
import 'dart:io';

typedef PullRemoteHeads = Future<List<Map<String, dynamic>>> Function();
typedef PullRemoteRows =
    Future<List<Map<String, dynamic>>> Function(List<String> ids);
typedef PullGetAllLocal<L> = Future<List<L>> Function();
typedef PullUpsertBatchLocal<C> = Future<void> Function(List<C> items);
typedef PullGetId<L> = String Function(L row);
typedef PullGetUpdatedAt<L> = DateTime Function(L row);
typedef PullGetSyncedAt<L> = DateTime? Function(L row);
typedef PullRemoteToCompanion<C> = C Function(Map<String, dynamic> json);

class BasePullSync<L, C> {
  BasePullSync({
    required this.idColumnRemote,
    required this.updatedAtColumnRemote,
    required this.getRemoteHeads,
    required this.getRemoteRows,
    required this.getAllLocal,
    required this.upsertBatchLocal,
    required this.getId,
    required this.getUpdatedAt,
    required this.getSyncedAt,
    required this.remoteToCompanion,
    this.logTag = 'BasePullSync',
  });

  final String idColumnRemote;
  final String updatedAtColumnRemote;
  final PullRemoteHeads getRemoteHeads;
  final PullRemoteRows getRemoteRows;
  final PullGetAllLocal<L> getAllLocal;
  final PullUpsertBatchLocal<C> upsertBatchLocal;
  final PullGetId<L> getId;
  final PullGetUpdatedAt<L> getUpdatedAt;
  final PullGetSyncedAt<L> getSyncedAt;
  final PullRemoteToCompanion<C> remoteToCompanion;
  final String logTag;

  bool _isLocalSynced(L row) {
    final syncedAt = getSyncedAt(row);
    return syncedAt != null &&
        !syncedAt.toUtc().isBefore(getUpdatedAt(row).toUtc());
  }

  bool _isTemporaryRemoteFailure(Object error) {
    return error is TimeoutException || error is SocketException;
  }

  Future<void> pull() async {
    late final List<Map<String, dynamic>> heads;
    try {
      heads = await getRemoteHeads();
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
      final rawUpdatedAt = head[updatedAtColumnRemote];
      if (id.isEmpty || rawUpdatedAt == null) {
        continue;
      }

      final updatedAt = rawUpdatedAt is DateTime
          ? rawUpdatedAt.toUtc()
          : DateTime.tryParse(rawUpdatedAt.toString())?.toUtc();
      if (updatedAt != null) {
        remoteUpdatedAtById[id] = updatedAt;
      }
    }

    if (remoteUpdatedAtById.isEmpty) {
      return;
    }

    final localRows = await getAllLocal();
    final localById = <String, L>{for (final row in localRows) getId(row): row};
    final idsToFetch = <String>[];

    for (final entry in remoteUpdatedAtById.entries) {
      final local = localById[entry.key];
      if (local == null) {
        idsToFetch.add(entry.key);
        continue;
      }
      if (_isLocalSynced(local) &&
          entry.value.isAfter(getUpdatedAt(local).toUtc())) {
        idsToFetch.add(entry.key);
      }
    }

    if (idsToFetch.isEmpty) {
      return;
    }

    late final List<Map<String, dynamic>> rows;
    try {
      rows = await getRemoteRows(idsToFetch);
    } catch (error) {
      if (_isTemporaryRemoteFailure(error)) {
        log('pull rows skipped error=$error', name: logTag);
        return;
      }
      rethrow;
    }

    if (rows.isNotEmpty) {
      await upsertBatchLocal(rows.map(remoteToCompanion).toList());
    }
  }
}
