import 'package:drift/drift.dart';

import '../local/app_database.dart';

typedef WhereExpr<T extends Table> = Expression<bool> Function(T table);

class BaseDao<T extends Table, D> extends DatabaseAccessor<AppDatabase> {
  BaseDao(super.db, {required this.table});

  final TableInfo<T, D> table;

  DateTime nowUtc() => DateTime.now().toUtc();

  // ---------------------------------------------------------------------------
  // UPSERTS
  // ---------------------------------------------------------------------------

  Future<void> upsertOne(Insertable<D> companion) {
    return into(table).insertOnConflictUpdate(companion);
  }

  Future<void> upsertBatch<I extends Insertable<D>>(List<I> companions) async {
    if (companions.isEmpty) return;

    await batch((batch) {
      batch.insertAllOnConflictUpdate(table, companions);
    });
  }

  // ---------------------------------------------------------------------------
  // UPDATES
  // ---------------------------------------------------------------------------

  Future<int> writeWhere({
    required WhereExpr<T> where,
    required Insertable<D> companion,
  }) {
    return (update(table)..where(where)).write(companion);
  }

  Future<int> writeWhereNow({
    required WhereExpr<T> where,
    required Insertable<D> Function(DateTime nowUtc) patch,
  }) {
    return writeWhere(where: where, companion: patch(nowUtc()));
  }

  Future<int> updatePartialById({
    required WhereExpr<T> byId,
    required Insertable<D> patch,
  }) {
    return writeWhere(where: byId, companion: patch);
  }

  Future<int> updatePartialByIdNow({
    required WhereExpr<T> byId,
    required Insertable<D> Function(DateTime nowUtc) patch,
  }) {
    return writeWhereNow(where: byId, patch: patch);
  }

  Future<int> softDelete({
    required WhereExpr<T> byId,
    required Insertable<D> Function(DateTime nowUtc) patch,
  }) {
    return updatePartialByIdNow(byId: byId, patch: patch);
  }

  // ---------------------------------------------------------------------------
  // SINGLE / EXISTS
  // ---------------------------------------------------------------------------

  Future<D?> getSingleWhere(WhereExpr<T> where) {
    return (select(table)..where(where)).getSingleOrNull();
  }

  Future<bool> existsWhere(WhereExpr<T> where) async {
    final query = select(table)
      ..where(where)
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row != null;
  }

  Future<bool> existsAny() async {
    final query = selectOnly(table)
      ..addColumns([const Constant<int>(1)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row != null;
  }

  Future<bool> isEmpty() async => !(await existsAny());

  // ---------------------------------------------------------------------------
  // LIST / WATCH
  // ---------------------------------------------------------------------------

  Future<List<D>> listAll({List<OrderingTerm Function(T table)>? orderBy}) {
    final query = select(table);

    if (orderBy != null) {
      query.orderBy(orderBy);
    }

    return query.get();
  }

  Stream<List<D>> watchAll({List<OrderingTerm Function(T table)>? orderBy}) {
    final query = select(table);

    if (orderBy != null) {
      query.orderBy(orderBy);
    }

    return query.watch();
  }

  Future<List<D>> listWhere({
    required WhereExpr<T> where,
    List<OrderingTerm Function(T table)>? orderBy,
    int? limit,
    int? offset,
  }) {
    final query = select(table)..where(where);

    if (orderBy != null) {
      query.orderBy(orderBy);
    }

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  Stream<List<D>> watchWhere({
    required WhereExpr<T> where,
    List<OrderingTerm Function(T table)>? orderBy,
    int? limit,
    int? offset,
  }) {
    final query = select(table)..where(where);

    if (orderBy != null) {
      query.orderBy(orderBy);
    }

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.watch();
  }

  // ---------------------------------------------------------------------------
  // DELETED_AT HELPERS
  // ---------------------------------------------------------------------------

  Future<List<D>> listNotDeleted({
    required Expression<DateTime> Function(T table) deletedAt,
    List<OrderingTerm Function(T table)>? orderBy,
    int? limit,
    int? offset,
  }) {
    return listWhere(
      where: (table) => deletedAt(table).isNull(),
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Stream<List<D>> watchNotDeleted({
    required Expression<DateTime> Function(T table) deletedAt,
    List<OrderingTerm Function(T table)>? orderBy,
    int? limit,
    int? offset,
  }) {
    return watchWhere(
      where: (table) => deletedAt(table).isNull(),
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATED_AT HELPERS
  // ---------------------------------------------------------------------------

  Future<DateTime?> latestUpdatedAt({
    required Expression<DateTime> Function(T table) updatedAt,
    Expression<DateTime> Function(T table)? deletedAt,
    bool includeDeleted = false,
  }) async {
    final tableRef = table.asDslTable;
    final updatedColumn = updatedAt(tableRef);

    final query = selectOnly(table)..addColumns([updatedColumn]);

    if (!includeDeleted && deletedAt != null) {
      query.where(deletedAt(tableRef).isNull());
    }

    query
      ..orderBy([OrderingTerm.desc(updatedColumn)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.read(updatedColumn);
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Future<List<D>> listLikeAnyNoCase({
    required List<Expression<String> Function(T table)> columns,
    required String query,
    WhereExpr<T>? baseWhere,
    int? limit,
    int? offset,
    List<OrderingTerm Function(T table)>? orderBy,
  }) {
    final text = query.trim();

    if (text.isEmpty) {
      return listWhere(
        where: baseWhere ?? (_) => const Constant<bool>(true),
        limit: limit,
        offset: offset,
        orderBy: orderBy,
      );
    }

    final like = '%$text%';

    return listWhere(
      where: (table) {
        final base = baseWhere != null
            ? baseWhere(table)
            : const Constant<bool>(true);

        Expression<bool> match = const Constant<bool>(false);

        for (final column in columns) {
          match = match | column(table).collate(Collate.noCase).like(like);
        }

        return base & match;
      },
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );
  }

  Stream<List<D>> watchLikeAnyNoCase({
    required List<Expression<String> Function(T table)> columns,
    required String query,
    WhereExpr<T>? baseWhere,
    int? limit,
    int? offset,
    List<OrderingTerm Function(T table)>? orderBy,
  }) {
    final text = query.trim();

    if (text.isEmpty) {
      return watchWhere(
        where: baseWhere ?? (_) => const Constant<bool>(true),
        limit: limit,
        offset: offset,
        orderBy: orderBy,
      );
    }

    final like = '%$text%';

    return watchWhere(
      where: (table) {
        final base = baseWhere != null
            ? baseWhere(table)
            : const Constant<bool>(true);

        Expression<bool> match = const Constant<bool>(false);

        for (final column in columns) {
          match = match | column(table).collate(Collate.noCase).like(like);
        }

        return base & match;
      },
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );
  }

  // ---------------------------------------------------------------------------
  // SYNC
  // ---------------------------------------------------------------------------

  Future<List<D>> listPendingSync({
    required Expression<DateTime> Function(T table) syncedAt,
    required Expression<DateTime> Function(T table) updatedAt,
    Expression<DateTime> Function(T table)? deletedAt,
    bool includeDeleted = true,
  }) {
    return listWhere(
      where: (table) {
        final pending =
            syncedAt(table).isNull() |
            syncedAt(table).isSmallerThan(updatedAt(table));

        if (includeDeleted || deletedAt == null) {
          return pending;
        }

        return pending & deletedAt(table).isNull();
      },
    );
  }
}
