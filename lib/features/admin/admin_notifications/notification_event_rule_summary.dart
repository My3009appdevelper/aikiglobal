import 'package:flutter/material.dart';

import '../../../core/data/models/app_notification_event.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'notification_admin_labels.dart';

class NotificationEventRuleSummary extends StatelessWidget {
  const NotificationEventRuleSummary({super.key, required this.event});

  final AppNotificationEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo funciona',
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppTypography.displayFont,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RuleSummaryRow(
          icon: notificationTriggerTypeIcon(event.triggerType),
          label: 'Se activa',
          value: notificationEventActivationLabel(event),
        ),
        const SizedBox(height: AppSpacing.xs),
        _RuleSummaryRow(
          icon: Icons.schedule_outlined,
          label: 'Cuándo',
          value: notificationEventTimingLabel(event),
        ),
        const SizedBox(height: AppSpacing.xs),
        _RuleSummaryRow(
          icon: notificationActionIcon(event.actionType),
          label: 'Al pulsarla',
          value: notificationActionLabel(event.actionType),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RuleSummaryRow(
          icon: notificationAudienceIcon(event.audienceType),
          label: 'Audiencia',
          value: notificationAudienceLabel(event.audienceType),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Vigencia',
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppTypography.displayFont,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RuleSummaryRow(
          icon: Icons.calendar_month_outlined,
          label: 'Inicio',
          value: notificationDateTimeLabel(event.startsAt),
        ),
        const SizedBox(height: AppSpacing.xs),
        _RuleSummaryRow(
          icon: Icons.event_busy_outlined,
          label: 'Final',
          value: event.endsAt == null
              ? 'Indeterminada'
              : notificationDateTimeLabel(event.endsAt!),
        ),
      ],
    );
  }
}

class _RuleSummaryRow extends StatelessWidget {
  const _RuleSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 76,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppTypography.displayFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
