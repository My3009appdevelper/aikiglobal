const notificationCategories = [
  'content',
  'events',
  'schedule_changes',
  'general',
  'admin',
  'progress',
];

const notificationAudienceTypes = ['all', 'all_users', 'all_admins'];

const notificationActionTypes = [
  'none',
  'open_content_item',
  'open_company_info',
  'open_home',
  'open_explore',
  'open_meditation',
];

const notificationEventTriggerTypes = [
  'manual',
  'domain_event',
  'schedule',
  'progress_event',
];
const notificationEventTriggerKeys = [
  'content.published',
  'content.updated',
  'event.published',
  'schedule.changed',
  'schedule.interval',
  'schedule.at_time',
  'progress.streak_reminder',
  'progress.streak_milestone',
];
const notificationEventExecutionModes = ['once', 'per_occurrence'];
const notificationScheduleIntervalPresets = ['12_hours', '1_day', '2_days'];
const notificationStreakMilestonePresets = [3, 7, 14, 30, 60, 100];

const notificationContentAutomaticTriggerKeys = [
  'content.published',
  'content.updated',
];

const notificationStreakAutomaticTriggerKeys = [
  'progress.streak_reminder',
  'progress.streak_milestone',
];
const notificationEventStatuses = [
  'draft',
  'active',
  'paused',
  'completed',
  'cancelled',
];

const notificationDispatchTriggerSources = [
  'manual',
  'scheduler',
  'domain_event',
];
const notificationDispatchStatuses = [
  'pending',
  'processing',
  'completed',
  'partial',
  'failed',
  'cancelled',
];

const notificationTemplateVariablesByTriggerKey = <String, Set<String>>{
  'content.published': {
    'profile_name',
    'profile_email',
    'content_title',
    'content_subtitle',
    'content_description',
    'content_uuid',
  },
  'content.updated': {
    'profile_name',
    'profile_email',
    'content_title',
    'content_subtitle',
    'content_description',
    'content_uuid',
  },
  'event.published': {
    'profile_name',
    'profile_email',
    'content_title',
    'content_subtitle',
    'content_description',
    'content_uuid',
  },
  'schedule.changed': {
    'schedule_name',
    'previous_time',
    'new_time',
    'effective_date',
  },
  'progress.streak_reminder': {
    'profile_name',
    'profile_email',
    'current_streak',
    'longest_streak',
    'last_activity_date',
    'next_milestone',
    'remaining_to_milestone',
  },
  'progress.streak_milestone': {
    'profile_name',
    'profile_email',
    'current_streak',
    'longest_streak',
    'last_activity_date',
    'next_milestone',
    'remaining_to_milestone',
  },
};

class NotificationTemplateVariable {
  const NotificationTemplateVariable({
    required this.key,
    required this.label,
    required this.example,
    this.compactLabel,
  });

  final String key;
  final String label;
  final String example;
  final String? compactLabel;

  String get displayLabel => compactLabel ?? label;
}

class NotificationTemplatePart {
  const NotificationTemplatePart.text(this.value) : token = null;

  const NotificationTemplatePart.token(this.token) : value = '';

  final String value;
  final String? token;

  bool get isToken => token != null;
}

const _commonNotificationTemplateVariables = [
  NotificationTemplateVariable(
    key: 'profile_name',
    label: 'Nombre del usuario',
    example: 'Ana',
    compactLabel: 'User',
  ),
  NotificationTemplateVariable(
    key: 'profile_email',
    label: 'Correo del usuario',
    example: 'ana@aiki.com',
    compactLabel: 'correo',
  ),
];

const _contentNotificationTemplateVariables = [
  NotificationTemplateVariable(
    key: 'content_title',
    label: 'Título del contenido',
    example: 'Respiración consciente',
    compactLabel: 'título',
  ),
  NotificationTemplateVariable(
    key: 'content_subtitle',
    label: 'Subtítulo del contenido',
    example: 'Una pausa para volver a ti',
    compactLabel: 'subtítulo',
  ),
  NotificationTemplateVariable(
    key: 'content_description',
    label: 'Descripción del contenido',
    example: 'Un momento para respirar.',
    compactLabel: 'descrip',
  ),
];

// Se conserva para que las plantillas antiguas que ya usan esta variable
// sigan siendo válidas, aunque ya no se ofrece como chip en el editor.
const _legacyContentTemplateVariableExamples = <String, String>{
  'content_type': 'Meditación',
};

const _streakNotificationTemplateVariables = [
  NotificationTemplateVariable(
    key: 'current_streak',
    label: 'Días de racha',
    example: '7',
    compactLabel: 'progreso',
  ),
  NotificationTemplateVariable(
    key: 'longest_streak',
    label: 'Racha más larga',
    example: '14',
    compactLabel: 'prog. max.',
  ),
  NotificationTemplateVariable(
    key: 'last_activity_date',
    label: 'Fecha de última actividad',
    example: '04/08/2026',
    compactLabel: 'fecha',
  ),
  NotificationTemplateVariable(
    key: 'next_milestone',
    label: 'Siguiente meta',
    example: '14',
    compactLabel: 'meta',
  ),
  NotificationTemplateVariable(
    key: 'remaining_to_milestone',
    label: 'Días para la siguiente meta',
    example: '7',
    compactLabel: 'faltan',
  ),
];

List<NotificationTemplateVariable> notificationTemplateVariablesForTrigger(
  String? triggerKey,
) {
  final variables = <NotificationTemplateVariable>[
    ..._commonNotificationTemplateVariables,
  ];
  if (isContentAutomaticTriggerKey(triggerKey)) {
    variables.addAll(_contentNotificationTemplateVariables);
  } else if (isStreakAutomaticTriggerKey(triggerKey)) {
    variables.addAll(_streakNotificationTemplateVariables);
  }
  return variables;
}

Set<String> notificationAllowedTemplateVariables(String? triggerKey) {
  final variables = notificationTemplateVariablesForTrigger(
    triggerKey,
  ).map((variable) => variable.key).toSet();
  if (isContentAutomaticTriggerKey(triggerKey)) {
    variables.addAll(_legacyContentTemplateVariableExamples.keys);
  }
  return variables;
}

Map<String, String> notificationTemplateExamplesForTrigger(String? triggerKey) {
  final examples = <String, String>{
    for (final variable in notificationTemplateVariablesForTrigger(triggerKey))
      variable.key: variable.example,
  };
  if (isContentAutomaticTriggerKey(triggerKey)) {
    examples.addAll(_legacyContentTemplateVariableExamples);
  }
  return examples;
}

Map<String, String> notificationTemplatePreviewValues(
  String? triggerKey, {
  String? profileName,
  String? profileEmail,
  Map<String, String> overrides = const {},
}) {
  final values = notificationTemplateExamplesForTrigger(triggerKey)
    ..remove('profile_name')
    ..remove('profile_email');
  final cleanName = profileName?.trim();
  final cleanEmail = profileEmail?.trim();
  if (cleanName != null && cleanName.isNotEmpty) {
    values['profile_name'] = cleanName;
  }
  if (cleanEmail != null && cleanEmail.isNotEmpty) {
    values['profile_email'] = cleanEmail;
  }
  values.addAll(overrides);
  return values;
}

List<int> notificationMilestonesFromConfig(Map<String, dynamic> config) {
  final raw = config['milestones'];
  if (raw is! List) {
    return notificationStreakMilestonePresets;
  }

  final milestones = <int>{};
  for (final value in raw) {
    if (value is num && value.isFinite && value == value.roundToDouble()) {
      final milestone = value.toInt();
      if (milestone > 0) {
        milestones.add(milestone);
      }
    }
  }
  if (milestones.isEmpty) {
    return notificationStreakMilestonePresets;
  }
  return milestones.toList()..sort();
}

Map<String, String> notificationStreakPreviewValues({
  required int currentStreak,
  required int longestStreak,
  String? lastActivityDate,
  Iterable<int> milestones = notificationStreakMilestonePresets,
}) {
  final current = currentStreak < 0 ? 0 : currentStreak;
  final longest = longestStreak < 0 ? 0 : longestStreak;
  final ordered = milestones.where((value) => value > current).toList()..sort();
  final nextMilestone = ordered.isEmpty ? current : ordered.first;
  final remaining = nextMilestone > current ? nextMilestone - current : 0;
  return {
    'current_streak': '$current',
    'longest_streak': '$longest',
    if (lastActivityDate != null && lastActivityDate.trim().isNotEmpty)
      'last_activity_date': lastActivityDate,
    'next_milestone': '$nextMilestone',
    'remaining_to_milestone': '$remaining',
  };
}

Map<String, String> notificationStreakPreviewValuesForTrigger({
  required String? triggerKey,
  required Map<String, dynamic> triggerConfig,
  required int currentStreak,
  required int longestStreak,
  String? lastActivityDate,
}) {
  final milestones = notificationMilestonesFromConfig(triggerConfig);
  if (triggerKey != 'progress.streak_milestone') {
    return notificationStreakPreviewValues(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: lastActivityDate,
      milestones: milestones,
    );
  }

  final selectedMilestone = milestones.first;
  final previewLongestStreak = longestStreak < selectedMilestone
      ? selectedMilestone
      : longestStreak;
  return {
    'current_streak': '$selectedMilestone',
    'longest_streak': '$previewLongestStreak',
    if (lastActivityDate != null && lastActivityDate.trim().isNotEmpty)
      'last_activity_date': lastActivityDate,
    'next_milestone': '$selectedMilestone',
    'remaining_to_milestone': '0',
  };
}

List<NotificationTemplatePart> parseNotificationTemplate(
  String template, {
  required Set<String> allowedVariables,
}) {
  final parts = <NotificationTemplatePart>[];
  final pattern = RegExp(r'\{([a-z][a-z0-9_]*)\}');
  var cursor = 0;
  for (final match in pattern.allMatches(template)) {
    final variable = match.group(1)!;
    final before = template.substring(cursor, match.start);
    if (before.isNotEmpty) {
      parts.add(NotificationTemplatePart.text(before));
    }
    if (allowedVariables.contains(variable)) {
      parts.add(NotificationTemplatePart.token(variable));
    } else {
      parts.add(NotificationTemplatePart.text(match.group(0)!));
    }
    cursor = match.end;
  }
  final remaining = template.substring(cursor);
  if (remaining.isNotEmpty) {
    parts.add(NotificationTemplatePart.text(remaining));
  }
  return parts;
}

String serializeNotificationTemplate(List<NotificationTemplatePart> parts) {
  return parts
      .map((part) => part.isToken ? '{${part.token}}' : part.value)
      .join();
}

String renderNotificationTemplateExample(
  List<NotificationTemplatePart> parts, {
  required Map<String, String> examples,
}) {
  return parts
      .map((part) => part.isToken ? examples[part.token] ?? '' : part.value)
      .join()
      .trim();
}

List<String> notificationTriggerKeysForType(String triggerType) {
  return switch (triggerType) {
    'domain_event' => const [
      'content.published',
      'content.updated',
      'event.published',
      'schedule.changed',
    ],
    'schedule' => const ['schedule.interval', 'schedule.at_time'],
    'progress_event' => const [
      'progress.streak_reminder',
      'progress.streak_milestone',
    ],
    _ => const [],
  };
}

List<String> notificationTriggerKeysForForm(
  String triggerType, {
  String? currentKey,
}) {
  final keys = switch (triggerType) {
    'domain_event' => notificationContentAutomaticTriggerKeys,
    _ => notificationTriggerKeysForType(triggerType),
  };
  if (currentKey != null &&
      currentKey.isNotEmpty &&
      !keys.contains(currentKey)) {
    return [...keys, currentKey];
  }
  return keys;
}

bool isContentAutomaticTriggerKey(String? triggerKey) {
  return triggerKey != null &&
      notificationContentAutomaticTriggerKeys.contains(triggerKey);
}

bool isStreakAutomaticTriggerKey(String? triggerKey) {
  return triggerKey != null &&
      notificationStreakAutomaticTriggerKeys.contains(triggerKey);
}

bool isAutomaticMessageTriggerKey(String? triggerKey) {
  return isContentAutomaticTriggerKey(triggerKey) ||
      isStreakAutomaticTriggerKey(triggerKey);
}

bool notificationContentDestinationIsDynamic(String? triggerKey) {
  return isContentAutomaticTriggerKey(triggerKey);
}

Map<String, dynamic> notificationActionPayloadTemplate({
  required String actionType,
  required String? triggerKey,
  required String? contentUuid,
}) {
  if (actionType != 'open_content_item') {
    return const {};
  }
  if (notificationContentDestinationIsDynamic(triggerKey)) {
    return const {'uuid_content_item': '{content_uuid}'};
  }
  final cleanContentUuid = contentUuid?.trim();
  return cleanContentUuid == null || cleanContentUuid.isEmpty
      ? const {}
      : {'uuid_content_item': cleanContentUuid};
}

String notificationAutomaticTitleTemplate(String triggerKey) {
  return switch (triggerKey) {
    'content.published' => 'Nueva publicación',
    'content.updated' => 'Contenido actualizado',
    'progress.streak_reminder' => 'Tu racha continúa',
    'progress.streak_milestone' => 'Meta de racha',
    _ => '',
  };
}

String notificationAutomaticMessageCoreTemplate(String triggerKey) {
  return switch (triggerKey) {
    'content.published' || 'content.updated' => '{content_title}',
    'progress.streak_reminder' => 'Llevas {current_streak} días de racha.',
    'progress.streak_milestone' => 'Alcanzaste {current_streak} días de racha.',
    _ => '',
  };
}

String notificationAutomaticMessageTemplate(
  String triggerKey, {
  String prefix = '',
  String suffix = '',
}) {
  final core = notificationAutomaticMessageCoreTemplate(triggerKey);
  if (core.isEmpty) {
    return '';
  }
  return [
    prefix.trim(),
    core,
    suffix.trim(),
  ].where((part) => part.isNotEmpty).join(' ');
}

String notificationAutomaticPreviewTitle(String triggerKey) {
  return notificationAutomaticTitleTemplate(triggerKey);
}

String notificationAutomaticPreviewBody(
  String triggerKey, {
  String prefix = '',
  String suffix = '',
}) {
  final example = switch (triggerKey) {
    'content.published' => 'Respiración consciente',
    'content.updated' => 'Meditación para dormir',
    'progress.streak_reminder' => 'Llevas 7 días de racha.',
    'progress.streak_milestone' => 'Alcanzaste 7 días de racha.',
    _ => '',
  };
  if (example.isEmpty) {
    return '';
  }
  return [
    prefix.trim(),
    example,
    suffix.trim(),
  ].where((part) => part.isNotEmpty).join(' ');
}

class NotificationAutomaticMessageAffixes {
  const NotificationAutomaticMessageAffixes({
    required this.prefix,
    required this.suffix,
  });

  final String prefix;
  final String suffix;
}

NotificationAutomaticMessageAffixes notificationAutomaticMessageAffixes(
  String triggerKey,
  String template,
) {
  final core = notificationAutomaticMessageCoreTemplate(triggerKey);
  final index = core.isEmpty ? -1 : template.indexOf(core);
  if (index < 0) {
    return const NotificationAutomaticMessageAffixes(prefix: '', suffix: '');
  }
  return NotificationAutomaticMessageAffixes(
    prefix: template.substring(0, index).trim(),
    suffix: template.substring(index + core.length).trim(),
  );
}

Map<String, dynamic> defaultNotificationTriggerConfig(String triggerKey) {
  return switch (triggerKey) {
    'schedule.interval' => {
      'interval_value': 12,
      'interval_unit': 'hours',
      'timezone_mode': 'user_local',
    },
    'schedule.at_time' => {
      'local_time': '08:00',
      'timezone_mode': 'user_local',
    },
    'progress.streak_reminder' => {
      'reminder_time': '20:00',
      'min_streak': 1,
      'timezone_mode': 'user_local',
    },
    'progress.streak_milestone' => {
      'milestones': [3, 7, 14, 30],
      'timezone_mode': 'user_local',
    },
    _ => <String, dynamic>{},
  };
}

void validateNotificationEventDefinition({
  required String name,
  required String category,
  required String titleTemplate,
  required String bodyTemplate,
  required String triggerType,
  required String? triggerKey,
  required String executionMode,
  required String audienceType,
  required String actionType,
  required Map<String, dynamic> actionPayloadTemplate,
  Map<String, dynamic> triggerConfig = const {},
  required DateTime startsAt,
  required DateTime? endsAt,
  required String status,
}) {
  _requireText(name, 'El nombre interno es obligatorio.');
  _requireText(titleTemplate, 'El título de la notificación es obligatorio.');
  _requireText(bodyTemplate, 'El mensaje de la notificación es obligatorio.');
  _requireAllowed(category, notificationCategories, 'categoría');
  _requireAllowed(triggerType, notificationEventTriggerTypes, 'disparador');
  _requireAllowed(
    executionMode,
    notificationEventExecutionModes,
    'modo de ejecución',
  );
  _requireAllowed(audienceType, notificationAudienceTypes, 'audiencia');
  _requireAllowed(actionType, notificationActionTypes, 'acción');
  _requireAllowed(status, notificationEventStatuses, 'estado');

  final cleanTriggerKey = _cleanNullableText(triggerKey);
  if (triggerType == 'manual') {
    if (cleanTriggerKey != null || executionMode != 'once') {
      throw ArgumentError(
        'Una notificación manual no lleva trigger_key y se ejecuta una vez.',
      );
    }
  } else {
    if (cleanTriggerKey == null ||
        !notificationEventTriggerKeys.contains(cleanTriggerKey)) {
      throw ArgumentError('El trigger_key automático no es válido.');
    }
  }

  _validateTriggerConfiguration(
    triggerType: triggerType,
    triggerKey: cleanTriggerKey,
    executionMode: executionMode,
    triggerConfig: triggerConfig,
  );

  if (endsAt != null && !endsAt.toUtc().isAfter(startsAt.toUtc())) {
    throw ArgumentError('La fecha final debe ser posterior a la inicial.');
  }

  if (actionType == 'open_content_item') {
    final contentUuid = actionPayloadTemplate['uuid_content_item'];
    if (contentUuid is! String || contentUuid.trim().isEmpty) {
      throw ArgumentError(
        'open_content_item requiere uuid_content_item en el payload.',
      );
    }
  }

  final allowedVariables = notificationAllowedTemplateVariables(
    cleanTriggerKey,
  );
  for (final template in [titleTemplate, bodyTemplate]) {
    _validateTemplateVariables(template, allowedVariables);
  }

  final payloadAllowedVariables = {...allowedVariables};
  if (isContentAutomaticTriggerKey(cleanTriggerKey)) {
    payloadAllowedVariables.add('content_uuid');
  }
  final payloadTemplateTexts = <String>[];
  _collectTemplateTexts(actionPayloadTemplate, payloadTemplateTexts);
  for (final template in payloadTemplateTexts) {
    _validateTemplateVariables(template, payloadAllowedVariables);
  }
}

bool notificationEventAllowsManualSend(String triggerType) {
  return triggerType == 'manual';
}

bool notificationDispatchAllowsManualAction(String triggerSource) {
  return triggerSource == 'manual';
}

void _validateTriggerConfiguration({
  required String triggerType,
  required String? triggerKey,
  required String executionMode,
  required Map<String, dynamic> triggerConfig,
}) {
  if (triggerType == 'manual') {
    if (triggerConfig.isNotEmpty) {
      throw ArgumentError('Una notificación manual no lleva configuración.');
    }
    return;
  }

  if (triggerType == 'domain_event') {
    if (!_isTriggerKeyIn(triggerKey, const {
      'content.published',
      'content.updated',
      'event.published',
      'schedule.changed',
    })) {
      throw ArgumentError('El trigger_key del evento no es válido.');
    }
    if (triggerConfig.isNotEmpty) {
      throw ArgumentError(
        'Un evento de dominio no lleva configuración adicional.',
      );
    }
    return;
  }

  if (triggerType == 'schedule') {
    if (!_isTriggerKeyIn(triggerKey, const {
      'schedule.interval',
      'schedule.at_time',
    })) {
      throw ArgumentError('El trigger_key del horario no es válido.');
    }
    if (executionMode != 'per_occurrence') {
      throw ArgumentError('Un horario debe ejecutarse en cada ocurrencia.');
    }
    _validateScheduleConfig(triggerKey!, triggerConfig);
    return;
  }

  if (triggerType == 'progress_event') {
    if (!_isTriggerKeyIn(triggerKey, const {
      'progress.streak_reminder',
      'progress.streak_milestone',
    })) {
      throw ArgumentError('El trigger_key de progreso no es válido.');
    }
    if (executionMode != 'per_occurrence') {
      throw ArgumentError(
        'Un evento de progreso debe ejecutarse en cada ocurrencia.',
      );
    }
    _validateProgressConfig(triggerKey!, triggerConfig);
  }
}

bool _isTriggerKeyIn(String? value, Set<String> allowed) {
  return value != null && allowed.contains(value);
}

void _validateScheduleConfig(String triggerKey, Map<String, dynamic> config) {
  _requireUserLocalTimezone(config);
  if (triggerKey == 'schedule.interval') {
    final value = config['interval_value'];
    final unit = config['interval_unit'];
    if (value is! int || value < 1 || value > 365) {
      throw ArgumentError('El intervalo debe ser un entero entre 1 y 365.');
    }
    if (unit != 'hours' && unit != 'days') {
      throw ArgumentError('La unidad del intervalo no es válida.');
    }
    if (unit == 'hours' && value > 24) {
      throw ArgumentError('El intervalo por horas no puede superar 24.');
    }
    return;
  }

  _requireLocalTime(config['local_time']);
  final days = config['days_of_week'];
  if (days != null &&
      (days is! List ||
          days.isEmpty ||
          days.any((day) => day is! int || day < 1 || day > 7))) {
    throw ArgumentError('Los días del horario no son válidos.');
  }
}

void _validateProgressConfig(String triggerKey, Map<String, dynamic> config) {
  _requireUserLocalTimezone(config);
  if (triggerKey == 'progress.streak_reminder') {
    _requireLocalTime(config['reminder_time']);
    final minStreak = config['min_streak'];
    if (minStreak != null && (minStreak is! int || minStreak < 1)) {
      throw ArgumentError('La racha mínima debe ser un entero positivo.');
    }
    return;
  }

  final milestones = config['milestones'];
  if (milestones is! List || milestones.isEmpty) {
    throw ArgumentError('Agrega al menos un objetivo de racha.');
  }
  final values = milestones.whereType<int>().toList(growable: false);
  if (values.length != milestones.length ||
      values.any((value) => value < 1) ||
      values.toSet().length != values.length) {
    throw ArgumentError('Los objetivos de racha deben ser enteros únicos.');
  }
}

void _requireUserLocalTimezone(Map<String, dynamic> config) {
  if (config['timezone_mode'] != 'user_local') {
    throw ArgumentError(
      'La regla debe usar la zona horaria local de cada usuario.',
    );
  }
}

void _requireLocalTime(Object? value) {
  if (value is! String ||
      !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value)) {
    throw ArgumentError('La hora local debe tener el formato HH:mm.');
  }
}

void _requireText(String value, String message) {
  if (value.trim().isEmpty) {
    throw ArgumentError(message);
  }
}

void _requireAllowed(String value, List<String> allowed, String field) {
  if (!allowed.contains(value.trim())) {
    throw ArgumentError('El valor de $field no es válido.');
  }
}

void _collectTemplateTexts(Object? value, List<String> output) {
  if (value is String) {
    output.add(value);
    return;
  }
  if (value is Map) {
    for (final entry in value.values) {
      _collectTemplateTexts(entry, output);
    }
    return;
  }
  if (value is List) {
    for (final entry in value) {
      _collectTemplateTexts(entry, output);
    }
  }
}

void _validateTemplateVariables(String template, Set<String> allowed) {
  final placeholderPattern = RegExp(r'\{([a-z][a-z0-9_]*)\}');
  final matches = placeholderPattern.allMatches(template);

  for (final match in matches) {
    final variable = match.group(1)!;
    if (!allowed.contains(variable)) {
      throw ArgumentError('La variable {$variable} no está permitida.');
    }
  }

  final withoutKnownPlaceholders = template.replaceAll(placeholderPattern, '');
  if (withoutKnownPlaceholders.contains('{') ||
      withoutKnownPlaceholders.contains('}')) {
    throw ArgumentError('La plantilla contiene una variable no válida.');
  }
}

String? _cleanNullableText(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}
