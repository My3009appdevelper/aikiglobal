import 'package:aikiglobal/core/data/common/json_object_codec.dart';
import 'package:aikiglobal/core/data/models/notification_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON object codec', () {
    test('encodes object keys canonically and round-trips nested values', () {
      final encoded = encodeJsonObject({
        'z': 1,
        'a': {'second': true, 'first': 'value'},
      });

      expect(encoded, '{"a":{"first":"value","second":true},"z":1}');
      expect(decodeJsonObject(encoded), {
        'a': {'first': 'value', 'second': true},
        'z': 1,
      });
    });

    test('rejects a JSON root that is not an object', () {
      expect(() => decodeJsonObject('[1,2]'), throwsArgumentError);
    });
  });

  group('notification event validation', () {
    test('form keeps only content publication automatic options', () {
      expect(notificationTriggerKeysForForm('domain_event'), [
        'content.published',
        'content.updated',
      ]);
      expect(
        notificationTriggerKeysForForm(
          'domain_event',
          currentKey: 'event.published',
        ),
        ['content.published', 'content.updated', 'event.published'],
      );
    });

    test('content automatic destinations use the triggering content', () {
      expect(
        notificationContentDestinationIsDynamic('content.published'),
        isTrue,
      );
      expect(
        notificationContentDestinationIsDynamic('progress.streak_reminder'),
        isFalse,
      );
    });

    test('uses the triggering content token for automatic content actions', () {
      expect(
        notificationActionPayloadTemplate(
          actionType: 'open_content_item',
          triggerKey: 'content.published',
          contentUuid: null,
        ),
        {'uuid_content_item': '{content_uuid}'},
      );
      expect(
        notificationActionPayloadTemplate(
          actionType: 'open_content_item',
          triggerKey: null,
          contentUuid: 'content-1',
        ),
        {'uuid_content_item': 'content-1'},
      );
    });

    test('builds the automatic content message with prefix and suffix', () {
      expect(
        notificationAutomaticTitleTemplate('content.published'),
        'Nueva publicación',
      );
      expect(
        notificationAutomaticMessageTemplate(
          'content.published',
          prefix: 'Descubre',
          suffix: 'en Aiki',
        ),
        'Descubre {content_title} en Aiki',
      );
      expect(
        notificationAutomaticPreviewBody(
          'content.published',
          prefix: 'Descubre',
          suffix: 'en Aiki',
        ),
        'Descubre Respiración consciente en Aiki',
      );
    });

    test('builds the automatic streak message with the current days', () {
      expect(
        notificationAutomaticTitleTemplate('progress.streak_reminder'),
        'Tu racha continúa',
      );
      expect(
        notificationAutomaticMessageTemplate(
          'progress.streak_reminder',
          prefix: 'Hoy',
          suffix: 'Sigue así',
        ),
        'Hoy Llevas {current_streak} días de racha. Sigue así',
      );
      expect(
        notificationAutomaticPreviewBody(
          'progress.streak_reminder',
          prefix: 'Hoy',
          suffix: 'Sigue así',
        ),
        'Hoy Llevas 7 días de racha. Sigue así',
      );
    });

    test('preview de meta de racha usa los días seleccionados', () {
      final values = notificationStreakPreviewValuesForTrigger(
        triggerKey: 'progress.streak_milestone',
        triggerConfig: const {
          'milestones': [3, 7],
        },
        currentStreak: 2,
        longestStreak: 2,
      );

      expect(values['current_streak'], '3');
      expect(values['longest_streak'], '3');
      expect(values['next_milestone'], '3');
      expect(values['remaining_to_milestone'], '0');
    });

    test('el editor no ofrece el chip de tipo de contenido', () {
      final variables = notificationTemplateVariablesForTrigger(
        'content.published',
      );

      expect(
        variables.any((variable) => variable.key == 'content_type'),
        isFalse,
      );
      expect(
        variables.map((variable) => variable.displayLabel),
        isNot(contains('tipo')),
      );
      expect(
        notificationAllowedTemplateVariables('content.published'),
        contains('content_type'),
      );
    });

    test('accepts a controlled content publication template', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Nuevo contenido',
          category: 'content',
          titleTemplate: 'Nuevo: {content_title}',
          bodyTemplate: '{content_subtitle}',
          triggerType: 'domain_event',
          triggerKey: 'content.published',
          executionMode: 'per_occurrence',
          audienceType: 'all_users',
          actionType: 'open_content_item',
          actionPayloadTemplate: const {'uuid_content_item': '{content_uuid}'},
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'active',
        ),
        returnsNormally,
      );
    });

    test(
      'requires manual notifications to execute once without trigger key',
      () {
        expect(
          () => validateNotificationEventDefinition(
            name: 'Aviso manual',
            category: 'general',
            titleTemplate: 'Aviso',
            bodyTemplate: 'Mensaje',
            triggerType: 'manual',
            triggerKey: null,
            executionMode: 'per_occurrence',
            audienceType: 'all',
            actionType: 'none',
            actionPayloadTemplate: const {},
            startsAt: DateTime.utc(2026, 7, 16),
            endsAt: null,
            status: 'draft',
          ),
          throwsArgumentError,
        );
      },
    );

    test('rejects placeholders not allowed for the trigger', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Nuevo contenido',
          category: 'content',
          titleTemplate: 'Hola {schedule_name}',
          bodyTemplate: 'Ya está disponible',
          triggerType: 'domain_event',
          triggerKey: 'content.published',
          executionMode: 'per_occurrence',
          audienceType: 'all_users',
          actionType: 'open_home',
          actionPayloadTemplate: const {},
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'active',
        ),
        throwsArgumentError,
      );
    });

    test('requires a content UUID payload for open_content_item', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Abrir contenido',
          category: 'general',
          titleTemplate: 'Contenido',
          bodyTemplate: 'Ábrelo ahora',
          triggerType: 'manual',
          triggerKey: null,
          executionMode: 'once',
          audienceType: 'all_users',
          actionType: 'open_content_item',
          actionPayloadTemplate: const {},
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'draft',
        ),
        throwsArgumentError,
      );
    });

    test('requires ends_at to be later than starts_at', () {
      final startsAt = DateTime.utc(2026, 7, 16, 12);

      expect(
        () => validateNotificationEventDefinition(
          name: 'Aviso',
          category: 'general',
          titleTemplate: 'Aviso',
          bodyTemplate: 'Mensaje',
          triggerType: 'manual',
          triggerKey: null,
          executionMode: 'once',
          audienceType: 'all',
          actionType: 'none',
          actionPayloadTemplate: const {},
          startsAt: startsAt,
          endsAt: startsAt,
          status: 'draft',
        ),
        throwsArgumentError,
      );
    });

    test('accepts content.updated with the same content variables', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Contenido actualizado',
          category: 'content',
          titleTemplate: 'Actualizado: {content_title}',
          bodyTemplate: '{content_type}',
          triggerType: 'domain_event',
          triggerKey: 'content.updated',
          executionMode: 'per_occurrence',
          audienceType: 'all_users',
          actionType: 'open_content_item',
          actionPayloadTemplate: const {'uuid_content_item': '{content_uuid}'},
          triggerConfig: const {},
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'active',
        ),
        returnsNormally,
      );
    });

    test('accepts an interval schedule in the users local timezone', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Cada doce horas',
          category: 'schedule_changes',
          titleTemplate: 'Un momento para ti',
          bodyTemplate: 'Regresa a tu práctica.',
          triggerType: 'schedule',
          triggerKey: 'schedule.interval',
          executionMode: 'per_occurrence',
          audienceType: 'all_users',
          actionType: 'open_meditation',
          actionPayloadTemplate: const {},
          triggerConfig: const {
            'interval_value': 12,
            'interval_unit': 'hours',
            'timezone_mode': 'user_local',
          },
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'active',
        ),
        returnsNormally,
      );
    });

    test('accepts a streak milestone with a controlled milestone list', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Rachas',
          category: 'progress',
          titleTemplate: 'Vas {current_streak} días',
          bodyTemplate: 'Tu siguiente meta es {next_milestone}.',
          triggerType: 'progress_event',
          triggerKey: 'progress.streak_milestone',
          executionMode: 'per_occurrence',
          audienceType: 'all_users',
          actionType: 'open_meditation',
          actionPayloadTemplate: const {},
          triggerConfig: const {
            'timezone_mode': 'user_local',
            'milestones': [3, 7, 14, 30],
          },
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'active',
        ),
        returnsNormally,
      );
    });

    test('rejects a local schedule without its required configuration', () {
      expect(
        () => validateNotificationEventDefinition(
          name: 'Horario incompleto',
          category: 'general',
          titleTemplate: 'Aviso',
          bodyTemplate: 'Mensaje',
          triggerType: 'schedule',
          triggerKey: 'schedule.at_time',
          executionMode: 'per_occurrence',
          audienceType: 'all_users',
          actionType: 'none',
          actionPayloadTemplate: const {},
          triggerConfig: const {'timezone_mode': 'utc'},
          startsAt: DateTime.utc(2026, 7, 16),
          endsAt: null,
          status: 'draft',
        ),
        throwsArgumentError,
      );
    });
  });
}
