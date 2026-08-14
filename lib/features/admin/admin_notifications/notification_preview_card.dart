import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_logo.dart';
import 'notification_admin_labels.dart';

class AdminNotificationPreviewCard extends StatelessWidget {
  const AdminNotificationPreviewCard({
    super.key,
    required this.title,
    required this.body,
    this.internalName,
    this.audienceType,
    this.triggerType,
    this.triggerKey,
  });

  final String title;
  final String body;
  final String? internalName;
  final String? audienceType;
  final String? triggerType;
  final String? triggerKey;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista previa',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppTypography.displayFont,
            ),
          ),
          const SizedBox(height: 14),
          AdminNotificationPushPreview(
            internalName: internalName,
            title: title,
            body: body,
            audienceType: audienceType,
            triggerType: triggerType,
            triggerKey: triggerKey,
          ),
        ],
      ),
    );
  }
}

class AdminNotificationPushPreview extends StatelessWidget {
  const AdminNotificationPushPreview({
    super.key,
    this.internalName,
    required this.title,
    required this.body,
    this.audienceType,
    this.triggerType,
    this.triggerKey,
  });

  final String? internalName;
  final String title;
  final String body;
  final String? audienceType;
  final String? triggerType;
  final String? triggerKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasRules = audienceType != null || triggerType != null;
    final cleanName = internalName?.trim() ?? '';
    final cleanTitle = title.trim().isEmpty
        ? 'Título de la notificación'
        : title.trim();
    final cleanBody = body.trim().isEmpty
        ? 'Aquí aparecerá tu mensaje.'
        : body.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cleanName.isNotEmpty) ...[
          Text(
            cleanName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: AppTypography.displayFont,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const AppLogo(compact: true, width: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleanTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: AppTypography.displayFont,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(cleanBody, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        if (hasRules) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (audienceType != null)
                _NotificationPreviewChip(
                  label: notificationAudienceLabel(audienceType!),
                ),
              if (triggerType != null)
                _NotificationPreviewChip(
                  label: notificationTriggerTypeLabel(triggerType!),
                ),
              if (triggerType != null)
                _NotificationPreviewChip(
                  label: triggerKey == null || triggerKey!.trim().isEmpty
                      ? 'Manual'
                      : notificationTriggerKeyLabel(triggerKey!),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NotificationPreviewChip extends StatelessWidget {
  const _NotificationPreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.09),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontFamily: AppTypography.displayFont),
      ),
    );
  }
}
