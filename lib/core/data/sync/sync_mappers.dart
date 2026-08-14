import 'package:drift/drift.dart';

import '../common/json_object_codec.dart';
import '../local/app_database.dart';
import '../models/app_company_info.dart';
import '../models/app_content_media.dart';
import '../models/app_content_item.dart';
import '../models/app_notification_device.dart';
import '../models/app_notification_dispatch.dart';
import '../models/app_notification_event.dart';
import '../models/app_notification_inbox_item.dart';
import '../models/app_profile.dart';
import '../models/app_user_content_state.dart';
import '../models/app_wellness_daily_log.dart';
import '../models/app_wellness_profile_stats.dart';

String _stringValue(
  Map<String, dynamic> json,
  String key, {
  String fallback = '',
}) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  return value.toString();
}

String? _nullableStringValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

bool _boolValue(
  Map<String, dynamic> json,
  String key, {
  bool fallback = false,
}) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  return fallback;
}

int _intValue(Map<String, dynamic> json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

int? _nullableIntValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

DateTime _dateTimeValue(
  Map<String, dynamic> json,
  String key, {
  DateTime? fallback,
}) {
  final value = json[key];
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value).toUtc();
  }
  return fallback ?? DateTime.now().toUtc();
}

DateTime? _nullableDateTimeValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value).toUtc();
  }
  return null;
}

String? _dateToRemote(DateTime? date) => date?.toUtc().toIso8601String();

Map<String, dynamic> _jsonObjectValue(Map<String, dynamic> json, String key) {
  return decodeJsonObject(json[key]);
}

String _dateOnlyValue(
  Map<String, dynamic> json,
  String key, {
  String? fallback,
}) {
  final value = json[key];
  if (value is DateTime) {
    return _dateOnlyFromDateTime(value);
  }
  if (value is String && value.isNotEmpty) {
    return value.length >= 10 ? value.substring(0, 10) : value;
  }
  return fallback ?? _dateOnlyFromDateTime(DateTime.now());
}

String? _nullableDateOnlyValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return _dateOnlyFromDateTime(value);
  }
  if (value is String && value.isNotEmpty) {
    return value.length >= 10 ? value.substring(0, 10) : value;
  }
  return null;
}

String _dateOnlyFromDateTime(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '${local.year}-$month-$day';
}

Map<String, dynamic> companyInfoToRemote(LocalCompanyInfo info) {
  return {
    'uuid_company_info': info.uuidCompanyInfo,
    'slug': info.slug,
    'hero_titulo': info.heroTitulo,
    'hero_subtitulo': info.heroSubtitulo,
    'hero_image_path': info.heroImagePath,
    'texto_entrada': info.textoEntrada,
    'quienes_somos': info.quienesSomos,
    'significado_aiki': info.significadoAiki,
    'mision': info.mision,
    'vision': info.vision,
    'filosofia': info.filosofia,
    'mensaje_fundadores_titulo': info.mensajeFundadoresTitulo,
    'mensaje_fundadores_texto': info.mensajeFundadoresTexto,
    'mensaje_fundadores_image_path1': info.mensajeFundadoresImagePath1,
    'mensaje_fundadores_image_path2': info.mensajeFundadoresImagePath2,
    'mensaje_fundadores_image_path3': info.mensajeFundadoresImagePath3,
    'mensaje_fundadores_image_path4': info.mensajeFundadoresImagePath4,
    'mensaje_fundadores_image_path5': info.mensajeFundadoresImagePath5,
    'created_at': _dateToRemote(info.createdAt),
    'updated_at': _dateToRemote(info.updatedAt),
    'deleted_at': _dateToRemote(info.deletedAt),
    'synced_at': _dateToRemote(info.syncedAt),
  };
}

CompanyInfoTableCompanion companyInfoRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return CompanyInfoTableCompanion.insert(
    uuidCompanyInfo: _stringValue(json, 'uuid_company_info'),
    slug: Value(_stringValue(json, 'slug', fallback: 'main')),
    heroTitulo: Value(_stringValue(json, 'hero_titulo')),
    heroSubtitulo: Value(_stringValue(json, 'hero_subtitulo')),
    heroImagePath: Value(_nullableStringValue(json, 'hero_image_path')),
    textoEntrada: Value(_stringValue(json, 'texto_entrada')),
    quienesSomos: _stringValue(json, 'quienes_somos'),
    significadoAiki: Value(_stringValue(json, 'significado_aiki')),
    mision: _stringValue(json, 'mision'),
    vision: _stringValue(json, 'vision'),
    filosofia: _stringValue(json, 'filosofia'),
    mensajeFundadoresTitulo: Value(
      _stringValue(json, 'mensaje_fundadores_titulo'),
    ),
    mensajeFundadoresTexto: Value(
      _stringValue(json, 'mensaje_fundadores_texto'),
    ),
    mensajeFundadoresImagePath1: Value(
      _nullableStringValue(json, 'mensaje_fundadores_image_path1'),
    ),
    mensajeFundadoresImagePath2: Value(
      _nullableStringValue(json, 'mensaje_fundadores_image_path2'),
    ),
    mensajeFundadoresImagePath3: Value(
      _nullableStringValue(json, 'mensaje_fundadores_image_path3'),
    ),
    mensajeFundadoresImagePath4: Value(
      _nullableStringValue(json, 'mensaje_fundadores_image_path4'),
    ),
    mensajeFundadoresImagePath5: Value(
      _nullableStringValue(json, 'mensaje_fundadores_image_path5'),
    ),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

AppCompanyInfo companyInfoRemoteToApp(Map<String, dynamic> json) {
  return AppCompanyInfo(
    uuidCompanyInfo: _stringValue(json, 'uuid_company_info'),
    slug: _stringValue(json, 'slug', fallback: 'main'),
    heroTitulo: _stringValue(json, 'hero_titulo'),
    heroSubtitulo: _stringValue(json, 'hero_subtitulo'),
    heroImagePath: _nullableStringValue(json, 'hero_image_path'),
    textoEntrada: _stringValue(json, 'texto_entrada'),
    quienesSomos: _stringValue(json, 'quienes_somos'),
    significadoAiki: _stringValue(json, 'significado_aiki'),
    mision: _stringValue(json, 'mision'),
    vision: _stringValue(json, 'vision'),
    filosofia: _stringValue(json, 'filosofia'),
    mensajeFundadoresTitulo: _stringValue(json, 'mensaje_fundadores_titulo'),
    mensajeFundadoresTexto: _stringValue(json, 'mensaje_fundadores_texto'),
    mensajeFundadoresImagePath1: _nullableStringValue(
      json,
      'mensaje_fundadores_image_path1',
    ),
    mensajeFundadoresImagePath2: _nullableStringValue(
      json,
      'mensaje_fundadores_image_path2',
    ),
    mensajeFundadoresImagePath3: _nullableStringValue(
      json,
      'mensaje_fundadores_image_path3',
    ),
    mensajeFundadoresImagePath4: _nullableStringValue(
      json,
      'mensaje_fundadores_image_path4',
    ),
    mensajeFundadoresImagePath5: _nullableStringValue(
      json,
      'mensaje_fundadores_image_path5',
    ),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt:
        _nullableDateTimeValue(json, 'synced_at') ??
        _dateTimeValue(json, 'updated_at'),
  );
}

Map<String, dynamic> profileToRemote(LocalProfile profile) {
  return {
    'uuid_profile': profile.uuidProfile,
    'auth_user_id': profile.authUserId,
    'nombre': profile.nombre,
    'email': profile.email,
    'foto_path_supabase': profile.fotoPathSupabase,
    'role': profile.role,
    'activo': profile.activo,
    'onboarding_completado': profile.onboardingCompletado,
    'created_at': _dateToRemote(profile.createdAt),
    'updated_at': _dateToRemote(profile.updatedAt),
    'deleted_at': _dateToRemote(profile.deletedAt),
  };
}

Map<String, dynamic> profileToUserRemotePatch(LocalProfile profile) {
  return {
    'nombre': profile.nombre,
    'foto_path_supabase': profile.fotoPathSupabase,
    'onboarding_completado': profile.onboardingCompletado,
    'updated_at': _dateToRemote(profile.updatedAt),
  };
}

ProfilesTableCompanion profileRemoteToCompanion(Map<String, dynamic> json) {
  final syncedAt = DateTime.now().toUtc();
  return ProfilesTableCompanion.insert(
    uuidProfile: _stringValue(json, 'uuid_profile'),
    authUserId: _stringValue(json, 'auth_user_id'),
    nombre: Value(_nullableStringValue(json, 'nombre')),
    email: _stringValue(json, 'email'),
    fotoPathSupabase: Value(_nullableStringValue(json, 'foto_path_supabase')),
    role: Value(_stringValue(json, 'role', fallback: 'user')),
    activo: Value(_boolValue(json, 'activo', fallback: true)),
    onboardingCompletado: Value(_boolValue(json, 'onboarding_completado')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

AppProfile profileRemoteToApp(Map<String, dynamic> json) {
  return AppProfile(
    uuidProfile: _stringValue(json, 'uuid_profile'),
    authUserId: _stringValue(json, 'auth_user_id'),
    nombre: _nullableStringValue(json, 'nombre'),
    email: _stringValue(json, 'email'),
    fotoPathSupabase: _nullableStringValue(json, 'foto_path_supabase'),
    fotoPathLocal: _nullableStringValue(json, 'foto_path_local'),
    role: _stringValue(json, 'role', fallback: 'user'),
    activo: _boolValue(json, 'activo', fallback: true),
    onboardingCompletado: _boolValue(json, 'onboarding_completado'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}

Map<String, dynamic> notificationDeviceToRemote(
  LocalNotificationDevice device,
) {
  return {
    'uuid_notification_device': device.uuidNotificationDevice,
    'uuid_profile': device.uuidProfile,
    'installation_id': device.installationId,
    'fcm_token': device.fcmToken,
    'platform': device.platform,
    'permission_status': device.permissionStatus,
    'app_version': device.appVersion,
    'timezone': device.timeZone,
    'is_active': device.isActive,
    'registration_refreshed_at': _dateToRemote(device.registrationRefreshedAt),
    'created_at': _dateToRemote(device.createdAt),
    'updated_at': _dateToRemote(device.updatedAt),
    'deleted_at': _dateToRemote(device.deletedAt),
  };
}

NotificationDevicesTableCompanion notificationDeviceRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return NotificationDevicesTableCompanion.insert(
    uuidNotificationDevice: _stringValue(json, 'uuid_notification_device'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    installationId: _stringValue(json, 'installation_id'),
    fcmToken: Value(_nullableStringValue(json, 'fcm_token')),
    platform: _stringValue(json, 'platform'),
    permissionStatus: Value(
      _stringValue(json, 'permission_status', fallback: 'not_determined'),
    ),
    appVersion: Value(_nullableStringValue(json, 'app_version')),
    timeZone: Value(_nullableStringValue(json, 'timezone')),
    isActive: Value(_boolValue(json, 'is_active', fallback: true)),
    registrationRefreshedAt: Value(
      _nullableDateTimeValue(json, 'registration_refreshed_at'),
    ),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

AppNotificationDevice notificationDeviceRemoteToApp(Map<String, dynamic> json) {
  return AppNotificationDevice(
    uuidNotificationDevice: _stringValue(json, 'uuid_notification_device'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    installationId: _stringValue(json, 'installation_id'),
    fcmToken: _nullableStringValue(json, 'fcm_token'),
    platform: _stringValue(json, 'platform'),
    permissionStatus: _stringValue(
      json,
      'permission_status',
      fallback: 'not_determined',
    ),
    appVersion: _nullableStringValue(json, 'app_version'),
    timeZone: _nullableStringValue(json, 'timezone'),
    isActive: _boolValue(json, 'is_active', fallback: true),
    registrationRefreshedAt: _nullableDateTimeValue(
      json,
      'registration_refreshed_at',
    ),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}

Map<String, dynamic> notificationEventToRemote(LocalNotificationEvent event) {
  return {
    'uuid_notification_event': event.uuidNotificationEvent,
    'name': event.name,
    'category': event.category,
    'title_template': event.titleTemplate,
    'body_template': event.bodyTemplate,
    'trigger_type': event.triggerType,
    'trigger_key': event.triggerKey,
    'execution_mode': event.executionMode,
    'audience_type': event.audienceType,
    'action_type': event.actionType,
    'action_payload_template': decodeJsonObject(
      event.actionPayloadTemplateJson,
    ),
    'trigger_config': decodeJsonObject(event.triggerConfigJson),
    'starts_at': _dateToRemote(event.startsAt),
    'ends_at': _dateToRemote(event.endsAt),
    'status': event.status,
    'uuid_created_by_profile': event.uuidCreatedByProfile,
    'uuid_updated_by_profile': event.uuidUpdatedByProfile,
    'created_at': _dateToRemote(event.createdAt),
    'updated_at': _dateToRemote(event.updatedAt),
    'deleted_at': _dateToRemote(event.deletedAt),
  };
}

NotificationEventsTableCompanion notificationEventRemoteToCompanion(
  Map<String, dynamic> json,
) {
  return NotificationEventsTableCompanion.insert(
    uuidNotificationEvent: _stringValue(json, 'uuid_notification_event'),
    name: _stringValue(json, 'name'),
    category: _stringValue(json, 'category'),
    titleTemplate: _stringValue(json, 'title_template'),
    bodyTemplate: _stringValue(json, 'body_template'),
    triggerType: _stringValue(json, 'trigger_type'),
    triggerKey: Value(_nullableStringValue(json, 'trigger_key')),
    executionMode: _stringValue(json, 'execution_mode'),
    audienceType: _stringValue(json, 'audience_type'),
    actionType: _stringValue(json, 'action_type'),
    actionPayloadTemplateJson: Value(
      encodeJsonObject(_jsonObjectValue(json, 'action_payload_template')),
    ),
    triggerConfigJson: Value(
      encodeJsonObject(_jsonObjectValue(json, 'trigger_config')),
    ),
    startsAt: Value(_dateTimeValue(json, 'starts_at')),
    endsAt: Value(_nullableDateTimeValue(json, 'ends_at')),
    status: Value(_stringValue(json, 'status', fallback: 'draft')),
    uuidCreatedByProfile: Value(
      _nullableStringValue(json, 'uuid_created_by_profile'),
    ),
    uuidUpdatedByProfile: Value(
      _nullableStringValue(json, 'uuid_updated_by_profile'),
    ),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(DateTime.now().toUtc()),
  );
}

AppNotificationEvent notificationEventRemoteToApp(Map<String, dynamic> json) {
  return AppNotificationEvent(
    uuidNotificationEvent: _stringValue(json, 'uuid_notification_event'),
    name: _stringValue(json, 'name'),
    category: _stringValue(json, 'category'),
    titleTemplate: _stringValue(json, 'title_template'),
    bodyTemplate: _stringValue(json, 'body_template'),
    triggerType: _stringValue(json, 'trigger_type'),
    triggerKey: _nullableStringValue(json, 'trigger_key'),
    executionMode: _stringValue(json, 'execution_mode'),
    audienceType: _stringValue(json, 'audience_type'),
    actionType: _stringValue(json, 'action_type'),
    actionPayloadTemplate: _jsonObjectValue(json, 'action_payload_template'),
    triggerConfig: _jsonObjectValue(json, 'trigger_config'),
    startsAt: _dateTimeValue(json, 'starts_at'),
    endsAt: _nullableDateTimeValue(json, 'ends_at'),
    status: _stringValue(json, 'status', fallback: 'draft'),
    uuidCreatedByProfile: _nullableStringValue(json, 'uuid_created_by_profile'),
    uuidUpdatedByProfile: _nullableStringValue(json, 'uuid_updated_by_profile'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt:
        _nullableDateTimeValue(json, 'synced_at') ??
        _dateTimeValue(json, 'updated_at'),
  );
}

NotificationDispatchesTableCompanion notificationDispatchRemoteToCompanion(
  Map<String, dynamic> json,
) {
  return NotificationDispatchesTableCompanion.insert(
    uuidNotificationDispatch: _stringValue(json, 'uuid_notification_dispatch'),
    uuidNotificationEvent: _stringValue(json, 'uuid_notification_event'),
    triggerSource: _stringValue(json, 'trigger_source'),
    uuidTriggeredByProfile: Value(
      _nullableStringValue(json, 'uuid_triggered_by_profile'),
    ),
    sourceEntityType: Value(_nullableStringValue(json, 'source_entity_type')),
    sourceEntityUuid: Value(_nullableStringValue(json, 'source_entity_uuid')),
    idempotencyKey: _stringValue(json, 'idempotency_key'),
    titleSnapshot: _stringValue(json, 'title_snapshot'),
    bodySnapshot: _stringValue(json, 'body_snapshot'),
    categorySnapshot: _stringValue(json, 'category_snapshot'),
    audienceTypeSnapshot: _stringValue(json, 'audience_type_snapshot'),
    actionTypeSnapshot: _stringValue(json, 'action_type_snapshot'),
    actionPayloadSnapshotJson: Value(
      encodeJsonObject(_jsonObjectValue(json, 'action_payload_snapshot')),
    ),
    status: Value(_stringValue(json, 'status', fallback: 'pending')),
    targetProfileCount: Value(_intValue(json, 'target_profile_count')),
    targetDeviceCount: Value(_intValue(json, 'target_device_count')),
    successDeviceCount: Value(_intValue(json, 'success_device_count')),
    failureDeviceCount: Value(_intValue(json, 'failure_device_count')),
    invalidTokenCount: Value(_intValue(json, 'invalid_token_count')),
    startedAt: Value(_nullableDateTimeValue(json, 'started_at')),
    completedAt: Value(_nullableDateTimeValue(json, 'completed_at')),
    errorSummary: Value(_nullableStringValue(json, 'error_summary')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(DateTime.now().toUtc()),
  );
}

AppNotificationDispatch notificationDispatchRemoteToApp(
  Map<String, dynamic> json,
) {
  return AppNotificationDispatch(
    uuidNotificationDispatch: _stringValue(json, 'uuid_notification_dispatch'),
    uuidNotificationEvent: _stringValue(json, 'uuid_notification_event'),
    triggerSource: _stringValue(json, 'trigger_source'),
    uuidTriggeredByProfile: _nullableStringValue(
      json,
      'uuid_triggered_by_profile',
    ),
    sourceEntityType: _nullableStringValue(json, 'source_entity_type'),
    sourceEntityUuid: _nullableStringValue(json, 'source_entity_uuid'),
    idempotencyKey: _stringValue(json, 'idempotency_key'),
    titleSnapshot: _stringValue(json, 'title_snapshot'),
    bodySnapshot: _stringValue(json, 'body_snapshot'),
    categorySnapshot: _stringValue(json, 'category_snapshot'),
    audienceTypeSnapshot: _stringValue(json, 'audience_type_snapshot'),
    actionTypeSnapshot: _stringValue(json, 'action_type_snapshot'),
    actionPayloadSnapshot: _jsonObjectValue(json, 'action_payload_snapshot'),
    status: _stringValue(json, 'status', fallback: 'pending'),
    targetProfileCount: _intValue(json, 'target_profile_count'),
    targetDeviceCount: _intValue(json, 'target_device_count'),
    successDeviceCount: _intValue(json, 'success_device_count'),
    failureDeviceCount: _intValue(json, 'failure_device_count'),
    invalidTokenCount: _intValue(json, 'invalid_token_count'),
    startedAt: _nullableDateTimeValue(json, 'started_at'),
    completedAt: _nullableDateTimeValue(json, 'completed_at'),
    errorSummary: _nullableStringValue(json, 'error_summary'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt:
        _nullableDateTimeValue(json, 'synced_at') ??
        _dateTimeValue(json, 'updated_at'),
  );
}

NotificationsInboxTableCompanion notificationInboxRemoteToCompanion(
  Map<String, dynamic> json,
) {
  return NotificationsInboxTableCompanion.insert(
    uuidNotificationInbox: _stringValue(json, 'uuid_notification_inbox'),
    uuidNotificationDispatch: _stringValue(json, 'uuid_notification_dispatch'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    title: _stringValue(json, 'title'),
    body: _stringValue(json, 'body'),
    category: _stringValue(json, 'category'),
    actionType: _stringValue(json, 'action_type'),
    actionPayloadJson: Value(
      encodeJsonObject(_jsonObjectValue(json, 'action_payload')),
    ),
    readAt: Value(_nullableDateTimeValue(json, 'read_at')),
    openedAt: Value(_nullableDateTimeValue(json, 'opened_at')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(DateTime.now().toUtc()),
  );
}

AppNotificationInboxItem notificationInboxRemoteToApp(
  Map<String, dynamic> json,
) {
  return AppNotificationInboxItem(
    uuidNotificationInbox: _stringValue(json, 'uuid_notification_inbox'),
    uuidNotificationDispatch: _stringValue(json, 'uuid_notification_dispatch'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    title: _stringValue(json, 'title'),
    body: _stringValue(json, 'body'),
    category: _stringValue(json, 'category'),
    actionType: _stringValue(json, 'action_type'),
    actionPayload: _jsonObjectValue(json, 'action_payload'),
    readAt: _nullableDateTimeValue(json, 'read_at'),
    openedAt: _nullableDateTimeValue(json, 'opened_at'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt:
        _nullableDateTimeValue(json, 'synced_at') ??
        _dateTimeValue(json, 'updated_at'),
  );
}

Map<String, dynamic> notificationInboxReadStateToRemote(
  LocalNotificationInboxItem item,
) {
  return {
    'read_at': _dateToRemote(item.readAt),
    'opened_at': _dateToRemote(item.openedAt),
  };
}

Map<String, dynamic> contentItemToRemote(LocalContentItem item) {
  return {
    'uuid_content_item': item.uuidContentItem,
    'tipo': item.tipo,
    'titulo': item.titulo,
    'subtitulo': item.subtitulo,
    'descripcion': item.descripcion,
    'cover_path_supabase': item.coverPathSupabase,
    'status': item.status,
    'destacado': item.destacado,
    'descargable': item.descargable,
    'duracion_segundos': item.duracionSegundos,
    'orden': item.orden,
    'created_by': item.createdBy,
    'created_at': _dateToRemote(item.createdAt),
    'updated_at': _dateToRemote(item.updatedAt),
    'deleted_at': _dateToRemote(item.deletedAt),
  };
}

ContentItemsTableCompanion contentItemRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return ContentItemsTableCompanion.insert(
    uuidContentItem: _stringValue(json, 'uuid_content_item'),
    tipo: _stringValue(json, 'tipo'),
    titulo: _stringValue(json, 'titulo'),
    subtitulo: Value(_nullableStringValue(json, 'subtitulo')),
    descripcion: Value(_nullableStringValue(json, 'descripcion')),
    coverPathSupabase: Value(_nullableStringValue(json, 'cover_path_supabase')),
    status: Value(_stringValue(json, 'status', fallback: 'draft')),
    destacado: Value(_boolValue(json, 'destacado')),
    descargable: Value(_boolValue(json, 'descargable')),
    duracionSegundos: Value(_nullableIntValue(json, 'duracion_segundos')),
    orden: Value(_intValue(json, 'orden')),
    createdBy: Value(_nullableStringValue(json, 'created_by')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

AppContentItem contentItemRemoteToApp(Map<String, dynamic> json) {
  return AppContentItem(
    uuidContentItem: _stringValue(json, 'uuid_content_item'),
    tipo: _stringValue(json, 'tipo'),
    titulo: _stringValue(json, 'titulo'),
    subtitulo: _nullableStringValue(json, 'subtitulo'),
    descripcion: _nullableStringValue(json, 'descripcion'),
    coverPathSupabase: _nullableStringValue(json, 'cover_path_supabase'),
    coverPathLocal: _nullableStringValue(json, 'cover_path_local'),
    status: _stringValue(json, 'status', fallback: 'draft'),
    destacado: _boolValue(json, 'destacado'),
    descargable: _boolValue(json, 'descargable'),
    duracionSegundos: _nullableIntValue(json, 'duracion_segundos'),
    orden: _intValue(json, 'orden'),
    createdBy: _nullableStringValue(json, 'created_by'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}

AppContentMedia contentMediaRemoteToApp(Map<String, dynamic> json) {
  return AppContentMedia(
    uuidContentMedia: _stringValue(json, 'uuid_content_media'),
    uuidContentItem: _stringValue(json, 'uuid_content_item'),
    tipo: _stringValue(json, 'type'),
    titulo: _nullableStringValue(json, 'title'),
    storagePathSupabase: _stringValue(json, 'storage_path'),
    storagePathLocal: _nullableStringValue(json, 'storage_path_local'),
    duracionSegundos: _nullableIntValue(json, 'duration_seconds'),
    orden: _intValue(json, 'sort_order'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}

Map<String, dynamic> contentMediaToRemote(LocalContentMedia media) {
  return {
    'uuid_content_media': media.uuidContentMedia,
    'uuid_content_item': media.uuidContentItem,
    'type': media.tipo,
    'title': media.titulo,
    'storage_path': media.storagePathSupabase,
    'duration_seconds': media.duracionSegundos,
    'sort_order': media.orden,
    'created_at': _dateToRemote(media.createdAt),
    'updated_at': _dateToRemote(media.updatedAt),
    'deleted_at': _dateToRemote(media.deletedAt),
  };
}

ContentMediaTableCompanion contentMediaRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return ContentMediaTableCompanion.insert(
    uuidContentMedia: _stringValue(json, 'uuid_content_media'),
    uuidContentItem: _stringValue(json, 'uuid_content_item'),
    tipo: _stringValue(json, 'type'),
    titulo: Value(_nullableStringValue(json, 'title')),
    storagePathSupabase: _stringValue(json, 'storage_path'),
    duracionSegundos: Value(_nullableIntValue(json, 'duration_seconds')),
    orden: Value(_intValue(json, 'sort_order')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

Map<String, dynamic> userContentStateToRemote(LocalUserContentState state) {
  return {
    'uuid_user_content_state': state.uuidUserContentState,
    'uuid_profile': state.uuidProfile,
    'uuid_content_item': state.uuidContentItem,
    'favorito': state.favorito,
    'progreso_porcentaje': state.progresoPorcentaje,
    'ultima_posicion_segundos': state.ultimaPosicionSegundos,
    'completado': state.completado,
    'started_at': _dateToRemote(state.startedAt),
    'completed_at': _dateToRemote(state.completedAt),
    'created_at': _dateToRemote(state.createdAt),
    'updated_at': _dateToRemote(state.updatedAt),
    'deleted_at': _dateToRemote(state.deletedAt),
    'synced_at': _dateToRemote(state.syncedAt),
  };
}

UserContentStatesTableCompanion userContentStateRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return UserContentStatesTableCompanion.insert(
    uuidUserContentState: _stringValue(json, 'uuid_user_content_state'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    uuidContentItem: _stringValue(json, 'uuid_content_item'),
    favorito: Value(_boolValue(json, 'favorito')),
    progresoPorcentaje: Value(_intValue(json, 'progreso_porcentaje')),
    ultimaPosicionSegundos: Value(_intValue(json, 'ultima_posicion_segundos')),
    completado: Value(_boolValue(json, 'completado')),
    startedAt: Value(_nullableDateTimeValue(json, 'started_at')),
    completedAt: Value(_nullableDateTimeValue(json, 'completed_at')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

AppUserContentState userContentStateRemoteToApp(Map<String, dynamic> json) {
  return AppUserContentState(
    uuidUserContentState: _stringValue(json, 'uuid_user_content_state'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    uuidContentItem: _stringValue(json, 'uuid_content_item'),
    favorito: _boolValue(json, 'favorito'),
    progresoPorcentaje: _intValue(json, 'progreso_porcentaje'),
    ultimaPosicionSegundos: _intValue(json, 'ultima_posicion_segundos'),
    completado: _boolValue(json, 'completado'),
    startedAt: _nullableDateTimeValue(json, 'started_at'),
    completedAt: _nullableDateTimeValue(json, 'completed_at'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}

Map<String, dynamic> wellnessDailyLogToRemote(LocalWellnessDailyLog log) {
  return {
    'uuid_daily_log': log.uuidDailyLog,
    'uuid_profile': log.uuidProfile,
    'fecha': log.fecha,
    'mood': log.mood,
    'energia': log.energia,
    'calma': log.calma,
    'descanso': log.descanso,
    'conexion': log.conexion,
    'meditacion_completada': log.meditacionCompletada,
    'minutos_bienestar': log.minutosBienestar,
    'nota': log.nota,
    'created_at': _dateToRemote(log.createdAt),
    'updated_at': _dateToRemote(log.updatedAt),
    'deleted_at': _dateToRemote(log.deletedAt),
    'synced_at': _dateToRemote(log.syncedAt),
  };
}

WellnessDailyLogsTableCompanion wellnessDailyLogRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return WellnessDailyLogsTableCompanion.insert(
    uuidDailyLog: _stringValue(json, 'uuid_daily_log'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    fecha: _dateOnlyValue(json, 'fecha'),
    mood: Value(_nullableStringValue(json, 'mood')),
    energia: Value(_intValue(json, 'energia')),
    calma: Value(_intValue(json, 'calma')),
    descanso: Value(_intValue(json, 'descanso')),
    conexion: Value(_intValue(json, 'conexion')),
    meditacionCompletada: Value(_boolValue(json, 'meditacion_completada')),
    minutosBienestar: Value(_intValue(json, 'minutos_bienestar')),
    nota: Value(_nullableStringValue(json, 'nota')),
    createdAt: Value(_dateTimeValue(json, 'created_at')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    deletedAt: Value(_nullableDateTimeValue(json, 'deleted_at')),
    syncedAt: Value(syncedAt),
  );
}

AppWellnessDailyLog wellnessDailyLogRemoteToApp(Map<String, dynamic> json) {
  return AppWellnessDailyLog(
    uuidDailyLog: _stringValue(json, 'uuid_daily_log'),
    uuidProfile: _stringValue(json, 'uuid_profile'),
    fecha: _dateOnlyValue(json, 'fecha'),
    mood: _nullableStringValue(json, 'mood'),
    energia: _intValue(json, 'energia'),
    calma: _intValue(json, 'calma'),
    descanso: _intValue(json, 'descanso'),
    conexion: _intValue(json, 'conexion'),
    meditacionCompletada: _boolValue(json, 'meditacion_completada'),
    minutosBienestar: _intValue(json, 'minutos_bienestar'),
    nota: _nullableStringValue(json, 'nota'),
    createdAt: _dateTimeValue(json, 'created_at'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    deletedAt: _nullableDateTimeValue(json, 'deleted_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}

Map<String, dynamic> wellnessProfileStatsToRemote(
  LocalWellnessProfileStats stats,
) {
  return {
    'uuid_profile': stats.uuidProfile,
    'current_streak': stats.currentStreak,
    'longest_streak': stats.longestStreak,
    'last_activity_date': stats.lastActivityDate,
    'total_active_days': stats.totalActiveDays,
    'updated_at': _dateToRemote(stats.updatedAt),
    'synced_at': _dateToRemote(stats.syncedAt),
  };
}

WellnessProfileStatsTableCompanion wellnessProfileStatsRemoteToCompanion(
  Map<String, dynamic> json,
) {
  final syncedAt = DateTime.now().toUtc();
  return WellnessProfileStatsTableCompanion.insert(
    uuidProfile: _stringValue(json, 'uuid_profile'),
    currentStreak: Value(_intValue(json, 'current_streak')),
    longestStreak: Value(_intValue(json, 'longest_streak')),
    lastActivityDate: Value(_nullableDateOnlyValue(json, 'last_activity_date')),
    totalActiveDays: Value(_intValue(json, 'total_active_days')),
    updatedAt: Value(_dateTimeValue(json, 'updated_at')),
    syncedAt: Value(syncedAt),
  );
}

AppWellnessProfileStats wellnessProfileStatsRemoteToApp(
  Map<String, dynamic> json,
) {
  return AppWellnessProfileStats(
    uuidProfile: _stringValue(json, 'uuid_profile'),
    currentStreak: _intValue(json, 'current_streak'),
    longestStreak: _intValue(json, 'longest_streak'),
    lastActivityDate: _nullableDateOnlyValue(json, 'last_activity_date'),
    totalActiveDays: _intValue(json, 'total_active_days'),
    updatedAt: _dateTimeValue(json, 'updated_at'),
    syncedAt: _nullableDateTimeValue(json, 'synced_at'),
  );
}
