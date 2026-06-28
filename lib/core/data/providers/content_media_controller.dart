import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/cache/local_media_cache.dart';
import '../local/daos/content_media_dao.dart';
import '../models/app_content_media.dart';
import '../models/content_media_file_metadata.dart';
import '../remote/services/content_media_remote_service.dart';
import '../remote/services/content_media_storage_service.dart';
import '../sync/content_media_sync_service.dart';
import '../sync/sync_mappers.dart';

class ContentMediaController extends ChangeNotifier {
  ContentMediaController({
    required ContentMediaDao? contentMediaDao,
    ContentMediaRemoteService? contentMediaRemoteService,
    ContentMediaStorageService? contentMediaStorageService,
    ContentMediaSyncService? syncService,
    LocalMediaCache? localMediaCache,
  }) : _contentMediaDao = contentMediaDao,
       _contentMediaRemoteService = contentMediaRemoteService,
       _contentMediaStorageService = contentMediaStorageService,
       _syncService = syncService,
       _localMediaCache = localMediaCache;

  final ContentMediaDao? _contentMediaDao;
  final ContentMediaRemoteService? _contentMediaRemoteService;
  final ContentMediaStorageService? _contentMediaStorageService;
  final ContentMediaSyncService? _syncService;
  final LocalMediaCache? _localMediaCache;

  static const _contentMediaCacheNamespace = 'content_media';
  static const supportedTypes = {
    'mp4',
    'mov',
    'm4v',
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
  };

  StreamSubscription<List<LocalContentMedia>>? _mediaSubscription;

  List<AppContentMedia> _items = const [];
  String? _activeContentUuid;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  List<AppContentMedia> get items => _items;
  String? get activeContentUuid => _activeContentUuid;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _contentMediaRemoteService != null;

  static bool isValidMediaType(String value) {
    return ContentMediaFileMetadata.isSupportedType(value);
  }

  static String normalizeMediaType(String value, {required String fileName}) {
    final cleanValue = value.trim().toLowerCase();
    if (isValidMediaType(cleanValue)) {
      return cleanValue;
    }

    final fileMetadata = ContentMediaFileMetadata.tryParse(fileName);
    if (fileMetadata != null) {
      return fileMetadata.tipo;
    }

    return cleanValue;
  }

  Future<String?> resolveMediaUrl(String storagePath) {
    return _contentMediaStorageService?.createSignedUrl(storagePath) ??
        Future.value(null);
  }

  void watchForContent(String uuidContentItem) {
    final cleanContentUuid = uuidContentItem.trim();
    _activeContentUuid = cleanContentUuid;
    _cancelSubscription();

    if (cleanContentUuid.isEmpty) {
      _items = const [];
      notifyListeners();
      return;
    }

    final dao = _contentMediaDao;
    if (dao == null) {
      unawaited(loadForContent(cleanContentUuid));
      return;
    }

    _mediaSubscription = dao
        .watchByContent(cleanContentUuid)
        .listen(
          (localMedia) {
            _items = _toAppMedia(localMedia);
            _error = null;
            notifyListeners();
          },
          onError: (Object error) {
            _error = error;
            notifyListeners();
          },
        );
  }

  Future<void> loadForContent(String uuidContentItem) async {
    final cleanContentUuid = uuidContentItem.trim();
    _activeContentUuid = cleanContentUuid;

    if (cleanContentUuid.isEmpty) {
      _items = const [];
      notifyListeners();
      return;
    }

    final dao = _contentMediaDao;
    if (dao == null) {
      await _loadRemoteForContent(cleanContentUuid);
      return;
    }

    await _loadFromLocal(() => dao.getByContent(cleanContentUuid));
  }

  Future<bool> hasPublishableMedia(String uuidContentItem) async {
    final cleanContentUuid = uuidContentItem.trim();
    if (cleanContentUuid.isEmpty) {
      return false;
    }

    final dao = _contentMediaDao;
    if (dao != null) {
      return (await dao.getPublishableCountByContent(cleanContentUuid)) > 0;
    }

    final remoteService = _contentMediaRemoteService;
    if (remoteService == null) {
      return _items.any(
        (media) =>
            media.uuidContentItem == cleanContentUuid && media.isPublishable,
      );
    }

    final rows = await remoteService.getByContentOnline(cleanContentUuid);
    return rows
        .map(contentMediaRemoteToApp)
        .any((media) => media.isPublishable);
  }

  Future<void> pullFromRemote() async {
    final syncService = _syncService;
    if (syncService == null) {
      await _reloadActiveRemoteView();
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
    final syncService = _syncService;
    if (syncService == null) {
      await _reloadActiveRemoteView();
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

  Future<String> addMedia({
    String? uuidContentMedia,
    required String uuidContentItem,
    required String tipo,
    required String titulo,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
    int? duracionSegundos,
    required int orden,
    bool syncAfterSave = false,
  }) async {
    final now = DateTime.now().toUtc();
    final cleanContentUuid = uuidContentItem.trim();
    final cleanMediaUuid =
        _cleanNullableText(uuidContentMedia) ?? _generateUuidV4();
    final cleanTipo = normalizeMediaType(tipo, fileName: fileName);
    final cleanTitulo = titulo.trim();

    if (cleanContentUuid.isEmpty) {
      throw ArgumentError('El contenido es obligatorio.');
    }
    if (!isValidMediaType(cleanTipo)) {
      throw ArgumentError(
        'El tipo de archivo no es válido. tipo="$cleanTipo" archivo="$fileName"',
      );
    }
    if (cleanTitulo.isEmpty) {
      throw ArgumentError('El título del archivo es obligatorio.');
    }
    if (bytes.isEmpty) {
      throw ArgumentError('El archivo seleccionado está vacío.');
    }

    final storageService = _contentMediaStorageService;
    if (storageService == null) {
      throw StateError('No hay servicio de Storage para subir archivos.');
    }

    String? uploadedRemotePath;

    try {
      uploadedRemotePath = await storageService.uploadMedia(
        uuidContentItem: cleanContentUuid,
        uuidContentMedia: cleanMediaUuid,
        bytes: bytes,
        fileName: _cleanNullableText(fileName) ?? 'media_file',
        contentType: _cleanNullableText(contentType),
      );

      final localPath = await _localMediaCache?.writeBytes(
        namespace: _contentMediaCacheNamespace,
        remotePath: uploadedRemotePath,
        bytes: bytes,
      );

      final dao = _contentMediaDao;
      final remoteService = _contentMediaRemoteService;

      if (dao != null) {
        await dao.upsertContentMedia(
          ContentMediaTableCompanion.insert(
            uuidContentMedia: cleanMediaUuid,
            uuidContentItem: cleanContentUuid,
            tipo: cleanTipo,
            titulo: Value(cleanTitulo),
            storagePathSupabase: uploadedRemotePath,
            storagePathLocal: Value(localPath),
            duracionSegundos: Value(duracionSegundos),
            orden: Value(orden),
            createdAt: Value(now),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncedAt: const Value(null),
          ),
        );
      } else if (remoteService != null) {
        await remoteService.upsertOnline({
          'uuid_content_media': cleanMediaUuid,
          'uuid_content_item': cleanContentUuid,
          'type': cleanTipo,
          'title': cleanTitulo,
          'storage_path': uploadedRemotePath,
          'duration_seconds': duracionSegundos,
          'sort_order': orden,
          'created_at': remoteService.isoUtc(now),
          'updated_at': remoteService.isoUtc(now),
          'deleted_at': null,
        });
        await _loadRemoteForContent(cleanContentUuid);
      }

      if (syncAfterSave) {
        await syncWithRemote();
      }

      return cleanMediaUuid;
    } catch (_) {
      if (uploadedRemotePath != null) {
        unawaited(_deleteRemoteMediaSafe(uploadedRemotePath));
      }
      rethrow;
    }
  }

  Future<void> archiveMedia(
    String uuidContentMedia, {
    bool syncAfterUpdate = false,
  }) async {
    final cleanMediaUuid = uuidContentMedia.trim();
    final dao = _contentMediaDao;
    final remoteService = _contentMediaRemoteService;

    if (dao != null) {
      await dao.softDeleteByUuid(cleanMediaUuid);
    } else if (remoteService != null) {
      await remoteService.archiveOnline(cleanMediaUuid);
      await _reloadActiveRemoteView();
    }

    if (syncAfterUpdate) {
      await syncWithRemote();
    }
  }

  Future<void> updateMediaMetadata({
    required String uuidContentMedia,
    required String tipo,
    required String titulo,
    required int? duracionSegundos,
    required int orden,
    bool syncAfterUpdate = false,
  }) async {
    final cleanMediaUuid = uuidContentMedia.trim();
    final cleanTipo = tipo.trim().toLowerCase();
    final cleanTitulo = titulo.trim();

    if (cleanMediaUuid.isEmpty) {
      throw ArgumentError('El archivo es obligatorio.');
    }
    if (!isValidMediaType(cleanTipo)) {
      throw ArgumentError('El tipo de archivo no es válido.');
    }
    if (cleanTitulo.isEmpty) {
      throw ArgumentError('El título del archivo es obligatorio.');
    }

    final dao = _contentMediaDao;
    final remoteService = _contentMediaRemoteService;

    if (dao != null) {
      await dao.updateMetadata(
        cleanMediaUuid,
        tipo: cleanTipo,
        titulo: cleanTitulo,
        duracionSegundos: duracionSegundos,
        orden: orden,
      );
    } else if (remoteService != null) {
      await remoteService.updateMetadataOnline(
        cleanMediaUuid,
        tipo: cleanTipo,
        titulo: cleanTitulo,
        duracionSegundos: duracionSegundos,
        orden: orden,
      );
      await _reloadActiveRemoteView();
    }

    if (syncAfterUpdate) {
      await syncWithRemote();
    }
  }

  Future<void> _reloadActiveRemoteView() async {
    final activeContentUuid = _activeContentUuid;
    if (activeContentUuid == null || activeContentUuid.isEmpty) {
      return;
    }

    await _loadRemoteForContent(activeContentUuid);
  }

  Future<void> _loadRemoteForContent(String uuidContentItem) async {
    final service = _contentMediaRemoteService;
    if (service == null) {
      _error = StateError('No hay servicio remoto para archivos de contenido.');
      notifyListeners();
      return;
    }

    await _load(() async {
      final rows = await service.getByContentOnline(uuidContentItem);
      return rows.map(contentMediaRemoteToApp).toList();
    });
  }

  Future<void> _loadFromLocal(
    Future<List<LocalContentMedia>> Function() load,
  ) async {
    await _load(() async => _toAppMedia(await load()));
  }

  Future<void> _load(Future<List<AppContentMedia>> Function() load) async {
    _setLoading(true);
    _error = null;

    try {
      _items = await load();
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
    }
  }

  List<AppContentMedia> _toAppMedia(List<LocalContentMedia> media) {
    return List.unmodifiable(media.map(AppContentMedia.fromLocal));
  }

  Future<void> _deleteRemoteMediaSafe(String remotePath) async {
    try {
      await _contentMediaStorageService?.deleteMedia(remotePath);
    } catch (_) {
      // Si el rollback del archivo falla, la metadata no se guardo y el error
      // original sigue siendo el resultado relevante para la UI.
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

  void _cancelSubscription() {
    _mediaSubscription?.cancel();
    _mediaSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
