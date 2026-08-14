import '../../common/base_service.dart';
import '../supabase_tables.dart';

class NotificationDevicesRemoteService extends BaseService {
  NotificationDevicesRemoteService({super.supabase})
    : super(
        table: SupabaseTables.notificationDevices,
        idColumn: 'uuid_notification_device',
        headSelect: 'uuid_notification_device, updated_at',
        onConflict: 'uuid_notification_device',
        logTag: 'NotificationDevicesRemoteService',
      );

  Future<List<Map<String, dynamic>>> getForProfileOnline(String uuidProfile) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .isFilter('deleted_at', null),
      orderByColumn: 'updated_at',
      ascending: false,
    );
  }

  Future<Map<String, dynamic>?> getByProfileAndInstallationOnline({
    required String uuidProfile,
    required String installationId,
  }) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .eq('installation_id', installationId.trim())
          .isFilter('deleted_at', null),
    );
  }

  Future<void> updateRegistrationOnline(
    String uuidNotificationDevice, {
    required String? fcmToken,
    required String platform,
    required String permissionStatus,
    required String? appVersion,
    String? timeZone,
    required bool isActive,
    required DateTime? registrationRefreshedAt,
  }) {
    return updateOnlineById(uuidNotificationDevice.trim(), {
      'fcm_token': _cleanNullableText(fcmToken),
      'platform': platform.trim(),
      'permission_status': permissionStatus.trim(),
      'app_version': _cleanNullableText(appVersion),
      'timezone': _cleanNullableText(timeZone),
      'is_active': isActive,
      'registration_refreshed_at': registrationRefreshedAt == null
          ? null
          : isoUtc(registrationRefreshedAt),
      'deleted_at': null,
    });
  }

  Future<void> deactivateOnline(String uuidNotificationDevice) {
    return updateOnlineById(uuidNotificationDevice.trim(), {
      'is_active': false,
    });
  }
}

String? _cleanNullableText(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}
