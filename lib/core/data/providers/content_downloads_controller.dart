import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/cache/local_media_cache.dart';
import '../local/daos/content_downloads_dao.dart';
import '../models/app_content_media.dart';
import '../remote/services/content_media_storage_service.dart';
import 'content_media_controller.dart';
import 'subscription_controller.dart';

class ContentDownloadsController extends ChangeNotifier {
  ContentDownloadsController({
    required ContentDownloadsDao? contentDownloadsDao,
    required ContentMediaController contentMediaController,
    required ContentMediaStorageService? storageService,
    required LocalMediaCache? localMediaCache,
    required SubscriptionController subscriptionController,
  }) : _contentDownloadsDao = contentDownloadsDao,
       _contentMediaController = contentMediaController,
       _storageService = storageService,
       _localMediaCache = localMediaCache,
       _subscriptionController = subscriptionController {
    _subscriptionController.addListener(_onSubscriptionChanged);
  }

  static const statusPending = 'pending';
  static const statusDownloading = 'downloading';
  static const statusCompleted = 'completed';
  static const statusFailed = 'failed';
  static const statusRemoved = 'removed';
  static const _cacheNamespace = 'content_downloads';
  static final _lifetimeAccessUntil = DateTime.utc(9999, 12, 31, 23, 59, 59);

  final ContentDownloadsDao? _contentDownloadsDao;
  final ContentMediaController _contentMediaController;
  final ContentMediaStorageService? _storageService;
  final LocalMediaCache? _localMediaCache;
  final SubscriptionController _subscriptionController;

  StreamSubscription<List<LocalContentDownload>>? _downloadSubscription;
  String? _activeProfileUuid;
  List<LocalContentDownload> _downloads = const [];
  final Map<String, double> _downloadProgress = {};
  final Map<String, Object> _downloadErrors = {};

  List<LocalContentDownload> get downloads => _downloads;
  String? get activeProfileUuid => _activeProfileUuid;
  bool get isSupported => !kIsWeb && _localMediaCache != null;

  void watchForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;
    _cancelSubscription();

    final dao = _contentDownloadsDao;
    if (dao == null) {
      _downloads = const [];
      notifyListeners();
      return;
    }

    _downloadSubscription = dao
        .watchForProfile(cleanProfile)
        .listen(
          (downloads) {
            _downloads = List.unmodifiable(downloads);
            notifyListeners();
          },
          onError: (Object error) {
            _downloadErrors['profile'] = error;
            notifyListeners();
          },
        );

    unawaited(_recoverAndReconcile(cleanProfile));
  }

  Future<void> recoverInterruptedDownloads() async {
    final profileUuid = _activeProfileUuid;
    if (profileUuid == null) {
      return;
    }

    await _recoverAndReconcile(profileUuid);
  }

  bool canDownload({required bool descargable}) {
    return isSupported &&
        descargable &&
        _subscriptionController.hasDownloadAccess &&
        _activeProfileUuid != null;
  }

  bool isDownloaded(String uuidContentMedia) {
    final download = _findDownload(uuidContentMedia);
    return download?.status == statusCompleted &&
        _hasUsableLocalFile(download!);
  }

  bool isContentDownloaded(String uuidContentItem) {
    final media = _downloads.where(
      (download) =>
          download.uuidContentItem == uuidContentItem.trim() &&
          download.status == statusCompleted &&
          _hasValidAccess(download),
    );
    return media.isNotEmpty && media.every(_hasUsableLocalFile);
  }

  bool isContentDownloading(String uuidContentItem) {
    return _downloads.any(
      (download) =>
          download.uuidContentItem == uuidContentItem.trim() &&
          download.status == statusDownloading,
    );
  }

  double? downloadProgress(String uuidContentMedia) {
    return _downloadProgress[uuidContentMedia.trim()];
  }

  double? downloadProgressForContent(String uuidContentItem) {
    final media = _downloads.where(
      (download) => download.uuidContentItem == uuidContentItem.trim(),
    );
    final values = media
        .map((download) => _downloadProgress[download.uuidContentMedia])
        .whereType<double>()
        .toList();
    if (values.isEmpty) {
      return null;
    }

    return values.reduce((total, value) => total + value) / values.length;
  }

  Object? downloadError(String uuidContentMedia) {
    return _downloadErrors[uuidContentMedia.trim()];
  }

  Future<void> downloadContent({
    required String uuidContentItem,
    required bool descargable,
  }) async {
    if (!canDownload(descargable: descargable)) {
      throw StateError('Necesitas una suscripción Premium para descargar.');
    }

    final media = await _contentMediaController.getByContentSnapshot(
      uuidContentItem,
    );
    final publishableMedia = media.where((item) => item.isPublishable).toList();
    if (publishableMedia.isEmpty) {
      throw StateError('Este contenido no tiene archivos descargables.');
    }

    for (final item in publishableMedia) {
      await downloadMedia(media: item, descargable: descargable);
    }
  }

  Future<void> downloadMedia({
    required AppContentMedia media,
    required bool descargable,
  }) async {
    if (!canDownload(descargable: descargable)) {
      throw StateError('Necesitas una suscripción Premium para descargar.');
    }

    final profileUuid = _activeProfileUuid;
    final storageService = _storageService;
    final localCache = _localMediaCache;
    if (profileUuid == null || storageService == null || localCache == null) {
      throw StateError('Las descargas offline no están disponibles aquí.');
    }

    final remotePath = media.storagePathSupabase.trim();
    if (remotePath.isEmpty) {
      throw StateError('El contenido no tiene una ruta multimedia válida.');
    }

    final mediaUuid = media.uuidContentMedia.trim();
    final accessExpiresAt = _currentAccessExpiration();
    _downloadProgress[mediaUuid] = 0;
    _downloadErrors.remove(mediaUuid);
    notifyListeners();

    final downloadUuid = _downloadUuid(profileUuid, mediaUuid);
    final now = DateTime.now().toUtc();
    final existing = await _contentDownloadsDao?.getByProfileAndMedia(
      profileUuid,
      mediaUuid,
    );
    _ensureActiveProfile(profileUuid);
    await _contentDownloadsDao?.upsertDownload(
      ContentDownloadsTableCompanion(
        uuidContentDownload: Value(downloadUuid),
        uuidProfile: Value(profileUuid),
        uuidContentItem: Value(media.uuidContentItem),
        uuidContentMedia: Value(mediaUuid),
        storagePathSupabase: Value(remotePath),
        storagePathLocal: Value(existing?.storagePathLocal),
        status: const Value(statusDownloading),
        bytesDownloaded: const Value(0),
        totalBytes: const Value(0),
        downloadedAt: const Value(null),
        accessExpiresAt: Value(accessExpiresAt),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );

    try {
      final localPath = await localCache.canonicalPath(
        namespace: _cacheNamespace,
        remotePath: remotePath,
      );
      if (localPath == null || localPath.isEmpty) {
        throw StateError('No se pudo preparar el archivo en el dispositivo.');
      }

      var totalBytes = 0;
      final bytesDownloaded = await storageService.downloadMediaToFile(
        remotePath: remotePath,
        localPath: localPath,
        onProgress: (received, total) {
          totalBytes = total ?? totalBytes;
          if (total != null && total > 0) {
            _downloadProgress[mediaUuid] = received / total;
          }
          notifyListeners();
        },
      );
      if (bytesDownloaded == null || bytesDownloaded <= 0) {
        throw StateError('No se pudo descargar el archivo multimedia.');
      }

      if (!await localCache.exists(localPath)) {
        throw StateError('No se pudo guardar el archivo en el dispositivo.');
      }

      if (_activeProfileUuid != profileUuid) {
        await localCache.delete(localPath);
        await localCache.deletePartial(localPath);
        throw StateError('La sesión cambió durante la descarga.');
      }

      final completedAt = DateTime.now().toUtc();
      await _contentDownloadsDao?.upsertDownload(
        ContentDownloadsTableCompanion(
          uuidContentDownload: Value(downloadUuid),
          uuidProfile: Value(profileUuid),
          uuidContentItem: Value(media.uuidContentItem),
          uuidContentMedia: Value(mediaUuid),
          storagePathSupabase: Value(remotePath),
          storagePathLocal: Value(localPath),
          status: const Value(statusCompleted),
          bytesDownloaded: Value(bytesDownloaded),
          totalBytes: Value(totalBytes > 0 ? totalBytes : bytesDownloaded),
          downloadedAt: Value(completedAt),
          accessExpiresAt: Value(accessExpiresAt),
          createdAt: Value(existing?.createdAt ?? completedAt),
          updatedAt: Value(completedAt),
        ),
      );
      _downloadProgress[mediaUuid] = 1;
      notifyListeners();
    } catch (error) {
      _downloadErrors[mediaUuid] = error;
      await _contentDownloadsDao?.updateByUuid(
        downloadUuid,
        ContentDownloadsTableCompanion(
          status: const Value(statusFailed),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeDownload({required String uuidContentMedia}) async {
    final profileUuid = _activeProfileUuid;
    if (profileUuid == null) {
      return;
    }

    final download = await _contentDownloadsDao?.getByProfileAndMedia(
      profileUuid,
      uuidContentMedia,
    );
    if (download == null) {
      return;
    }

    final localCache = _localMediaCache;
    final localPath = download.storagePathLocal ??
        await localCache?.canonicalPath(
          namespace: _cacheNamespace,
          remotePath: download.storagePathSupabase,
        );
    await localCache?.delete(localPath);
    await localCache?.deletePartial(localPath);
    await _contentDownloadsDao?.deleteByUuid(download.uuidContentDownload);
    _downloadProgress.remove(uuidContentMedia.trim());
    _downloadErrors.remove(uuidContentMedia.trim());
    notifyListeners();
  }

  Future<String?> openDownloadedMedia({
    required String uuidContentMedia,
  }) async {
    final profileUuid = _activeProfileUuid;
    if (profileUuid == null) {
      return null;
    }

    final download = await _contentDownloadsDao?.getByProfileAndMedia(
      profileUuid,
      uuidContentMedia,
    );
    if (download == null || download.status != statusCompleted) {
      return null;
    }

    final expiresAt = download.accessExpiresAt;
    if (expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc())) {
      return null;
    }

    final localPath = download.storagePathLocal;
    final localCache = _localMediaCache;
    if (localCache == null || !await localCache.exists(localPath)) {
      return null;
    }

    return localPath;
  }

  Future<void> refreshAccessExpirations() async {
    final profileUuid = _activeProfileUuid;
    final dao = _contentDownloadsDao;
    if (profileUuid == null ||
        dao == null ||
        _subscriptionController.isLoading) {
      return;
    }

    final subscription = _subscriptionController.currentSubscription;
    final now = DateTime.now().toUtc();
    final accessExpiresAt = _subscriptionController.hasDownloadAccess
        ? subscription!.currentPeriodEnd ?? _lifetimeAccessUntil
        : now;

    final downloads = await dao.getForProfile(profileUuid);
    if (_activeProfileUuid != profileUuid) {
      return;
    }

    for (final download in downloads.where(
      (item) => item.status == statusCompleted,
    )) {
      await dao.updateByUuid(
        download.uuidContentDownload,
        ContentDownloadsTableCompanion(
          accessExpiresAt: Value(accessExpiresAt),
          updatedAt: Value(now),
        ),
      );
    }
  }

  void clear() {
    _cancelSubscription();
    _activeProfileUuid = null;
    _downloads = const [];
    _downloadProgress.clear();
    _downloadErrors.clear();
    notifyListeners();
  }

  void _onSubscriptionChanged() {
    unawaited(refreshAccessExpirations());
  }

  DateTime? _currentAccessExpiration() {
    final subscription = _subscriptionController.currentSubscription;
    if (subscription == null || !_subscriptionController.hasDownloadAccess) {
      return null;
    }

    return subscription.currentPeriodEnd ?? _lifetimeAccessUntil;
  }

  bool _hasUsableLocalFile(LocalContentDownload download) {
    return download.storagePathLocal != null &&
        _hasValidAccess(download) &&
        _localMediaCache?.existsSync(download.storagePathLocal) == true;
  }

  bool _hasValidAccess(LocalContentDownload download) {
    final expiresAt = download.accessExpiresAt;
    return expiresAt == null || expiresAt.isAfter(DateTime.now().toUtc());
  }

  void _ensureActiveProfile(String profileUuid) {
    if (_activeProfileUuid != profileUuid) {
      throw StateError('La sesión cambió durante la descarga.');
    }
  }

  Future<void> _recoverAndReconcile(String profileUuid) async {
    final dao = _contentDownloadsDao;
    final localCache = _localMediaCache;
    if (dao == null || localCache == null) {
      return;
    }

    final downloads = await dao.getForProfile(profileUuid);
    if (_activeProfileUuid != profileUuid) {
      return;
    }

    final now = DateTime.now().toUtc();
    for (final download in downloads) {
      if (download.status == statusDownloading) {
        await dao.updateByUuid(
          download.uuidContentDownload,
          ContentDownloadsTableCompanion(
            status: const Value(statusFailed),
            updatedAt: Value(now),
          ),
        );
        continue;
      }

      if (download.status != statusCompleted ||
          await localCache.exists(download.storagePathLocal)) {
        continue;
      }

      await dao.updateByUuid(
        download.uuidContentDownload,
        ContentDownloadsTableCompanion(
          status: const Value(statusFailed),
          storagePathLocal: const Value(null),
          bytesDownloaded: const Value(0),
          totalBytes: const Value(0),
          downloadedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }
  }

  LocalContentDownload? _findDownload(String uuidContentMedia) {
    final cleanMediaUuid = uuidContentMedia.trim();
    for (final download in _downloads) {
      if (download.uuidContentMedia == cleanMediaUuid) {
        return download;
      }
    }
    return null;
  }

  String _downloadUuid(String uuidProfile, String uuidContentMedia) {
    final digest = sha256.convert(
      utf8.encode('${uuidProfile.trim()}:$uuidContentMedia'),
    );
    final bytes = digest.bytes.sublist(0, 16);
    bytes[6] = (bytes[6] & 0x0f) | 0x50;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  void _cancelSubscription() {
    _downloadSubscription?.cancel();
    _downloadSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    _subscriptionController.removeListener(_onSubscriptionChanged);
    super.dispose();
  }
}
