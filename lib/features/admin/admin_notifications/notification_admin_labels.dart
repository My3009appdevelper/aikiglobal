import 'package:flutter/material.dart';

import '../../../core/data/models/app_notification_event.dart';
import '../../../core/data/models/notification_values.dart';

String notificationCategoryLabel(String value) => switch (value) {
  'content' => 'Contenido',
  'events' => 'Eventos',
  'schedule_changes' => 'Cambios de horario',
  'progress' => 'Progreso',
  'admin' => 'Admin.',
  _ => 'General',
};

IconData notificationCategoryIcon(String value) => switch (value) {
  'content' => Icons.auto_awesome_motion_outlined,
  'events' => Icons.event_available_outlined,
  'schedule_changes' => Icons.schedule_outlined,
  'progress' => Icons.local_fire_department_outlined,
  'admin' => Icons.admin_panel_settings_outlined,
  _ => Icons.notifications_none_rounded,
};

String notificationAudienceLabel(String value) => switch (value) {
  'all' => 'Todos',
  'all_admins' => 'Admins',
  _ => 'Usuarios',
};

IconData notificationAudienceIcon(String value) => switch (value) {
  'all' => Icons.groups_outlined,
  'all_admins' => Icons.admin_panel_settings_outlined,
  _ => Icons.person_outline_rounded,
};

String notificationActionLabel(String value) => switch (value) {
  'open_content_item' => 'Abrir contenido',
  'open_company_info' => '¿Quiénes somos?',
  'open_explore' => 'Explorar',
  'open_home' => 'Mi espacio',
  'open_meditation' => 'Abrir temp.',
  _ => 'Sin acción',
};

IconData notificationActionIcon(String value) => switch (value) {
  'open_content_item' => Icons.play_circle_outline_rounded,
  'open_company_info' => Icons.business_outlined,
  'open_home' => Icons.home_outlined,
  'open_explore' => Icons.explore_outlined,
  'open_meditation' => Icons.self_improvement_outlined,
  _ => Icons.notifications_none_rounded,
};

String notificationTriggerTypeLabel(String value) => switch (value) {
  'domain_event' => 'Auto',
  'schedule' => 'Horario',
  'progress_event' => 'Progreso personal',
  _ => 'Manual',
};

IconData notificationTriggerTypeIcon(String value) => switch (value) {
  'domain_event' => Icons.bolt_outlined,
  'schedule' => Icons.schedule_outlined,
  'progress_event' => Icons.local_fire_department_outlined,
  _ => Icons.touch_app_outlined,
};

String notificationTriggerKeyLabel(String value) => switch (value) {
  'content.published' => 'Nvo. contenido',
  'content.updated' => 'Edit. contenido',
  'event.published' => 'Nuevo evento publicado',
  'schedule.changed' => 'Cambio de horario',
  'schedule.interval' => 'Cierto tiempo',
  'schedule.at_time' => 'Hora específica',
  'progress.streak_reminder' => 'Recordatorio de racha',
  'progress.streak_milestone' => 'Meta de racha',
  _ => value,
};

IconData notificationTriggerKeyIcon(String value) => switch (value) {
  'content.published' => Icons.new_releases_outlined,
  'content.updated' => Icons.edit_note_outlined,
  'event.published' => Icons.event_available_outlined,
  'schedule.changed' => Icons.calendar_month_outlined,
  'schedule.interval' => Icons.autorenew_rounded,
  'schedule.at_time' => Icons.alarm_outlined,
  'progress.streak_reminder' => Icons.notifications_active_outlined,
  'progress.streak_milestone' => Icons.flag_outlined,
  _ => Icons.tune_rounded,
};

String notificationEventActivationLabel(AppNotificationEvent event) {
  if (event.triggerType == 'manual' ||
      event.triggerKey == null ||
      event.triggerKey!.trim().isEmpty) {
    return 'Al pulsar Enviar ahora';
  }

  return switch (event.triggerKey) {
    'content.published' => 'Al publicar contenido',
    'content.updated' => 'Al editar contenido',
    'event.published' => 'Al publicar un evento',
    'schedule.changed' => 'Al cambiar un horario',
    'schedule.interval' => 'Por intervalo',
    'schedule.at_time' => 'A una hora específica',
    'progress.streak_reminder' => 'Como recordatorio de racha',
    'progress.streak_milestone' => 'Al alcanzar una meta de racha',
    _ => notificationTriggerKeyLabel(event.triggerKey!),
  };
}

String notificationEventTimingLabel(AppNotificationEvent event) {
  final config = event.triggerConfig;
  return switch (event.triggerKey) {
    'schedule.interval' => '${_notificationIntervalLabel(config)} · hora local',
    'schedule.at_time' =>
      'A las ${_notificationConfigTime(config, 'local_time', '08:00')} · '
          'hora local',
    'progress.streak_reminder' =>
      'Cada día a '
          '${_notificationConfigTime(config, 'reminder_time', '20:00')} · '
          'hora local',
    'progress.streak_milestone' =>
      'Al alcanzar ${_notificationMilestoneLabel(config)}',
    'content.published' ||
    'content.updated' ||
    'event.published' ||
    'schedule.changed' => notificationExecutionModeLabel(event.executionMode),
    _ => 'Disponible para envío inmediato',
  };
}

String notificationEventValidityLabel(AppNotificationEvent event) {
  final start = notificationDateTimeLabel(event.startsAt);
  final end = event.endsAt;
  if (end == null) {
    return 'Vigencia: desde $start · sin fecha final';
  }
  return 'Vigencia: $start a ${notificationDateTimeLabel(end)}';
}

String _notificationIntervalLabel(Map<String, dynamic> config) {
  final value = config['interval_value'];
  final unit = config['interval_unit'];
  if (value is! num || unit is! String) {
    return 'Intervalo configurado';
  }
  final amount = value.toInt();
  if (unit == 'hours') {
    return 'Cada $amount ${amount == 1 ? 'hora' : 'horas'}';
  }
  return amount == 1 ? 'Cada día' : 'Cada $amount días';
}

String _notificationConfigTime(
  Map<String, dynamic> config,
  String key,
  String fallback,
) {
  final value = config[key];
  return value is String && value.trim().isNotEmpty ? value : fallback;
}

String _notificationMilestoneLabel(Map<String, dynamic> config) {
  final milestones = notificationMilestonesFromConfig(config);
  if (milestones.length == 1) {
    return '${milestones.first} días';
  }
  if (milestones.length == 2) {
    return '${milestones.first} y ${milestones.last} días';
  }
  final prefix = milestones.take(milestones.length - 1).join(', ');
  return '$prefix y ${milestones.last} días';
}

String notificationExecutionModeLabel(String value) => switch (value) {
  'per_occurrence' => 'Cada ocurrencia',
  _ => 'Una sola vez',
};

IconData notificationExecutionModeIcon(String value) => switch (value) {
  'per_occurrence' => Icons.repeat_rounded,
  _ => Icons.looks_one_outlined,
};

IconData notificationScheduleIntervalIcon(String value) => switch (value) {
  '12_hours' => Icons.schedule_outlined,
  '1_day' => Icons.today_outlined,
  '2_days' => Icons.date_range_outlined,
  _ => Icons.schedule_outlined,
};

String notificationEventStatusLabel(String value) => switch (value) {
  'active' => 'Activa',
  'completed' => 'Completada',
  'paused' => 'Pausada',
  'cancelled' => 'Cancelada',
  _ => 'Borrador',
};

String notificationDispatchStatusLabel(String value) => switch (value) {
  'pending' => 'Pendiente',
  'processing' => 'Procesando',
  'completed' => 'Completado',
  'partial' => 'Parcial',
  'failed' => 'Fallido',
  'cancelled' => 'Cancelado',
  _ => value,
};

const notificationMetricPeopleLabel = 'Personas';
const notificationMetricDevicesLabel = 'Dispositivos';
const notificationMetricSentLabel = 'Enviadas';
const notificationMetricFailedLabel = 'Fallidas';
const notificationMetricUnavailableLabel = 'No disponibles';
const notificationMetricOpenedLabel = 'Abiertas';
const notificationMetricReadLabel = 'Leídas';

String notificationPeopleCountLabel(int count) {
  return '$count ${count == 1 ? 'persona' : 'personas'}';
}

String notificationDeviceCountLabel(int count) {
  return '$count ${count == 1 ? 'dispositivo' : 'dispositivos'}';
}

String notificationDateTimeLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} · '
      '${two(local.hour)}:${two(local.minute)}';
}
