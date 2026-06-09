import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/content_items_dao.dart';
import '../models/app_content_item.dart';
import '../remote/services/content_items_remote_service.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/sync_mappers.dart';

class ContentItemsController extends ChangeNotifier {
  ContentItemsController({
    required ContentItemsDao? contentItemsDao,
    ContentItemsRemoteService? contentItemsRemoteService,
    ContentItemsSyncService? syncService,
  }) : _contentItemsDao = contentItemsDao,
       _contentItemsRemoteService = contentItemsRemoteService,
       _syncService = syncService;

  final ContentItemsDao? _contentItemsDao;
  final ContentItemsRemoteService? _contentItemsRemoteService;
  final ContentItemsSyncService? _syncService;

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
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
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
