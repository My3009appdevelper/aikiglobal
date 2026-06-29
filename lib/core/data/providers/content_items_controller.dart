import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../local/cache/local_media_cache.dart';
import '../local/daos/content_items_dao.dart';
import '../models/app_content_item.dart';
import '../remote/services/content_media_storage_service.dart';
import '../remote/services/content_items_remote_service.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/sync_mappers.dart';

class ContentItemsController extends ChangeNotifier {
  ContentItemsController({
    required ContentItemsDao? contentItemsDao,
    ContentItemsRemoteService? contentItemsRemoteService,
    ContentMediaStorageService? contentMediaStorageService,
    ContentItemsSyncService? syncService,
    LocalMediaCache? localMediaCache,
  }) : _contentItemsDao = contentItemsDao,
       _contentItemsRemoteService = contentItemsRemoteService,
       _contentMediaStorageService = contentMediaStorageService,
       _syncService = syncService,
       _localMediaCache = localMediaCache;

  final ContentItemsDao? _contentItemsDao;
  final ContentItemsRemoteService? _contentItemsRemoteService;
  final ContentMediaStorageService? _contentMediaStorageService;
  final ContentItemsSyncService? _syncService;
  final LocalMediaCache? _localMediaCache;

  static const _contentCoverCacheNamespace = 'content_covers';

  StreamSubscription<List<LocalContentItem>>? _itemsSubscription;
  StreamSubscription<List<LocalContentItem>>? _featuredSubscription;

  List<AppContentItem> _items = const [];
  List<AppContentItem> _featuredItems = const [];
  String? _activeTipo;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _adminMode = false;
  Object? _error;

  List<AppContentItem> get items => _items;
  List<AppContentItem> get featuredItems => _featuredItems;
  String? get activeTipo => _activeTipo;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get adminMode => _adminMode;
  Object? get error => _error;
  bool get hasRemote => _contentItemsRemoteService != null;

  Future<String?> resolveCoverImageUrl(String imagePath) {
    return _contentMediaStorageService?.createSignedUrl(imagePath) ??
        Future.value(null);
  }

  void watchPublished({String? tipo}) {
    _adminMode = false;
    _activeTipo = _cleanNullableText(tipo);
    _searchQuery = '';
    _cancelSubscriptions();

    if (_contentItemsDao == null) {
      unawaited(_loadRemotePublished(tipo: _activeTipo));
      return;
    }

    _subscribeItems(_contentItemsDao.watchPublished(tipo: _activeTipo));
    _subscribeFeatured(
      _contentItemsDao.watchFeaturedPublished(tipo: _activeTipo),
    );
  }

  void watchAdminAll() {
    _adminMode = true;
    _activeTipo = null;
    _searchQuery = '';
    _featuredItems = const [];
    _cancelSubscriptions();

    if (_contentItemsDao == null) {
      unawaited(_loadRemoteAll());
      return;
    }

    _subscribeItems(_contentItemsDao.watchAllNotDeleted());
    _featuredSubscription?.cancel();
    _featuredSubscription = null;
    notifyListeners();
  }

  Future<void> loadPublished({String? tipo}) async {
    _adminMode = false;
    _activeTipo = _cleanNullableText(tipo);
    _searchQuery = '';
    _cancelSubscriptions();

    final dao = _contentItemsDao;
    if (dao == null) {
      await _loadRemotePublished(tipo: _activeTipo);
      return;
    }

    final hasCachedPublished = await dao
        .getPublished(tipo: _activeTipo, limit: 1)
        .then((rows) => rows.isNotEmpty);

    if (!hasCachedPublished) {
      await pullFromRemote();
    }

    await _loadFromLocal(
      () async => dao.getPublished(tipo: _activeTipo),
      keepPreviousError: true,
    );

    if (_items.isNotEmpty) {
      _error = null;
      _featuredItems = _toAppItems(
        await dao.getFeaturedPublished(tipo: _activeTipo),
      );
      notifyListeners();
      return;
    }

    if (_contentItemsRemoteService != null) {
      await _loadRemotePublished(tipo: _activeTipo);
    }
  }

  Future<void> loadAdminAll() async {
    _adminMode = true;
    _activeTipo = null;
    _searchQuery = '';
    _featuredItems = const [];
    _cancelSubscriptions();

    final dao = _contentItemsDao;
    if (dao == null) {
      await _loadRemoteAll();
      return;
    }

    await _loadFromLocal(dao.getAllNotDeleted);
  }

  Future<List<AppContentItem>> getPublishedSnapshot({String? tipo}) async {
    final cleanTipo = _cleanNullableText(tipo);
    final dao = _contentItemsDao;
    if (dao != null) {
      final localItems = await dao.getPublished(tipo: cleanTipo);
      if (localItems.isNotEmpty || _contentItemsRemoteService == null) {
        return _toAppItems(localItems);
      }
    }

    final remoteService = _contentItemsRemoteService;
    if (remoteService != null) {
      final rows = await remoteService.getPublishedOnline(tipo: cleanTipo);
      return List.unmodifiable(rows.map(contentItemRemoteToApp));
    }

    return List.unmodifiable(
      _items.where((item) {
        final matchesTipo =
            cleanTipo == null || cleanTipo.isEmpty || item.tipo == cleanTipo;
        return item.isPublished && matchesTipo;
      }),
    );
  }

  Future<void> searchPublished(String query, {String? tipo}) async {
    _adminMode = false;
    _activeTipo = _cleanNullableText(tipo);
    _searchQuery = query.trim();
    _featuredItems = const [];

    final dao = _contentItemsDao;
    if (dao == null) {
      await _loadRemotePublishedSearch(_searchQuery, tipo: _activeTipo);
      return;
    }

    await _loadFromLocal(
      () => dao.searchPublished(_searchQuery, tipo: _activeTipo),
    );
  }

  Future<void> searchAdminAll(String query) async {
    _adminMode = true;
    _activeTipo = null;
    _searchQuery = query.trim();
    _featuredItems = const [];

    final dao = _contentItemsDao;
    if (dao == null) {
      await _loadRemoteSearchAll(_searchQuery);
      return;
    }

    await _loadFromLocal(() => dao.searchAllNotDeleted(_searchQuery));
  }

  Future<void> refreshFromRemote({bool includeAdminPush = false}) async {
    if (includeAdminPush) {
      await syncWithRemote();
      return;
    }

    await pullFromRemote();
  }

  Future<void> pullFromRemote() async {
    if (_contentItemsDao == null) {
      await _reloadCurrentRemoteView();
      return;
    }

    final syncService = _syncService;
    if (syncService == null) {
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.pull();
      await _cacheRemoteCoversFromLocal();
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> syncWithRemote() async {
    if (_contentItemsDao == null) {
      await _reloadCurrentRemoteView();
      return;
    }

    final syncService = _syncService;
    if (syncService == null) {
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.sync();
      await _cacheRemoteCoversFromLocal();
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> saveContentItem({
    String? uuidContentItem,
    required String tipo,
    required String titulo,
    String? subtitulo,
    String? descripcion,
    String? coverPathSupabase,
    String? coverPathLocal,
    Uint8List? coverBytes,
    String? coverFileName,
    String? coverContentType,
    required String status,
    required bool destacado,
    required bool descargable,
    int? duracionSegundos,
    required int orden,
    String? createdBy,
    bool syncAfterSave = false,
  }) async {
    final now = DateTime.now().toUtc();
    final cleanUuid = _cleanNullableText(uuidContentItem) ?? _generateUuidV4();
    final cleanTipo = tipo.trim().toLowerCase();
    final cleanTitulo = titulo.trim();
    final cleanStatus = status.trim().toLowerCase();

    if (cleanTipo.isEmpty) {
      throw ArgumentError('El tipo de contenido es obligatorio.');
    }
    if (cleanTitulo.isEmpty) {
      throw ArgumentError('El título del contenido es obligatorio.');
    }

    final existing = _itemByUuid(cleanUuid);
    final createdAt = existing?.createdAt ?? now;
    final previousCoverRemote =
        existing?.coverPathSupabase ?? _cleanNullableText(coverPathSupabase);
    final previousCoverLocal =
        existing?.coverPathLocal ?? _cleanNullableText(coverPathLocal);
    var nextCoverRemote = _cleanNullableText(coverPathSupabase);
    var nextCoverLocal =
        _cleanNullableText(coverPathLocal) ?? existing?.coverPathLocal;
    _UploadedContentCover? uploadedCover;

    final dao = _contentItemsDao;
    final remoteService = _contentItemsRemoteService;

    try {
      uploadedCover = await _uploadCoverIfNeeded(
        uuidContentItem: cleanUuid,
        bytes: coverBytes,
        fileName: coverFileName,
        contentType: coverContentType,
        previousLocalPath: previousCoverLocal,
      );

      if (uploadedCover != null) {
        nextCoverRemote = uploadedCover.remotePath;
        nextCoverLocal = uploadedCover.localPath;
      }

      if (dao != null) {
        await dao.upsertContentItem(
          ContentItemsTableCompanion.insert(
            uuidContentItem: cleanUuid,
            tipo: cleanTipo,
            titulo: cleanTitulo,
            subtitulo: Value(_cleanNullableText(subtitulo)),
            descripcion: Value(_cleanNullableText(descripcion)),
            coverPathSupabase: Value(nextCoverRemote),
            coverPathLocal: Value(nextCoverLocal),
            status: Value(cleanStatus),
            destacado: Value(destacado),
            descargable: Value(descargable),
            duracionSegundos: Value(duracionSegundos),
            orden: Value(orden),
            createdBy: Value(
              _cleanNullableText(createdBy) ?? existing?.createdBy,
            ),
            createdAt: Value(createdAt),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncedAt: const Value(null),
          ),
        );
      } else if (remoteService != null) {
        await remoteService.upsertOnline({
          'uuid_content_item': cleanUuid,
          'tipo': cleanTipo,
          'titulo': cleanTitulo,
          'subtitulo': _cleanNullableText(subtitulo),
          'descripcion': _cleanNullableText(descripcion),
          'cover_path_supabase': nextCoverRemote,
          'status': cleanStatus,
          'destacado': destacado,
          'descargable': descargable,
          'duracion_segundos': duracionSegundos,
          'orden': orden,
          'created_by': _cleanNullableText(createdBy) ?? existing?.createdBy,
          'created_at': remoteService.isoUtc(createdAt),
          'updated_at': remoteService.isoUtc(now),
          'deleted_at': null,
        });
        await _reloadCurrentRemoteView();
      }

      if (syncAfterSave) {
        await syncWithRemote();
      }

      final remoteMetadataUpdated =
          dao == null || (syncAfterSave && _error == null);
      if (remoteMetadataUpdated &&
          uploadedCover != null &&
          previousCoverRemote != null &&
          previousCoverRemote != uploadedCover.remotePath) {
        unawaited(_deleteRemoteMediaSafe(previousCoverRemote));
      }
    } catch (_) {
      if (uploadedCover != null) {
        unawaited(_deleteRemoteMediaSafe(uploadedCover.remotePath));
      }
      rethrow;
    }
  }

  Future<void> updateStatus(
    String uuidContentItem, {
    required String status,
    bool syncAfterUpdate = false,
  }) async {
    final dao = _contentItemsDao;
    final remoteService = _contentItemsRemoteService;

    if (dao != null) {
      await dao.updateStatus(uuidContentItem, status: status);
    } else if (remoteService != null) {
      await remoteService.updateStatusOnline(uuidContentItem, status);
      await _reloadCurrentRemoteView();
    }

    if (syncAfterUpdate) {
      await syncWithRemote();
    }
  }

  Future<void> updateFeatured(
    String uuidContentItem, {
    required bool destacado,
    bool syncAfterUpdate = false,
  }) async {
    final dao = _contentItemsDao;
    final remoteService = _contentItemsRemoteService;

    if (dao != null) {
      await dao.updateDestacado(uuidContentItem, destacado: destacado);
    } else if (remoteService != null) {
      await remoteService.updateFeaturedOnline(uuidContentItem, destacado);
      await _reloadCurrentRemoteView();
    }

    if (syncAfterUpdate) {
      await syncWithRemote();
    }
  }

  Future<void> archive(
    String uuidContentItem, {
    bool syncAfterUpdate = false,
  }) async {
    final dao = _contentItemsDao;
    final remoteService = _contentItemsRemoteService;

    if (dao != null) {
      await dao.softDeleteByUuid(uuidContentItem);
    } else if (remoteService != null) {
      await remoteService.archiveOnline(uuidContentItem);
      await _reloadCurrentRemoteView();
    }

    if (syncAfterUpdate) {
      await syncWithRemote();
    }
  }

  Future<void> updateLocalCoverPath(
    String uuidContentItem, {
    required String? coverPathLocal,
  }) {
    final dao = _contentItemsDao;
    if (dao != null) {
      return dao.updateCoverPathLocal(
        uuidContentItem,
        coverPathLocal: _cleanNullableText(coverPathLocal),
      );
    }

    return Future.value();
  }

  Future<void> _loadRemotePublished({String? tipo}) async {
    _featuredItems = const [];

    final service = _contentItemsRemoteService;

    if (service == null) {
      _error = StateError('No hay servicio remoto para contenidos publicados.');
      notifyListeners();
      return;
    }

    await _load(() async {
      final preferred = await service.getPublishedOnline(tipo: tipo);
      final rows = preferred.isNotEmpty
          ? preferred
          : await service.getPublishedOnlineFallback(tipo: tipo);

      return rows.map(contentItemRemoteToApp).toList();
    });

    final remoteRows = await service.getFeaturedPublishedOnline(tipo: tipo);

    _featuredItems = remoteRows.map(contentItemRemoteToApp).toList();
    notifyListeners();
  }

  Future<void> _loadRemotePublishedSearch(String query, {String? tipo}) async {
    final cleanQuery = query.trim().toLowerCase();

    await _load(() async {
      final rows =
          await _contentItemsRemoteService?.getPublishedOnline(tipo: tipo) ??
          const <Map<String, dynamic>>[];

      return rows
          .where((row) => _matchesQuery(row, cleanQuery))
          .map(contentItemRemoteToApp)
          .toList();
    });
  }

  Future<void> _loadRemoteAll() async {
    await _load(() async {
      final rows =
          await _contentItemsRemoteService?.getAllNotDeletedOnline() ??
          const <Map<String, dynamic>>[];
      return rows.map(contentItemRemoteToApp).toList();
    });
  }

  Future<void> _loadRemoteSearchAll(String query) async {
    final cleanQuery = query.trim().toLowerCase();

    await _load(() async {
      final rows =
          await _contentItemsRemoteService?.getAllNotDeletedOnline() ??
          const <Map<String, dynamic>>[];

      return rows
          .where((row) => _matchesQuery(row, cleanQuery))
          .map(contentItemRemoteToApp)
          .toList();
    });
  }

  bool _matchesQuery(Map<String, dynamic> row, String cleanQuery) {
    if (cleanQuery.isEmpty) {
      return true;
    }

    final textFields = [
      _rowValueAsString(row, 'tipo'),
      _rowValueAsString(row, 'titulo'),
      _rowValueAsString(row, 'subtitulo'),
      _rowValueAsString(row, 'descripcion'),
      _rowValueAsString(row, 'status'),
    ];

    return textFields.any((field) => field.contains(cleanQuery));
  }

  AppContentItem? _itemByUuid(String uuidContentItem) {
    final cleanUuid = uuidContentItem.trim();
    for (final item in _items) {
      if (item.uuidContentItem == cleanUuid) {
        return item;
      }
    }

    return null;
  }

  String _rowValueAsString(Map<String, dynamic> row, String key) {
    final value = row[key];
    return value?.toString().toLowerCase() ?? '';
  }

  Future<void> _reloadCurrentRemoteView() {
    if (_adminMode) {
      if (_searchQuery.isNotEmpty) {
        return _loadRemoteSearchAll(_searchQuery);
      }
      return _loadRemoteAll();
    }

    if (_searchQuery.isNotEmpty) {
      return _loadRemotePublishedSearch(_searchQuery, tipo: _activeTipo);
    }

    return _loadRemotePublished(tipo: _activeTipo);
  }

  void _subscribeItems(Stream<List<LocalContentItem>> stream) {
    _itemsSubscription?.cancel();
    _itemsSubscription = stream.listen(
      (localItems) {
        _items = _toAppItems(localItems);
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = error;
        notifyListeners();
      },
    );
  }

  void _subscribeFeatured(Stream<List<LocalContentItem>> stream) {
    _featuredSubscription?.cancel();
    _featuredSubscription = stream.listen(
      (localItems) {
        _featuredItems = _toAppItems(localItems);
        notifyListeners();
      },
      onError: (Object error) {
        _error = error;
        notifyListeners();
      },
    );
  }

  Future<void> _loadFromLocal(
    Future<List<LocalContentItem>> Function() load, {
    bool keepPreviousError = false,
  }) async {
    await _load(
      () async => _toAppItems(await load()),
      keepPreviousError: keepPreviousError,
    );
  }

  Future<void> _load(
    Future<List<AppContentItem>> Function() load, {
    bool keepPreviousError = false,
  }) async {
    _setLoading(true);
    final previousError = _error;
    if (!keepPreviousError) {
      _error = null;
    }

    try {
      _items = await load();
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
      if (keepPreviousError && _error == null) {
        _error = previousError;
      }
    }
  }

  List<AppContentItem> _toAppItems(List<LocalContentItem> items) {
    return List.unmodifiable(items.map(AppContentItem.fromLocal));
  }

  Future<_UploadedContentCover?> _uploadCoverIfNeeded({
    required String uuidContentItem,
    required Uint8List? bytes,
    required String? fileName,
    required String? contentType,
    required String? previousLocalPath,
  }) async {
    if (bytes == null) {
      return null;
    }

    final storageService = _contentMediaStorageService;
    if (storageService == null) {
      throw StateError('No hay servicio de Storage para subir la portada.');
    }

    final remotePath = await storageService.uploadCover(
      uuidContentItem: uuidContentItem,
      bytes: bytes,
      fileName: _cleanNullableText(fileName) ?? 'cover.jpg',
      contentType: _cleanNullableText(contentType),
    );

    final localPath = await _localMediaCache?.writeBytes(
      namespace: _contentCoverCacheNamespace,
      remotePath: remotePath,
      bytes: bytes,
    );

    if (previousLocalPath != null &&
        localPath != null &&
        previousLocalPath != localPath) {
      final cache = _localMediaCache;
      if (cache != null) {
        unawaited(cache.delete(previousLocalPath));
      }
    }

    return _UploadedContentCover(remotePath: remotePath, localPath: localPath);
  }

  Future<void> _cacheRemoteCoversFromLocal() async {
    final dao = _contentItemsDao;
    if (dao == null) {
      return;
    }

    final items = await dao.getAllNotDeleted();
    for (final item in items) {
      await _cacheRemoteCover(item);
    }
  }

  Future<void> _cacheRemoteCover(LocalContentItem item) async {
    final dao = _contentItemsDao;
    final storageService = _contentMediaStorageService;
    final cache = _localMediaCache;
    if (dao == null || storageService == null || cache == null) {
      return;
    }

    final remotePath = _cleanNullableText(item.coverPathSupabase);
    final localPath = _cleanNullableText(item.coverPathLocal);

    if (remotePath == null) {
      if (localPath != null) {
        await cache.delete(localPath);
        await dao.updateCoverPathLocal(
          item.uuidContentItem,
          coverPathLocal: null,
        );
      }
      return;
    }

    final expectedLocalPath = await cache.canonicalPath(
      namespace: _contentCoverCacheNamespace,
      remotePath: remotePath,
    );
    final hasDifferentLocalCache =
        expectedLocalPath != null &&
        localPath != null &&
        localPath != expectedLocalPath;

    if (hasDifferentLocalCache) {
      await dao.updateCoverPathLocal(
        item.uuidContentItem,
        coverPathLocal: null,
      );
      unawaited(cache.delete(localPath));
    }

    if (expectedLocalPath != null && localPath == expectedLocalPath) {
      final hasCachedFile = await cache.exists(localPath);
      if (hasCachedFile) {
        return;
      }
    }

    try {
      final bytes = await storageService.downloadMedia(remotePath);
      if (bytes == null || bytes.isEmpty) {
        return;
      }

      final nextLocalPath = await cache.writeBytes(
        namespace: _contentCoverCacheNamespace,
        remotePath: remotePath,
        bytes: bytes,
      );
      if (nextLocalPath == null) {
        return;
      }

      if (localPath != null && localPath != nextLocalPath) {
        unawaited(cache.delete(localPath));
      }

      await dao.updateCoverPathLocal(
        item.uuidContentItem,
        coverPathLocal: nextLocalPath,
      );
    } catch (_) {
      // La caché local es una optimización. Si falla, la app puede resolver
      // la portada privada con una signed URL cuando la necesite.
    }
  }

  Future<void> _deleteRemoteMediaSafe(String remotePath) async {
    try {
      await _contentMediaStorageService?.deleteMedia(remotePath);
    } catch (_) {
      // Borrar el archivo anterior no debe romper el guardado del contenido.
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void _setSyncing(bool value) {
    if (_isSyncing == value) {
      return;
    }
    _isSyncing = value;
    notifyListeners();
  }

  String? _cleanNullableText(String? value) {
    if (value == null) {
      return null;
    }
    final clean = value.trim();
    return clean.isEmpty ? null : clean;
  }

  String _generateUuidV4() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String byteToHex(int value) => value.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(byteToHex).join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20),
    ].join('-');
  }

  void _cancelSubscriptions() {
    _itemsSubscription?.cancel();
    _itemsSubscription = null;
    _featuredSubscription?.cancel();
    _featuredSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

class _UploadedContentCover {
  const _UploadedContentCover({required this.remotePath, this.localPath});

  final String remotePath;
  final String? localPath;
}
