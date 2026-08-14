import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_item.dart';
import '../../core/data/models/app_notification_inbox_item.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/notifications_inbox_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/app_responsive_container.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationsInboxController? _controller;
  bool _initialized = false;
  bool _markingAll = false;
  String? _openingUuid;
  Map<String, AppContentItem> _contentByUuid = const {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    _controller = AppDataScope.notificationsInbox(context);
    final profileUuid = AppDataScope.currentProfile(
      context,
    ).profile?.uuidProfile;
    if (profileUuid != null && _controller?.activeProfileUuid != profileUuid) {
      _controller?.watchForProfile(profileUuid);
    }
    unawaited(_loadContent());
  }

  Future<void> _loadContent({bool pullRemote = false}) async {
    final controller = AppDataScope.contentItems(context);
    if (pullRemote) {
      await controller.syncWithRemote();
    }
    final items = await controller.getPublishedSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _contentByUuid = {for (final item in items) item.uuidContentItem: item};
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      _controller?.syncWithRemote() ?? Future<void>.value(),
      _loadContent(pullRemote: true),
    ]);
  }

  Future<void> _markAllRead() async {
    if (_markingAll || (_controller?.unreadCount ?? 0) == 0) {
      return;
    }
    setState(() => _markingAll = true);
    try {
      await _controller?.markAllRead();
    } finally {
      if (mounted) {
        setState(() => _markingAll = false);
      }
    }
  }

  Future<void> _open(AppNotificationInboxItem item) async {
    if (_openingUuid != null) {
      return;
    }
    setState(() => _openingUuid = item.uuidNotificationInbox);
    try {
      final opened = await _controller?.openNotification(
        item.uuidNotificationInbox,
      );
      if (!mounted) {
        return;
      }
      if (opened == null ||
          !AppDataScope.notificationNavigation(context).openInboxItem(opened)) {
        _showMessage('No se pudo abrir esta notificación.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo abrir esta notificación.');
      }
    } finally {
      if (mounted) {
        setState(() => _openingUuid = null);
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

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      body: AppBackground(
        imageAsset: AppAssets.backgroundGarden,
        imageOpacity: 0.04,
        child: SafeArea(
          child: AppResponsiveContainer(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return AppRefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                AppBackButton(
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                                const Spacer(),
                                const AppLogo(width: 148),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notificaciones',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Mantente al día con tu bienestar.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                if (controller.unreadCount > 0)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _markingAll
                                          ? null
                                          : _markAllRead,
                                      icon: const Icon(Icons.done_all_rounded),
                                      label: const Text('Marcar todas'),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (controller.error != null)
                              _InboxMessage(
                                icon: Icons.cloud_off_outlined,
                                title: 'No se pudo actualizar el inbox',
                                body:
                                    'Mostramos las notificaciones guardadas en este dispositivo.',
                              )
                            else if (controller.notifications.isEmpty)
                              const _InboxMessage(
                                icon: Icons.notifications_none_rounded,
                                title: 'Aún no tienes notificaciones',
                                body: 'Los avisos importantes aparecerán aquí.',
                              )
                            else
                              ...controller.notifications.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: NotificationInboxTile(
                                    item: item,
                                    content: _contentFor(item),
                                    isOpening:
                                        _openingUuid ==
                                        item.uuidNotificationInbox,
                                    resolveImageUrl: AppDataScope.contentItems(
                                      context,
                                    ).resolveCoverImageUrl,
                                    onTap: () => _open(item),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppContentItem? _contentFor(AppNotificationInboxItem item) {
    if (item.actionType != 'open_content_item') {
      return null;
    }
    final uuid = item.actionPayload['uuid_content_item'];
    return uuid is String ? _contentByUuid[uuid] : null;
  }
}

class NotificationInboxTile extends StatelessWidget {
  const NotificationInboxTile({
    super.key,
    required this.item,
    required this.onTap,
    this.content,
    this.resolveImageUrl,
    this.isOpening = false,
  });

  final AppNotificationInboxItem item;
  final AppContentItem? content;
  final Future<String?> Function(String path)? resolveImageUrl;
  final VoidCallback onTap;
  final bool isOpening;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final stroke = item.isRead
        ? (brightness == Brightness.dark
              ? AppColors.darkStroke
              : AppColors.stroke)
        : scheme.primary.withValues(alpha: 0.55);
    final coverPath = _contentCoverPath(content);
    return AppInteractive(
      tooltip: 'Abrir notificación',
      borderRadius: AppRadius.large,
      hoverScale: 1.012,
      onTap: isOpening ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: stroke, width: item.isRead ? 1 : 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: Icon(_categoryIcon(item.category), size: 23),
                ),
                if (!item.isRead)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: scheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: AppTypography.displayFont,
                      fontWeight: item.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _dateTimeLabel(item.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (coverPath != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: AppRadius.small,
                child: SizedBox.square(
                  dimension: 72,
                  child: AppCoverImage(
                    imagePath: coverPath,
                    resolveImageUrl: resolveImageUrl,
                    fallback: ColoredBox(
                      color: scheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.spa_outlined, color: scheme.primary),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              isOpening
                  ? Icons.hourglass_top_rounded
                  : Icons.chevron_right_rounded,
              color: scheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxMessage extends StatelessWidget {
  const _InboxMessage({
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
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
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
      ),
    );
  }
}

IconData _categoryIcon(String category) => switch (category) {
  'content' => Icons.play_circle_outline_rounded,
  'events' => Icons.event_outlined,
  'schedule_changes' => Icons.schedule_rounded,
  'admin' => Icons.admin_panel_settings_outlined,
  _ => Icons.notifications_none_rounded,
};

String? _contentCoverPath(AppContentItem? item) {
  if (item == null) {
    return null;
  }
  final local = item.coverPathLocal?.trim();
  if (local != null && local.isNotEmpty) {
    return local;
  }
  final remote = item.coverPathSupabase?.trim();
  return remote == null || remote.isEmpty ? null : remote;
}

String _dateTimeLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} · '
      '${two(local.hour)}:${two(local.minute)}';
}
