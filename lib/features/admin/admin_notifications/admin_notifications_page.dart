import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/data/models/app_notification_dispatch.dart';
import '../../../core/data/models/app_notification_event.dart';
import '../../../core/data/models/notification_values.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/app_load_coordinator.dart';
import '../../../core/data/providers/notification_dispatches_controller.dart';
import '../../../core/data/providers/notification_events_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_segmented_tabs.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'admin_notification_event_form_page.dart';
import 'admin_notification_dispatch_detail_page.dart';
import 'notification_admin_labels.dart';
import 'notification_event_rule_summary.dart';
import 'notification_preview_card.dart';

enum AdminNotificationStatusFilter { all, draft, active, completed }

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;
  NotificationEventsController? _eventsController;
  NotificationDispatchesController? _dispatchesController;
  AdminNotificationStatusFilter _statusFilter =
      AdminNotificationStatusFilter.all;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final events = AppDataScope.notificationEvents(context);
    final dispatches = AppDataScope.notificationDispatches(context);
    final stats = AppDataScope.wellnessProfileStats(context);
    final profileUuid = AppDataScope.currentProfile(
      context,
    ).profile?.uuidProfile;
    if (profileUuid != null &&
        profileUuid.trim().isNotEmpty &&
        stats.activeProfileUuid != profileUuid) {
      stats.watchForProfile(profileUuid, pullRemote: false);
    }
    if (_eventsController == events && _dispatchesController == dispatches) {
      return;
    }

    _eventsController?.removeListener(_handleDataChanged);
    _dispatchesController?.removeListener(_handleDataChanged);
    _eventsController = events..addListener(_handleDataChanged);
    _dispatchesController = dispatches..addListener(_handleDataChanged);
    events.watchAll(pullRemote: false);
    dispatches.watchRecent(limit: 100, pullRemote: false);
    unawaited(
      AppDataScope.loadCoordinator(
        context,
      ).syncWithRemote(scope: AppLoadScope.adminNotifications),
    );
    _updatePolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _eventsController?.removeListener(_handleDataChanged);
    _dispatchesController?.removeListener(_handleDataChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleDataChanged() {
    _updatePolling();
  }

  void _updatePolling() {
    final isProcessing =
        _dispatchesController?.dispatches.any(
          (dispatch) => dispatch.status == 'processing',
        ) ??
        false;
    if (!isProcessing) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    _pollTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_pollProcessing());
    });
  }

  Future<void> _pollProcessing() async {
    await _dispatchesController?.pullFromRemote();
    await _eventsController?.pullFromRemote();
  }

  Future<void> _refresh() async {
    await AppDataScope.loadCoordinator(
      context,
    ).syncWithRemote(scope: AppLoadScope.adminNotifications);
  }

  Future<void> _openForm({
    AppNotificationEvent? event,
    bool duplicate = false,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AdminNotificationEventFormPage(event: event, duplicate: duplicate),
      ),
    );
  }

  Future<void> _archive(AppNotificationEvent event) async {
    final hasDispatch =
        await _dispatchesController?.hasDispatchForEvent(
          event.uuidNotificationEvent,
        ) ??
        false;
    if (!mounted) {
      return;
    }
    if (hasDispatch || !const {'draft', 'active'}.contains(event.status)) {
      _showMessage(
        'Sólo puedes archivar configuraciones que aún no se enviaron.',
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archivar configuración'),
        content: Text('¿Deseas archivar “${event.name}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await _eventsController?.archive(event.uuidNotificationEvent);
      await _eventsController?.syncWithRemote(throwOnError: true);
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo archivar la configuración.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  List<AppNotificationEvent> _filteredEvents(
    List<AppNotificationEvent> source,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return source
        .where((event) {
          final matchesStatus = switch (_statusFilter) {
            AdminNotificationStatusFilter.all => true,
            AdminNotificationStatusFilter.draft => event.status == 'draft',
            AdminNotificationStatusFilter.active => event.status == 'active',
            AdminNotificationStatusFilter.completed =>
              event.status == 'completed',
          };
          if (!matchesStatus || query.isEmpty) {
            return matchesStatus;
          }
          return [
            event.name,
            event.titleTemplate,
            event.bodyTemplate,
            notificationCategoryLabel(event.category),
          ].join(' ').toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventsController;
    final dispatches = _dispatchesController;
    final currentProfile = AppDataScope.currentProfile(context);
    final stats = AppDataScope.wellnessProfileStats(context);
    if (events == null || dispatches == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            events,
            dispatches,
            currentProfile,
            stats,
          ]),
          builder: (context, _) {
            final filtered = _filteredEvents(events.events);
            final profile = AppDataScope.currentProfile(context).profile;
            return AppRefreshIndicator(
              onRefresh: _refresh,
              notificationPredicate: (notification) => notification.depth > 0,
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppLogo(width: 148),
                          const SizedBox(height: AppSpacing.lg),
                          AdminNotificationsHeader(
                            total: events.events.length,
                            active: events.events
                                .where((item) => item.status == 'active')
                                .length,
                            sent: dispatches.dispatches.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      child: _AdminNotificationTabs(controller: _tabController),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 130),
                      children: [
                        AdminNotificationNewButton(
                          onPressed: () => _openForm(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _searchController,
                          hintText: 'Buscar configuración',
                          prefixIcon: Icons.search_rounded,
                          fillColor: Theme.of(context).colorScheme.surface,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _StatusFilters(
                          selected: _statusFilter,
                          onChanged: (value) =>
                              setState(() => _statusFilter = value),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (filtered.isEmpty)
                          const AdminNotificationsEmpty(
                            icon: Icons.notifications_none_rounded,
                            title: 'No hay configuraciones para mostrar',
                            body:
                                'Crea una notificación o cambia el filtro actual.',
                          )
                        else
                          ...filtered.map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: AdminNotificationEventCard(
                                event: event,
                                dispatchCount: dispatches.dispatches
                                    .where(
                                      (dispatch) =>
                                          dispatch.uuidNotificationEvent ==
                                          event.uuidNotificationEvent,
                                    )
                                    .length,
                                previewProfileName: profile?.nombre,
                                previewProfileEmail: profile?.email,
                                previewStreakValues:
                                    notificationStreakPreviewValuesForTrigger(
                                      triggerKey: event.triggerKey,
                                      triggerConfig: event.triggerConfig,
                                      currentStreak: stats.currentStreak,
                                      longestStreak: stats.longestStreak,
                                      lastActivityDate: stats.lastActivityDate,
                                    ),
                                onEdit: () => _openForm(event: event),
                                onDuplicate: () =>
                                    _openForm(event: event, duplicate: true),
                                onArchive: () => _archive(event),
                              ),
                            ),
                          ),
                      ],
                    ),
                    ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 130),
                      children: [
                        if (dispatches.dispatches.isEmpty)
                          const AdminNotificationsEmpty(
                            icon: Icons.history_rounded,
                            title: 'Todavía no hay envíos',
                            body:
                                'Aquí aparecerá el historial de notificaciones enviadas.',
                          )
                        else
                          ...dispatches.dispatches.map(
                            (dispatch) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: AdminNotificationDispatchCard(
                                dispatch: dispatch,
                                onTap: () => _openDispatchDetail(dispatch),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openDispatchDetail(AppNotificationDispatch dispatch) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminNotificationDispatchDetailPage(dispatch: dispatch),
      ),
    );
  }
}

class AdminNotificationsHeader extends StatelessWidget {
  const AdminNotificationsHeader({
    super.key,
    required this.total,
    required this.active,
    required this.sent,
  });

  final int total;
  final int active;
  final int sent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stroke = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(Theme.of(context).brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: AppTypography.displayFont,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Configura avisos manuales y consulta su historial de envío.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(value: total, label: 'Total'),
              ),
              Expanded(
                child: _HeaderMetric(
                  value: active,
                  label: 'Activas',
                  highlighted: true,
                ),
              ),
              Expanded(
                child: _HeaderMetric(value: sent, label: 'Envíos'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  final int value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontFamily: AppTypography.displayFont,
            color: color,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontFamily: AppTypography.displayFont,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AdminNotificationTabs extends StatelessWidget {
  const _AdminNotificationTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => AppSegmentedTabs(
        labels: const ['Configuraciones', 'Historial'],
        selectedIndex: controller.index,
        onChanged: controller.animateTo,
      ),
    );
  }
}

class AdminNotificationNewButton extends StatelessWidget {
  const AdminNotificationNewButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppInteractive(
      tooltip: 'Nueva notificación',
      borderRadius: AppRadius.large,
      onTap: onPressed,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: AppRadius.large,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_alert_rounded, color: scheme.onPrimary),
            const SizedBox(width: 10),
            Text(
              'Nueva notificación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: AppTypography.displayFont,
                color: scheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onChanged});

  final AdminNotificationStatusFilter selected;
  final ValueChanged<AdminNotificationStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      AdminNotificationStatusFilter.all: 'Todas',
      AdminNotificationStatusFilter.draft: 'Borradores',
      AdminNotificationStatusFilter.active: 'Activas',
      AdminNotificationStatusFilter.completed: 'Completadas',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AdminNotificationFilterChip(
                  label: entry.value,
                  selected: selected == entry.key,
                  onTap: () => onChanged(entry.key),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class AdminNotificationFilterChip extends StatelessWidget {
  const AdminNotificationFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppInteractive(
      tooltip: label,
      borderRadius: AppRadius.full,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: AppRadius.full,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontFamily: AppTypography.displayFont,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class AdminNotificationEventCard extends StatelessWidget {
  const AdminNotificationEventCard({
    super.key,
    required this.event,
    required this.dispatchCount,
    this.previewProfileName,
    this.previewProfileEmail,
    this.previewStreakValues = const {},
    required this.onEdit,
    required this.onDuplicate,
    required this.onArchive,
  });

  final AppNotificationEvent event;
  final int dispatchCount;
  final String? previewProfileName;
  final String? previewProfileEmail;
  final Map<String, String> previewStreakValues;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final canArchive =
        dispatchCount == 0 && const {'draft', 'active'}.contains(event.status);
    return _AdminNotificationCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: AppTypography.displayFont,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: event.status == 'completed' ? 'Ver' : 'Editar',
                onPressed: onEdit,
                icon: Icon(
                  event.status == 'completed'
                      ? Icons.visibility_outlined
                      : Icons.edit_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AdminNotificationPushPreview(
            title: _renderEventTemplate(
              event.titleTemplate,
              event.triggerKey,
              profileName: previewProfileName,
              profileEmail: previewProfileEmail,
              overrides: previewStreakValues,
            ),
            body: _renderEventTemplate(
              event.bodyTemplate,
              event.triggerKey,
              profileName: previewProfileName,
              profileEmail: previewProfileEmail,
              overrides: previewStreakValues,
            ),
            triggerType: event.triggerType,
            triggerKey: event.triggerKey,
          ),
          const SizedBox(height: 12),
          NotificationEventRuleSummary(event: event),
          const SizedBox(height: 12),
          if (event.hasPendingSync)
            const _InfoChip(label: 'Pendiente de sincronizar'),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                dispatchCount == 1 ? '1 envío' : '$dispatchCount envíos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (event.status == 'completed')
                TextButton.icon(
                  onPressed: onDuplicate,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Duplicar'),
                ),
              if (canArchive)
                IconButton(
                  tooltip: 'Archivar',
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _renderEventTemplate(
    String template,
    String? triggerKey, {
    String? profileName,
    String? profileEmail,
    Map<String, String> overrides = const {},
  }) {
    final parts = parseNotificationTemplate(
      template,
      allowedVariables: notificationAllowedTemplateVariables(triggerKey),
    );
    return renderNotificationTemplateExample(
      parts,
      examples: notificationTemplatePreviewValues(
        triggerKey,
        profileName: profileName,
        profileEmail: profileEmail,
        overrides: overrides,
      ),
    );
  }
}

class AdminNotificationDispatchCard extends StatelessWidget {
  const AdminNotificationDispatchCard({
    super.key,
    required this.dispatch,
    required this.onTap,
  });

  final AppNotificationDispatch dispatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppInteractive(
      tooltip: 'Ver detalle del envío',
      borderRadius: AppRadius.large,
      onTap: onTap,
      child: _AdminNotificationCardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dispatch.titleSnapshot,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: AppTypography.displayFont,
                    ),
                  ),
                ),
                _InfoChip(
                  label: notificationDispatchStatusLabel(dispatch.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dispatch.bodySnapshot,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              '${notificationDateTimeLabel(dispatch.createdAt)} · '
              '${notificationAudienceLabel(dispatch.audienceTypeSnapshot)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _DispatchMetric(
                  icon: Icons.people_outline_rounded,
                  label: notificationPeopleCountLabel(
                    dispatch.targetProfileCount,
                  ),
                ),
                _DispatchMetric(
                  icon: Icons.devices_rounded,
                  label: notificationDeviceCountLabel(
                    dispatch.targetDeviceCount,
                  ),
                ),
                _DispatchMetric(
                  icon: Icons.check_circle_outline_rounded,
                  label: '${dispatch.successDeviceCount} enviadas',
                ),
                _DispatchMetric(
                  icon: Icons.error_outline_rounded,
                  label: '${dispatch.failureDeviceCount} fallidas',
                ),
                _DispatchMetric(
                  icon: Icons.phonelink_erase_rounded,
                  label: '${dispatch.invalidTokenCount} no disponibles',
                ),
              ],
            ),
            if ((dispatch.errorSummary?.trim().isNotEmpty ?? false) &&
                !(dispatch.status == 'completed' &&
                    dispatch.failureDeviceCount == 0 &&
                    dispatch.invalidTokenCount == 0)) ...[
              const SizedBox(height: 10),
              Text(
                dispatch.errorSummary!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DispatchMetric extends StatelessWidget {
  const _DispatchMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.09),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontFamily: AppTypography.displayFont),
      ),
    );
  }
}

class _AdminNotificationCardShell extends StatelessWidget {
  const _AdminNotificationCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final stroke = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
      ),
      child: child,
    );
  }
}

class AdminNotificationsEmpty extends StatelessWidget {
  const AdminNotificationsEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
