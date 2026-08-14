import 'package:aikiglobal/core/data/common/base_pull_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pull fetches missing and newer rows without replacing pending local', () async {
    final syncedAt = DateTime.utc(2026, 7, 16, 10);
    final rows = <_PullRow>[
      _PullRow(
        id: 'same',
        updatedAt: DateTime.utc(2026, 7, 16, 9),
        syncedAt: syncedAt,
      ),
      _PullRow(
        id: 'newer',
        updatedAt: DateTime.utc(2026, 7, 16, 9),
        syncedAt: syncedAt,
      ),
      _PullRow(
        id: 'pending',
        updatedAt: DateTime.utc(2026, 7, 16, 11),
        syncedAt: null,
      ),
    ];
    List<String>? requestedIds;
    List<String>? stored;
    final pullSync = BasePullSync<_PullRow, String>(
      idColumnRemote: 'id',
      updatedAtColumnRemote: 'updated_at',
      getRemoteHeads: () async => [
        {'id': 'same', 'updated_at': '2026-07-16T09:00:00.000Z'},
        {'id': 'newer', 'updated_at': '2026-07-16T12:00:00.000Z'},
        {'id': 'pending', 'updated_at': '2026-07-16T12:00:00.000Z'},
        {'id': 'missing', 'updated_at': '2026-07-16T12:00:00.000Z'},
      ],
      getRemoteRows: (ids) async {
        requestedIds = ids;
        return [for (final id in ids) {'id': id, 'updated_at': '2026-07-16T12:00:00.000Z'}];
      },
      getAllLocal: () async => rows,
      upsertBatchLocal: (items) async => stored = items,
      getId: (row) => row.id,
      getUpdatedAt: (row) => row.updatedAt,
      getSyncedAt: (row) => row.syncedAt,
      remoteToCompanion: (json) => json['id']! as String,
    );

    await pullSync.pull();

    expect(requestedIds, ['newer', 'missing']);
    expect(stored, ['newer', 'missing']);
  });
}

class _PullRow {
  const _PullRow({required this.id, required this.updatedAt, this.syncedAt});

  final String id;
  final DateTime updatedAt;
  final DateTime? syncedAt;
}
