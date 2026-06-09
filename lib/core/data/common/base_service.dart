import 'dart:async';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class BaseService {
  BaseService({
    required this.table,
    required this.idColumn,
    SupabaseClient? supabase,
    this.orderColumn = 'updated_at',
    String? headSelect,
    this.onConflict,
    this.deletedAtColumn = 'deleted_at',
    this.updatedAtColumn = 'updated_at',
    this.pageSize = 1000,
    this.idsChunk = 200,
    this.remoteTimeout = const Duration(seconds: 15),
    String? logTag,
  }) : supabase = _resolveSupabaseClient(supabase),
       headSelect = headSelect ?? '$idColumn, updated_at',
       logTag = logTag ?? 'BaseService.$table';

  final SupabaseClient supabase;

  final String table;
  final String idColumn;
  final String orderColumn;
  final String headSelect;
  final String? onConflict;

  final String deletedAtColumn;
  final String updatedAtColumn;

  final int pageSize;
  final int idsChunk;

  final Duration remoteTimeout;
  final String logTag;

  static SupabaseClient _resolveSupabaseClient(SupabaseClient? client) {
    if (client != null) {
      return client;
    }

    throw StateError(
      'No hay cliente de Supabase inyectado en BaseService. '
      'Inicializa Supabase en el arranque y pasa supabase desde el punto único de composición.',
    );
  }

  // ---------------------------------------------------------------------------
  // TIME
  // ---------------------------------------------------------------------------

  DateTime nowUtc() => DateTime.now().toUtc();

  String isoUtc(DateTime date) => date.toUtc().toIso8601String();

  // ---------------------------------------------------------------------------
  // HELPERS PRIVADOS
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _touchUpdatedAt(
    Map<String, dynamic> patch, {
    required DateTime now,
    bool touch = true,
  }) {
    if (!touch) return patch;

    // Si el patch ya trae updated_at explícito, lo respetamos.
    if (patch.containsKey(updatedAtColumn)) {
      return patch;
    }

    return <String, dynamic>{...patch, updatedAtColumn: isoUtc(now)};
  }

  PostgrestTransformBuilder<PostgrestList> _applyStableOrder(
    PostgrestFilterBuilder<PostgrestList> query, {
    required String orderBy,
    required bool ascending,
  }) {
    final ordered = query.order(orderBy, ascending: ascending);

    if (orderBy == idColumn) {
      return ordered;
    }

    return ordered.order(idColumn, ascending: ascending);
  }

  // ---------------------------------------------------------------------------
  // REMOTE GUARD
  // ---------------------------------------------------------------------------

  Future<T> runRemote<T>(
    String operation,
    Future<T> Function() action, {
    Duration? timeout,
  }) async {
    try {
      return await action().timeout(timeout ?? remoteTimeout);
    } on TimeoutException {
      log('timeout operation=$operation table=$table', name: logTag);
      rethrow;
    } catch (error) {
      log('error operation=$operation table=$table error=$error', name: logTag);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SELECT PAGINADO
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> selectPaginated(
    String selectColumns, {
    PostgrestFilterBuilder<PostgrestList> Function(
      PostgrestFilterBuilder<PostgrestList> query,
    )?
    apply,
    bool ascending = true,
    String? orderByColumn,
  }) async {
    final orderBy = orderByColumn ?? orderColumn;
    final rows = <Map<String, dynamic>>[];

    var from = 0;

    while (true) {
      final to = from + pageSize - 1;

      PostgrestFilterBuilder<PostgrestList> query = supabase
          .from(table)
          .select(selectColumns);

      if (apply != null) {
        query = apply(query);
      }

      final page = await runRemote(
        'selectPaginated',
        () => _applyStableOrder(
          query,
          orderBy: orderBy,
          ascending: ascending,
        ).range(from, to),
      );

      final batch = List<Map<String, dynamic>>.from(page);
      rows.addAll(batch);

      if (batch.length < pageSize) {
        break;
      }

      from += pageSize;
    }

    return rows;
  }

  // ---------------------------------------------------------------------------
  // SINGLE / EXISTS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getSingleOnlineWhere(
    String selectColumns, {
    required PostgrestFilterBuilder<PostgrestList> Function(
      PostgrestFilterBuilder<PostgrestList> query,
    )
    apply,
    String? orderByColumn,
    bool ascending = true,
  }) async {
    final orderBy = orderByColumn ?? orderColumn;

    PostgrestFilterBuilder<PostgrestList> query = supabase
        .from(table)
        .select(selectColumns);

    query = apply(query);

    final response = await runRemote(
      'getSingleOnlineWhere',
      () => _applyStableOrder(
        query,
        orderBy: orderBy,
        ascending: ascending,
      ).limit(1),
    );

    final rows = List<Map<String, dynamic>>.from(response);
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> existsOnlineWhere({
    required PostgrestFilterBuilder<PostgrestList> Function(
      PostgrestFilterBuilder<PostgrestList> query,
    )
    apply,
  }) async {
    PostgrestFilterBuilder<PostgrestList> query = supabase
        .from(table)
        .select(idColumn);

    query = apply(query);

    final response = await runRemote('existsOnlineWhere', () => query.limit(1));

    return List<Map<String, dynamic>>.from(response).isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // READ HELPERS
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAllOnline({
    String selectColumns = '*',
  }) {
    return selectPaginated(selectColumns, ascending: true);
  }

  Future<List<Map<String, dynamic>>> getFilteredOnline(
    DateTime lastSync, {
    String selectColumns = '*',
  }) {
    return selectPaginated(
      selectColumns,
      ascending: true,
      apply: (query) => query.gt(orderColumn, isoUtc(lastSync)),
    );
  }

  Future<DateTime?> checkLatestOnlineUpdate() async {
    final response = await runRemote(
      'checkLatestOnlineUpdate',
      () => supabase
          .from(table)
          .select(orderColumn)
          .order(orderColumn, ascending: false)
          .limit(1),
    );

    if (response.isEmpty || response.first[orderColumn] == null) {
      return null;
    }

    return DateTime.parse(response.first[orderColumn].toString()).toUtc();
  }

  Future<List<Map<String, dynamic>>> getHeadsOnline() {
    return selectPaginated(headSelect, ascending: true);
  }

  Future<List<Map<String, dynamic>>> getByIdsOnline(
    List<String> ids, {
    String? filterColumn,
    String selectColumns = '*',
  }) async {
    if (ids.isEmpty) {
      return [];
    }

    final column = filterColumn ?? idColumn;
    final rows = <Map<String, dynamic>>[];

    for (var index = 0; index < ids.length; index += idsChunk) {
      final chunk = ids.sublist(
        index,
        index + idsChunk > ids.length ? ids.length : index + idsChunk,
      );

      final response = await runRemote(
        'getByIdsOnline',
        () => _applyStableOrder(
          supabase.from(table).select(selectColumns).inFilter(column, chunk),
          orderBy: orderColumn,
          ascending: true,
        ),
      );

      rows.addAll(List<Map<String, dynamic>>.from(response));
    }

    return rows;
  }

  // ---------------------------------------------------------------------------
  // WRITE HELPERS
  // ---------------------------------------------------------------------------

  Future<void> upsertOnline(Map<String, dynamic> data) async {
    await runRemote(
      'upsertOnline',
      () => supabase.from(table).upsert(data, onConflict: onConflict),
    );
  }

  Future<void> upsertBatchOnline(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) {
      return;
    }

    await runRemote(
      'upsertBatchOnline',
      () => supabase.from(table).upsert(rows, onConflict: onConflict),
    );
  }

  Future<void> updateOnlineById(
    String id,
    Map<String, dynamic> patch, {
    bool touchUpdatedAt = true,
  }) async {
    final now = nowUtc();

    final body = _touchUpdatedAt(patch, now: now, touch: touchUpdatedAt);

    await runRemote(
      'updateOnlineById',
      () => supabase.from(table).update(body).eq(idColumn, id),
    );
  }

  Future<void> softDeleteOnline(String id) async {
    final now = nowUtc();

    await updateOnlineById(id, {
      deletedAtColumn: isoUtc(now),
    }, touchUpdatedAt: true);
  }
}
