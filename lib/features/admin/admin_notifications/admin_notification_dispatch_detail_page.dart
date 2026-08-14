import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/data/models/app_notification_dispatch.dart';
import '../../../core/data/models/notification_dispatch_analytics.dart';
import '../../../core/data/models/notification_values.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/app_load_coordinator.dart';
import '../../../core/data/providers/notification_dispatches_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import 'notification_admin_labels.dart';

class AdminNotificationDispatchDetailPage extends StatefulWidget {
  const AdminNotificationDispatchDetailPage({
    super.key,
    required this.dispatch,
  });

  final AppNotificationDispatch dispatch;

  @override
  State<AdminNotificationDispatchDetailPage> createState() =>
      _AdminNotificationDispatchDetailPageState();
}

class _AdminNotificationDispatchDetailPageState
    extends State<AdminNotificationDispatchDetailPage> {
  NotificationDispatchesController? _controller;
  NotificationDispatchAnalytics? _analytics;
  bool _isLoading = true;
  bool _isActionInFlight = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppDataScope.notificationDispatches(context);
    if (_controller == controller) {
      return;
    }
    _controller = controller;
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final cached = controller.cachedAnalyticsFor(widget.dispatch);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _analytics = cached;
          _isLoading = false;
          _errorMessage = null;
        });
      }
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final analytics = await controller.loadAnalytics(widget.dispatch);
      if (!mounted) {
        return;
      }
      setState(() => _analytics = analytics);
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resend() async {
    final controller = _controller;
    if (controller == null || _isActionInFlight) {
      return;
    }
    final loadCoordinator = AppDataScope.loadCoordinator(context);
    final confirmed = await _confirmAction(
      title: 'Reenviar notificación',
      message:
          'Se creará un nuevo envío con el mismo título, mensaje, audiencia y destino. El historial actual se conservará.',
      actionLabel: 'Reenviar',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _isActionInFlight = true);
    try {
      final acceptance = await controller.requestManualResend(widget.dispatch);
      await loadCoordinator.syncWithRemote(
        scope: AppLoadScope.adminNotificationDispatch,
      );
      if (!mounted) {
        return;
      }
      _showMessage(
        acceptance.reused
            ? 'Este reenvío ya había sido solicitado.'
            : 'El reenvío fue aceptado y continuará en segundo plano.',
      );
    } catch (error) {
      if (mounted) {
        _showMessage(_friendlyError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInFlight = false);
      }
    }
  }

  Future<void> _retry() async {
    final controller = _controller;
    if (controller == null || _isActionInFlight) {
      return;
    }
    final loadCoordinator = AppDataScope.loadCoordinator(context);
    final confirmed = await _confirmAction(
      title: 'Reintentar envío',
      message:
          'Se volverá a procesar este envío fallido sin crear otro dispatch. Se conservarán sus destinatarios del inbox.',
      actionLabel: 'Reintentar',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _isActionInFlight = true);
    try {
      await controller.requestManualRetry(widget.dispatch);
      await loadCoordinator.syncWithRemote(
        scope: AppLoadScope.adminNotificationDispatch,
      );
      await _loadAnalytics();
      if (mounted) {
        _showMessage(
          'El reintento fue aceptado y continuará en segundo plano.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage(_friendlyError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInFlight = false);
      }
    }
  }

  Future<bool?> _confirmAction({
    required String title,
    required String message,
    required String actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final action = _actionForDispatch();
    return Scaffold(
      body: AppBackground(
        imageAsset: AppAssets.backgroundGarden,
        imageOpacity: 0.04,
        child: SafeArea(
          child: AppResponsiveContainer(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 130),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SnapshotCard(dispatch: widget.dispatch),
                        const SizedBox(height: AppSpacing.md),
                        if (_isLoading)
                          const _DetailStateCard(
                            icon: Icons.analytics_outlined,
                            message: 'Cargando indicadores del envío...',
                          )
                        else if (_errorMessage != null)
                          _DetailStateCard(
                            icon: Icons.error_outline_rounded,
                            message: _errorMessage!,
                            action: TextButton.icon(
                              onPressed: _loadAnalytics,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar consulta'),
                            ),
                          )
                        else if (_analytics != null)
                          _AnalyticsContent(analytics: _analytics!),
                        if (action != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          action,
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xl),
      child: Row(
        children: [
          AppBackButton(onTap: () => Navigator.of(context).pop()),
          const Spacer(),
          const AppLogo(width: 148),
        ],
      ),
    );
  }

  Widget? _actionForDispatch() {
    if (_isActionInFlight || widget.dispatch.status == 'processing') {
      return null;
    }
    if (!notificationDispatchAllowsManualAction(
      widget.dispatch.triggerSource,
    )) {
      return null;
    }
    if (const {'completed', 'partial'}.contains(widget.dispatch.status)) {
      return AppPrimaryButton(
        label: 'Reenviar notificación',
        icon: Icons.send_rounded,
        onPressed: _resend,
      );
    }
    if (widget.dispatch.status == 'failed' &&
        widget.dispatch.successDeviceCount == 0) {
      return AppSecondaryButton(
        label: 'Reintentar envío',
        icon: Icons.refresh_rounded,
        onPressed: _retry,
      );
    }
    return null;
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.dispatch});

  final AppNotificationDispatch dispatch;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dispatch.titleSnapshot,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: AppTypography.displayFont,
                  ),
                ),
              ),
              _DetailChip(
                label: notificationDispatchStatusLabel(dispatch.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(dispatch.bodySnapshot),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _DetailChip(
                label: notificationAudienceLabel(dispatch.audienceTypeSnapshot),
              ),
              _DetailChip(
                label: notificationCategoryLabel(dispatch.categorySnapshot),
              ),
              _DetailChip(
                label: notificationActionLabel(dispatch.actionTypeSnapshot),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enviado ${notificationDateTimeLabel(dispatch.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_shouldShowDispatchError(dispatch)) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _repairNotificationText(dispatch.errorSummary!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

bool _shouldShowDispatchError(AppNotificationDispatch dispatch) {
  final summary = dispatch.errorSummary?.trim();
  if (summary == null || summary.isEmpty) {
    return false;
  }
  if (dispatch.status == 'completed' &&
      dispatch.failureDeviceCount == 0 &&
      dispatch.invalidTokenCount == 0) {
    return false;
  }
  return true;
}

String _repairNotificationText(String value) {
  var repaired = value;
  const replacements = <String, String>{
    '\u00c3\u00a1': '\u00e1',
    '\u00c3\u00a9': '\u00e9',
    '\u00c3\u00ad': '\u00ed',
    '\u00c3\u00b3': '\u00f3',
    '\u00c3\u00ba': '\u00fa',
    '\u00c3\u00b1': '\u00f1',
    '\u00c3\u0081': '\u00c1',
    '\u00c3\u0089': '\u00c9',
    '\u00c3\u008d': '\u00cd',
    '\u00c3\u0093': '\u00d3',
    '\u00c3\u009a': '\u00da',
    '\u00c3\u0091': '\u00d1',
    '\u00c2\u00bf': '\u00bf',
    '\u00c2\u00a1': '\u00a1',
    '\u00c2\u00b7': '\u00b7',
  };
  for (final entry in replacements.entries) {
    repaired = repaired.replaceAll(entry.key, entry.value);
  }
  return repaired;
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.analytics});

  final NotificationDispatchAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionTitle(icon: Icons.insights_rounded, title: 'Indicadores'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 3 : 2;
            final width =
                (constraints.maxWidth - ((columns - 1) * AppSpacing.sm)) /
                columns;
            final metrics = [
              _MetricData(
                Icons.people_outline_rounded,
                notificationMetricPeopleLabel,
                '${analytics.targetProfileCount}',
              ),
              _MetricData(
                Icons.devices_rounded,
                notificationMetricDevicesLabel,
                '${analytics.targetDeviceCount}',
              ),
              _MetricData(
                Icons.check_circle_outline_rounded,
                notificationMetricSentLabel,
                '${analytics.successDeviceCount}',
              ),
              _MetricData(
                Icons.error_outline_rounded,
                notificationMetricFailedLabel,
                '${analytics.failureDeviceCount}',
              ),
              _MetricData(
                Icons.phonelink_erase_rounded,
                notificationMetricUnavailableLabel,
                '${analytics.invalidTokenCount}',
              ),
              _MetricData(
                Icons.visibility_outlined,
                notificationMetricOpenedLabel,
                '${analytics.openedCount} · ${(analytics.openedRate * 100).round()}%',
              ),
              _MetricData(
                Icons.mark_email_read_outlined,
                notificationMetricReadLabel,
                '${analytics.readCount} · ${(analytics.readRate * 100).round()}%',
              ),
            ];
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: metrics
                  .map(
                    (metric) => SizedBox(
                      width: width,
                      child: _MetricTile(data: metric),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),
        _DetailSectionTitle(
          icon: Icons.people_alt_outlined,
          title: 'Seguimiento por perfil',
        ),
        _RecipientsCard(recipients: analytics.recipients),
      ],
    );
  }
}

class _RecipientsCard extends StatelessWidget {
  const _RecipientsCard({required this.recipients});

  final List<NotificationDispatchRecipient> recipients;

  @override
  Widget build(BuildContext context) {
    if (recipients.isEmpty) {
      return const _DetailStateCard(
        icon: Icons.people_outline_rounded,
        message: 'No hay personas en la bandeja de este envío.',
      );
    }
    return _DetailCard(
      child: Column(
        children: recipients
            .map(
              (recipient) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _RecipientRow(recipient: recipient),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({required this.recipient});

  final NotificationDispatchRecipient recipient;

  @override
  Widget build(BuildContext context) {
    final status = recipient.isRead
        ? 'Leída'
        : recipient.isOpened
        ? 'Abierta'
        : 'Pendiente';
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            recipient.isRead
                ? Icons.mark_email_read_outlined
                : recipient.isOpened
                ? Icons.visibility_outlined
                : Icons.mail_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipient.displayName ?? recipient.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (recipient.displayName != null)
                Text(
                  recipient.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        _DetailChip(label: status),
      ],
    );
  }
}

class _MetricData {
  const _MetricData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(data.icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(data.label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppTypography.displayFont,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStateCard extends StatelessWidget {
  const _DetailStateCard({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        children: [
          Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(message, textAlign: TextAlign.center),
          ?action,
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: child,
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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

String _friendlyError(Object error) {
  final text = error.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '').trim();
  return text.isEmpty ? 'No se pudo consultar el seguimiento del envío.' : text;
}
