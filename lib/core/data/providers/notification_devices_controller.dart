import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/notification_devices_dao.dart';
import '../local/tables/notification_devices_table.dart';
import '../models/app_notification_device.dart';
import '../remote/services/notification_devices_remote_service.dart';
import '../sync/notification_devices_sync_service.dart';
import '../sync/sync_mappers.dart';

class NotificationDevicesController extends ChangeNotifier {
  NotificationDevicesController({
    required NotificationDevicesDao? notificationDevicesDao,
    NotificationDevicesRemoteService? notificationDevicesRemoteService,
    NotificationDevicesSyncService? syncService,
  }) : _notificationDevicesDao = notificationDevicesDao,
       _notificationDevicesRemoteService = notificationDevicesRemoteService,
       _syncService = syncService;

  final NotificationDevicesDao? _notificationDevicesDao;
  final NotificationDevicesRemoteService? _notificationDevicesRemoteService;
  final NotificationDevicesSyncService? _syncService;

  StreamSubscription<List<LocalNotificationDevice>>? _devicesSubscription;
  List<AppNotificationDevice> _devices = const [];
  String? _activeProfileUuid;
  String? _activeInstallationId;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  List<AppNotificationDevice> get devices => _devices;
  String? get activeProfileUuid => _activeProfileUuid;
  String? get activeInstallationId => _activeInstallationId;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _notificationDevicesRemoteService != null;

  AppNotificationDevice? get currentInstallation {
    final profileUuid = _activeProfileUuid;
    final installationId = _activeInstallationId;
    if (profileUuid == null || installationId == null) {
      return null;
    }

    for (final device in _devices) {
      if (device.uuidProfile == profileUuid &&
          device.installationId == installationId &&
          device.deletedAt == null) {
        return device;
      }
    }
    return null;
  }

  void watchForProfile(String uuidProfile, {bool pullRemote = true}) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;
    _cancelSubscription();

    final dao = _notificationDevicesDao;
    if (dao == null) {
      unawaited(loadForProfile(cleanProfile));
      return;
    }

    _devicesSubscription = dao
        .watchForProfile(cleanProfile)
        .listen(
          (localDevices) {
            _devices = _toAppDevices(localDevices);
            _error = null;
            notifyListeners();
          },
          onError: (Object error) {
            _error = error;
            notifyListeners();
          },
        );

    if (pullRemote) {
      unawaited(pullFromRemote(uuidProfile: cleanProfile));
    }
  }

  Future<void> loadForProfile(String uuidProfile) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;
    final dao = _notificationDevicesDao;
    if (dao != null) {
      await _loadFromLocal(() => dao.getForProfile(cleanProfile));
      return;
    }

    await _loadRemoteForProfile(cleanProfile);
  }

  Future<void> pullFromRemote({String? uuidProfile}) async {
    final cleanProfile = (uuidProfile ?? _activeProfileUuid ?? '').trim();
    if (cleanProfile.isEmpty) {
      return;
    }

    final dao = _notificationDevicesDao;
    final syncService = _syncService;
    if (dao == null || syncService == null) {
      await _loadRemoteForProfile(cleanProfile);
      return;
    }

    _setSyncing(true);
    _error = null;
    try {
      await syncService.pullForProfile(cleanProfile);
      await _reloadLocal(cleanProfile);
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> syncWithRemote({String? uuidProfile}) async {
    final cleanProfile = (uuidProfile ?? _activeProfileUuid ?? '').trim();
    if (cleanProfile.isEmpty) {
      return;
    }

    final dao = _notificationDevicesDao;
    final syncService = _syncService;
    if (dao == null || syncService == null) {
      await _loadRemoteForProfile(cleanProfile);
      return;
    }

    _setSyncing(true);
    _error = null;
    try {
      await syncService.syncForProfile(cleanProfile);
      await _reloadLocal(cleanProfile);
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> registerCurrentInstallation({
    required String installationId,
    required String? fcmToken,
    required String platform,
    required String permissionStatus,
    required String? appVersion,
    String? timeZone,
    required DateTime? registrationRefreshedAt,
    bool syncAfterSave = true,
  }) async {
    final profileUuid = (_activeProfileUuid ?? '').trim();
    final cleanInstallationId = installationId.trim();
    final cleanPlatform = platform.trim().toLowerCase();
    final cleanPermissionStatus = permissionStatus.trim().toLowerCase();

    if (profileUuid.isEmpty) {
      throw StateError(
        'No hay un perfil activo para registrar el dispositivo.',
      );
    }
    if (cleanInstallationId.isEmpty) {
      throw ArgumentError(
        'El identificador de instalación no puede estar vacío.',
      );
    }
    if (!notificationDevicePlatforms.contains(cleanPlatform)) {
      throw ArgumentError('La plataforma del dispositivo no es válida.');
    }
    if (!notificationPermissionStatuses.contains(cleanPermissionStatus)) {
      throw ArgumentError(
        'El estado del permiso de notificaciones no es válido.',
      );
    }

    final cleanToken = _cleanNullableText(fcmToken);
    final cleanAppVersion = _cleanNullableText(appVersion);
    final cleanTimeZone = _cleanNullableText(timeZone);
    final refreshedAt = registrationRefreshedAt?.toUtc();
    final now = DateTime.now().toUtc();
    final dao = _notificationDevicesDao;

    if (dao != null) {
      final existing = await dao.getByProfileAndInstallation(
        profileUuid,
        cleanInstallationId,
      );
      final uuidNotificationDevice =
          existing?.uuidNotificationDevice ?? _generateUuidV4();

      if (existing == null) {
        await dao.upsertNotificationDevice(
          NotificationDevicesTableCompanion.insert(
            uuidNotificationDevice: uuidNotificationDevice,
            uuidProfile: profileUuid,
            installationId: cleanInstallationId,
            fcmToken: Value(cleanToken),
            platform: cleanPlatform,
            permissionStatus: Value(cleanPermissionStatus),
            appVersion: Value(cleanAppVersion),
            timeZone: Value(cleanTimeZone),
            isActive: const Value(true),
            registrationRefreshedAt: Value(refreshedAt),
            createdAt: Value(now),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncedAt: const Value(null),
          ),
        );
      } else {
        await dao.updateRegistration(
          uuidNotificationDevice,
          fcmToken: cleanToken,
          platform: cleanPlatform,
          permissionStatus: cleanPermissionStatus,
          appVersion: cleanAppVersion,
          timeZone: cleanTimeZone,
          isActive: true,
          registrationRefreshedAt: refreshedAt,
        );
      }

      _activeInstallationId = cleanInstallationId;
      await _reloadLocal(profileUuid);
      if (syncAfterSave) {
        await syncWithRemote(uuidProfile: profileUuid);
      }
      return;
    }

    final service = _notificationDevicesRemoteService;
    if (service == null) {
      throw StateError('No hay persistencia configurada para dispositivos.');
    }

    final remoteExisting = await service.getByProfileAndInstallationOnline(
      uuidProfile: profileUuid,
      installationId: cleanInstallationId,
    );
    final existing = remoteExisting == null
        ? null
        : notificationDeviceRemoteToApp(remoteExisting);
    final uuidNotificationDevice =
        existing?.uuidNotificationDevice ?? _generateUuidV4();

    await service.upsertOnline({
      'uuid_notification_device': uuidNotificationDevice,
      'uuid_profile': profileUuid,
      'installation_id': cleanInstallationId,
      'fcm_token': cleanToken,
      'platform': cleanPlatform,
      'permission_status': cleanPermissionStatus,
      'app_version': cleanAppVersion,
      'timezone': cleanTimeZone,
      'is_active': true,
      'registration_refreshed_at': refreshedAt == null
          ? null
          : service.isoUtc(refreshedAt),
      'created_at': service.isoUtc(existing?.createdAt ?? now),
      'updated_at': service.isoUtc(now),
      'deleted_at': null,
      'synced_at': service.isoUtc(now),
    });

    _activeInstallationId = cleanInstallationId;
    await _loadRemoteForProfile(profileUuid);
  }

  Future<void> deactivateCurrentInstallation({
    bool requireRemoteConfirmation = false,
  }) async {
    final profileUuid = (_activeProfileUuid ?? '').trim();
    final installationId = (_activeInstallationId ?? '').trim();
    if (profileUuid.isEmpty || installationId.isEmpty) {
      return;
    }

    final dao = _notificationDevicesDao;
    AppNotificationDevice? current = currentInstallation;
    if (current == null && dao != null) {
      final local = await dao.getByProfileAndInstallation(
        profileUuid,
        installationId,
      );
      if (local != null) {
        current = AppNotificationDevice.fromLocal(local);
      }
    }
    if (current == null) {
      return;
    }

    if (dao != null) {
      await dao.deactivateByProfileAndInstallation(profileUuid, installationId);
      await _reloadLocal(profileUuid);
    }

    final service = _notificationDevicesRemoteService;
    if (service != null) {
      try {
        await service.deactivateOnline(current.uuidNotificationDevice);
        if (dao != null) {
          await dao.markSyncedByUuid(current.uuidNotificationDevice);
          await _reloadLocal(profileUuid);
        } else {
          await _loadRemoteForProfile(profileUuid);
        }
        return;
      } catch (error) {
        _error = error;
        notifyListeners();
        if (requireRemoteConfirmation && _hasToken(current)) {
          rethrow;
        }
      }
    } else if (requireRemoteConfirmation && _hasToken(current)) {
      throw StateError(
        'No se pudo confirmar la desactivación del dispositivo remoto.',
      );
    }

    if (!requireRemoteConfirmation && _syncService != null) {
      await syncWithRemote(uuidProfile: profileUuid);
    }
  }

  void clear() {
    _cancelSubscription();
    _devices = const [];
    _activeProfileUuid = null;
    _activeInstallationId = null;
    _isLoading = false;
    _isSyncing = false;
    _error = null;
    notifyListeners();
  }

  Future<void> _reloadLocal(String uuidProfile) async {
    final dao = _notificationDevicesDao;
    if (dao == null) {
      return;
    }
    _devices = _toAppDevices(await dao.getForProfile(uuidProfile));
    _error = null;
    notifyListeners();
  }

  Future<void> _loadFromLocal(
    Future<List<LocalNotificationDevice>> Function() load,
  ) async {
    await _load(() async => _toAppDevices(await load()));
  }

  Future<void> _loadRemoteForProfile(String uuidProfile) async {
    final service = _notificationDevicesRemoteService;
    if (service == null) {
      return;
    }
    await _load(() async {
      final rows = await service.getForProfileOnline(uuidProfile);
      return List.unmodifiable(rows.map(notificationDeviceRemoteToApp));
    });
  }

  Future<void> _load(
    Future<List<AppNotificationDevice>> Function() load,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      _devices = await load();
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
    }
  }

  List<AppNotificationDevice> _toAppDevices(
    List<LocalNotificationDevice> devices,
  ) {
    return List.unmodifiable(devices.map(AppNotificationDevice.fromLocal));
  }

  bool _hasToken(AppNotificationDevice device) {
    return device.fcmToken?.trim().isNotEmpty ?? false;
  }

  String? _cleanNullableText(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
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
    _devicesSubscription?.cancel();
    _devicesSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
