import 'package:aikiglobal/core/data/models/app_notification_event.dart';
import 'package:aikiglobal/core/data/models/manual_notification_dispatch_result.dart';
import 'package:aikiglobal/core/data/models/notification_values.dart';
import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/features/admin/admin_notifications/admin_notification_event_form_page.dart';
import 'package:aikiglobal/features/admin/admin_notifications/admin_notifications_page.dart';
import 'package:aikiglobal/features/admin/admin_notifications/notification_admin_labels.dart';
import 'package:aikiglobal/features/admin/admin_notifications/notification_preview_card.dart';
import 'package:aikiglobal/features/admin/admin_notifications/notification_template_editor.dart';
import 'package:aikiglobal/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('header muestra métricas con el estilo administrativo', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(const AdminNotificationsHeader(total: 8, active: 3, sent: 5)),
    );

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Notificaciones'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
  });

  test('la audiencia general se muestra como Todos', () {
    expect(notificationAudienceLabel('all'), 'Todos');
  });

  test('preview usa el perfil actual y no inventa datos de perfil', () {
    final values = notificationTemplatePreviewValues(
      'content.published',
      profileName: 'Mauricio Fukumoto',
      profileEmail: 'mauricio@aiki.com',
    );
    final withoutProfile = notificationTemplatePreviewValues(
      'content.published',
    );

    expect(values['profile_name'], 'Mauricio Fukumoto');
    expect(values['profile_email'], 'mauricio@aiki.com');
    expect(withoutProfile.containsKey('profile_name'), isFalse);
    expect(withoutProfile.containsKey('profile_email'), isFalse);
    expect(withoutProfile['content_title'], 'Respiración consciente');
  });

  test('preview usa la racha real en lugar del ejemplo', () {
    final values = notificationTemplatePreviewValues(
      'progress.streak_reminder',
      profileName: 'Mau',
      overrides: notificationStreakPreviewValues(
        currentStreak: 2,
        longestStreak: 2,
        milestones: const [3, 7],
      ),
    );

    expect(values['current_streak'], '2');
    expect(values['longest_streak'], '2');
    expect(values['next_milestone'], '3');
    expect(values['remaining_to_milestone'], '1');
  });

  test('solo los avisos manuales permiten acciones de envío inmediato', () {
    expect(notificationEventAllowsManualSend('manual'), isTrue);
    expect(notificationEventAllowsManualSend('domain_event'), isFalse);
    expect(notificationEventAllowsManualSend('schedule'), isFalse);
    expect(notificationEventAllowsManualSend('progress_event'), isFalse);

    expect(notificationDispatchAllowsManualAction('manual'), isTrue);
    expect(notificationDispatchAllowsManualAction('scheduler'), isFalse);
    expect(notificationDispatchAllowsManualAction('domain_event'), isFalse);
  });

  testWidgets('filtro seleccionado usa primary y onPrimary', (tester) async {
    final scheme = AppTheme.light.colorScheme;
    await tester.pumpWidget(
      themed(
        Row(
          children: [
            AdminNotificationFilterChip(
              label: 'Activas',
              selected: true,
              onTap: () {},
            ),
            AdminNotificationFilterChip(
              label: 'Borradores',
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Activas')).style?.color,
      scheme.onPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Borradores')).style?.color,
      scheme.onSurface,
    );
  });

  testWidgets('configuración completada sólo permite ver o duplicar', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        AdminNotificationEventCard(
          event: _event(status: 'completed'),
          dispatchCount: 1,
          onEdit: () {},
          onDuplicate: () {},
          onArchive: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.text('Duplicar'), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);
  });

  testWidgets('card muestra datos reales del perfil y regla de activación', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        AdminNotificationEventCard(
          event: _event(
            status: 'active',
            title: 'Hola {profile_name}',
            body: 'Descubre {content_title}.',
            triggerType: 'domain_event',
            triggerKey: 'content.published',
          ),
          dispatchCount: 0,
          previewProfileName: 'Mauricio Fukumoto',
          previewProfileEmail: 'mauricio@aiki.com',
          onEdit: () {},
          onDuplicate: () {},
          onArchive: () {},
        ),
      ),
    );

    expect(find.text('Hola Mauricio Fukumoto'), findsOneWidget);
    expect(find.text('Descubre Respiración consciente.'), findsOneWidget);
    expect(find.text('Nvo. contenido'), findsOneWidget);
    expect(find.textContaining('{'), findsNothing);
  });

  testWidgets('card muestra la racha real en la vista previa', (tester) async {
    await tester.pumpWidget(
      themed(
        AdminNotificationEventCard(
          event: _event(
            status: 'active',
            title: 'Tu progreso sigue',
            body:
                'Llevas {current_streak} días trabajando en ti, {profile_name}.',
            triggerType: 'progress_event',
            triggerKey: 'progress.streak_reminder',
          ),
          dispatchCount: 0,
          previewProfileName: 'Mau',
          previewStreakValues: notificationStreakPreviewValues(
            currentStreak: 2,
            longestStreak: 2,
            milestones: const [3, 7],
          ),
          onEdit: () {},
          onDuplicate: () {},
          onArchive: () {},
        ),
      ),
    );

    expect(find.text('Llevas 2 días trabajando en ti, Mau.'), findsOneWidget);
    expect(find.textContaining('Llevas 7 días'), findsNothing);
  });

  testWidgets('card muestra el momento y la acción de la notificación', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        AdminNotificationEventCard(
          event: _event(
            status: 'active',
            triggerType: 'schedule',
            triggerKey: 'schedule.at_time',
            executionMode: 'per_occurrence',
            actionType: 'open_explore',
            triggerConfig: const {
              'local_time': '17:00',
              'timezone_mode': 'user_local',
            },
          ),
          dispatchCount: 0,
          onEdit: () {},
          onDuplicate: () {},
          onArchive: () {},
        ),
      ),
    );

    expect(find.text('A una hora específica'), findsOneWidget);
    expect(find.text('A las 17:00 · hora local'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Audiencia'), findsOneWidget);
    expect(find.text('Usuarios'), findsOneWidget);
    expect(find.text('Vigencia'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Final'), findsOneWidget);
    expect(find.text('Indeterminada'), findsOneWidget);
    expect(find.text('Activa'), findsNothing);
    expect(find.text('General'), findsNothing);
  });

  testWidgets('vista previa representa el push real', (tester) async {
    await tester.pumpWidget(
      themed(
        const AdminNotificationPreviewCard(
          title: 'Nuevo audio',
          body: 'Escúchalo hoy.',
        ),
      ),
    );

    expect(find.text('Nuevo audio'), findsOneWidget);
    expect(find.text('Escúchalo hoy.'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.textContaining('Abrir Explorar'), findsNothing);
    expect(find.textContaining('Usuarios'), findsNothing);
  });

  testWidgets('vista previa usa surface como fondo del bloque', (tester) async {
    final scheme = AppTheme.light.colorScheme;

    await tester.pumpWidget(
      themed(
        const AdminNotificationPreviewCard(
          title: 'Nuevo audio',
          body: 'Escúchalo hoy.',
        ),
      ),
    );

    final cardContainer = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Vista previa'),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = cardContainer.decoration as BoxDecoration?;

    expect(decoration?.color, scheme.surface);
  });

  testWidgets('regla automática muestra disparador, recurrencia y vigencia', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        NotificationEventRuleCard(
          triggerType: 'domain_event',
          triggerKey: 'content.published',
          executionMode: 'per_occurrence',
          startsAt: DateTime.utc(2026, 7, 17, 12),
          endsAt: DateTime.utc(2026, 7, 31, 12),
          enabled: true,
          onTriggerTypeChanged: (_) {},
          onTriggerKeyChanged: (_) {},
          onExecutionModeChanged: (_) {},
          onStartsAtChanged: (_) {},
          onEndsAtChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Regla de activación'), findsOneWidget);
    expect(
      find.text(notificationTriggerTypeLabel('domain_event')),
      findsOneWidget,
    );
    expect(
      find.text(notificationTriggerKeyLabel('content.published')),
      findsOneWidget,
    );
    expect(find.text('Cada ocurrencia'), findsOneWidget);
    expect(find.text('Fecha inicial'), findsOneWidget);
    expect(find.text('Fecha final'), findsOneWidget);
  });

  testWidgets('regla de intervalo muestra la frecuencia y la zona local', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        NotificationEventRuleCard(
          triggerType: 'schedule',
          triggerKey: 'schedule.interval',
          executionMode: 'per_occurrence',
          triggerConfig: const {
            'interval_value': 12,
            'interval_unit': 'hours',
            'timezone_mode': 'user_local',
          },
          startsAt: DateTime.utc(2026, 7, 17, 12),
          endsAt: null,
          enabled: true,
          onTriggerTypeChanged: (_) {},
          onTriggerKeyChanged: (_) {},
          onExecutionModeChanged: (_) {},
          onTriggerConfigChanged: (_) {},
          onStartsAtChanged: (_) {},
          onEndsAtChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Cada 12 horas'), findsOneWidget);
    expect(find.text('Hora local de cada usuario'), findsOneWidget);
  });

  testWidgets('personalización automática usa chips y ejemplos', (
    tester,
  ) async {
    var title = 'Meta de racha';
    var body = 'Alcanzaste ';
    await tester.pumpWidget(
      themed(
        NotificationMessageTemplateFields(
          triggerKey: 'progress.streak_milestone',
          titleTemplate: title,
          bodyTemplate: body,
          enabled: true,
          onTitleChanged: (value) => title = value,
          onBodyChanged: (value) => body = value,
        ),
      ),
    );

    expect(
      find.text('Agrega texto o referencias personalizadas.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('template-text-0')).last);
    await tester.pump();
    expect(find.text('progreso'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);

    await tester.tap(find.text('progreso'));
    await tester.pump();
    expect(body, 'Alcanzaste {current_streak}');
    expect(title, 'Meta de racha');
  });

  testWidgets('diálogo bloquea envío cuando no hay perfiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AdminNotificationSendDialog(
            preview: _preview(profiles: 0, devices: 0),
          ),
        ),
      ),
    );

    expect(find.text('Enviar'), findsNothing);
    expect(find.text('Cerrar'), findsOneWidget);
    expect(find.textContaining('No hay personas para enviar'), findsOneWidget);
  });

  testWidgets('diálogo permite inbox aunque no haya dispositivos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AdminNotificationSendDialog(
            preview: _preview(profiles: 2, devices: 0),
          ),
        ),
      ),
    );

    expect(find.text('Enviar'), findsOneWidget);
    expect(
      find.textContaining('Se guardará el aviso en la app'),
      findsOneWidget,
    );
  });

  testWidgets('editor agrega y elimina variables como chips', (tester) async {
    var template = 'Hola ';
    await tester.pumpWidget(
      themed(
        NotificationTemplateEditor(
          label: 'Mensaje',
          initialTemplate: template,
          variables: notificationTemplateVariablesForTrigger(null),
          enabled: true,
          onChanged: (value) => template = value,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('template-text-0')));
    await tester.pump();
    await tester.tap(find.text('User').last);
    await tester.pump();
    expect(template, 'Hola {profile_name}');
    expect(find.text('User'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Quitar Nombre del usuario'));
    await tester.pump();
    expect(template, 'Hola ');
    expect(find.text('User'), findsOneWidget);
  });

  testWidgets('separa el campo de texto de la barra de variables', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        NotificationTemplateEditor(
          label: 'Título',
          initialTemplate: 'Nueva publicación',
          variables: notificationTemplateVariablesForTrigger(null),
          enabled: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('template-text-0')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('notification-template-toolbar-gap')),
      findsOneWidget,
    );
  });

  testWidgets('un chip se puede soltar entre caracteres del texto', (
    tester,
  ) async {
    var template = 'Hola {profile_name} mundo';
    await tester.pumpWidget(
      themed(
        NotificationTemplateEditor(
          label: 'Mensaje',
          initialTemplate: template,
          variables: notificationTemplateVariablesForTrigger(null),
          enabled: true,
          onChanged: (value) => template = value,
        ),
      ),
    );

    final token = find.text('User').first;
    final target = find.byKey(const ValueKey('template-text-2'));
    final gesture = await tester.startGesture(tester.getCenter(token));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(template, isNot('Hola {profile_name} mundo'));
    final tokenOffset = template.indexOf('{profile_name}');
    expect(tokenOffset, greaterThan('Hola '.length));
    expect(tokenOffset, lessThan(template.length - '{profile_name}'.length));
  });

  testWidgets('selectores largos usan ellipsis sin overflow', (tester) async {
    const longLabel = 'Contenido actualizado con un nombre muy extenso';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: NotificationFormSelect(
              label: 'Evento',
              value: 'updated',
              items: const ['updated'],
              labelFor: (_) => longLabel,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final label = tester.widget<Text>(find.text(longLabel));
    expect(label.maxLines, 2);
    expect(label.overflow, TextOverflow.ellipsis);
  });

  testWidgets('los selectores de opciones usan tarjetas visuales', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: NotificationFormSelect(
              label: 'Categoría',
              value: 'general',
              items: const ['general', 'events'],
              labelFor: (value) => value == 'general' ? 'General' : 'Eventos',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButtonFormField), findsNothing);
    expect(find.byIcon(Icons.tune_rounded), findsNWidgets(2));
  });

  testWidgets('las opciones se muestran en un carrusel horizontal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: NotificationFormSelect(
              label: 'Audiencia',
              value: 'all',
              items: const ['all', 'all_users', 'all_admins', 'extra'],
              labelFor: (value) => value,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final carousel = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('notification-options-carousel')),
    );
    expect(carousel.scrollDirection, Axis.horizontal);
  });

  testWidgets('chips largos del editor usan ellipsis sin overflow', (
    tester,
  ) async {
    const longLabel =
        'Nombre personalizado del usuario con una descripción extensa';
    await tester.pumpWidget(
      themed(
        SizedBox(
          width: 240,
          child: NotificationTemplateEditor(
            label: 'Mensaje',
            initialTemplate: '',
            variables: const [
              NotificationTemplateVariable(
                key: 'profile_name',
                label: longLabel,
                example: 'Ana',
              ),
            ],
            enabled: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('template-text-0')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final label = tester.widget<Text>(find.text(longLabel));
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
  });
}

AppNotificationEvent _event({
  required String status,
  String title = 'Título',
  String body = 'Mensaje',
  String triggerType = 'manual',
  String? triggerKey,
  String executionMode = 'once',
  String actionType = 'none',
  Map<String, dynamic> triggerConfig = const {},
}) {
  final now = DateTime.utc(2026, 7, 17);
  return AppNotificationEvent(
    uuidNotificationEvent: '11111111-1111-4111-8111-111111111111',
    name: 'Aviso de prueba',
    category: 'general',
    titleTemplate: title,
    bodyTemplate: body,
    triggerType: triggerType,
    triggerKey: triggerKey,
    executionMode: executionMode,
    audienceType: 'all_users',
    actionType: actionType,
    actionPayloadTemplate: const {},
    triggerConfig: triggerConfig,
    startsAt: now,
    status: status,
    createdAt: now,
    updatedAt: now,
    syncedAt: now,
  );
}

ManualNotificationAudiencePreview _preview({
  required int profiles,
  required int devices,
}) {
  return ManualNotificationAudiencePreview(
    uuidNotificationEvent: '11111111-1111-4111-8111-111111111111',
    title: 'Título',
    body: 'Mensaje',
    category: 'general',
    audienceType: 'all_users',
    actionType: 'none',
    actionPayload: const {},
    targetProfileCount: profiles,
    targetDeviceCount: devices,
  );
}
