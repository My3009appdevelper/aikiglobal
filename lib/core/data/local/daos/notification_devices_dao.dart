import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class NotificationDevicesDao
    extends BaseDao<$NotificationDevicesTableTable, LocalNotificationDevice> {
  NotificationDevicesDao(super.db) : super(table: db.notificationDevicesTable);

  Future<LocalNotificationDevice?> getByUuid(String uuidNotificationDevice) {
    return getSingleWhere(
      (table) =>
          table.uuidNotificationDevice.equals(uuidNotificationDevice.trim()),
    );
  }

  Future<LocalNotificationDevice?> getByProfileAndInstallation(
    String uuidProfile,
    String installationId,
  ) {
    return getSingleWhere(
      (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.installationId.equals(installationId.trim()) &
          table.deletedAt.isNull(),
    );
  }

  Future<List<LocalNotificationDevice>> getForProfile(String uuidProfile) {
    return listWhere(
      where: (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.isActive),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Future<List<LocalNotificationDevice>> getAllForProfile(
    String uuidProfile, {
    bool includeDeleted = true,
  }) {
    return listWhere(
      where: (table) {
        final profile = table.uuidProfile.equals(uuidProfile.trim());
        return includeDeleted ? profile : profile & table.deletedAt.isNull();
      },
      orderBy: [(table) => OrderingTerm.desc(table.updatedAt)],
    );
  }

  Stream<List<LocalNotificationDevice>> watchForProfile(String uuidProfile) {
    return watchWhere(
      where: (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.isActive),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Future<void> upsertNotificationDevice(
    NotificationDevicesTableCompanion device,
  ) {
    return upsertOne(device);
  }

  Future<void> upsertNotificationDevices(
    List<NotificationDevicesTableCompanion> devices,
  ) {
    return upsertBatch(devices);
  }

  Future<int> updateRegistration(
    String uuidNotificationDevice, {
    required String? fcmToken,
    required String platform,
    required String permissionStatus,
    required String? appVersion,
    String? timeZone,
    required bool isActive,
    required DateTime? registrationRefreshedAt,
  }) {
    return updatePartialByIdNow(
      byId: (table) =>
          table.uuidNotificationDevice.equals(uuidNotificationDevice.trim()),
      patch: (now) => NotificationDevicesTableCompanion(
        fcmToken: Value(_cleanNullableText(fcmToken)),
        platform: Value(platform.trim()),
        permissionStatus: Value(permissionStatus.trim()),
        appVersion: Value(_cleanNullableText(appVersion)),
        timeZone: Value(_cleanNullableText(timeZone)),
        isActive: Value(isActive),
        registrationRefreshedAt: Value(registrationRefreshedAt?.toUtc()),
        updatedAt: Value(now),
        deletedAt: const Value(null),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<int> deactivateByProfileAndInstallation(
    String uuidProfile,
    String installationId,
  ) {
    return writeWhereNow(
      where: (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.installationId.equals(installationId.trim()) &
          table.deletedAt.isNull(),
      patch: (now) => NotificationDevicesTableCompanion(
        isActive: const Value(false),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<int> softDeleteByUuid(String uuidNotificationDevice) {
    return softDelete(
      byId: (table) =>
          table.uuidNotificationDevice.equals(uuidNotificationDevice.trim()),
      patch: (now) => NotificationDevicesTableCompanion(
        isActive: const Value(false),
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<List<LocalNotificationDevice>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<List<LocalNotificationDevice>> getPendingSyncForProfile(
    String uuidProfile,
  ) {
    return listWhere(
      where: (table) {
        final pending =
            table.syncedAt.isNull() |
            table.syncedAt.isSmallerThan(table.updatedAt);
        return table.uuidProfile.equals(uuidProfile.trim()) & pending;
      },
    );
  }

  Future<int> markSyncedByUuid(
    String uuidNotificationDevice, {
    DateTime? syncedAt,
  }) {
    return writeWhere(
      where: (table) =>
          table.uuidNotificationDevice.equals(uuidNotificationDevice.trim()),
      companion: NotificationDevicesTableCompanion(
        syncedAt: Value(syncedAt?.toUtc() ?? nowUtc()),
      ),
    );
  }
}

String? _cleanNullableText(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}
