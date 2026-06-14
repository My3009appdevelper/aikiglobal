import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../models/app_content_item.dart';
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
