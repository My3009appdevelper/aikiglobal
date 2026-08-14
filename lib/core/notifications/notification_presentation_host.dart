import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/widgets/app_tertiary_button.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'notification_payload_codec.dart';

class NotificationPresentationHost extends StatefulWidget {
  const NotificationPresentationHost({
    super.key,
    required this.presentations,
    required this.scaffoldMessengerKey,
    required this.onOpen,
    required this.child,
    this.autoDismissDuration = const Duration(seconds: 8),
  });

  final Stream<NotificationPayload> presentations;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Future<void> Function(NotificationPayload payload) onOpen;
  final Duration autoDismissDuration;
  final Widget child;

  @override
  State<NotificationPresentationHost> createState() =>
      _NotificationPresentationHostState();
}

class _NotificationPresentationHostState
    extends State<NotificationPresentationHost> {
  StreamSubscription<NotificationPayload>? _subscription;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(NotificationPresentationHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presentations != widget.presentations) {
      unawaited(_subscription?.cancel());
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.presentations.listen(_showPresentation);
  }

  void _showPresentation(NotificationPayload payload) {
    _dismissTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messenger = widget.scaffoldMessengerKey.currentState;
      if (messenger == null) {
        return;
      }

      messenger
        ..hideCurrentMaterialBanner()
        ..showMaterialBanner(
          _buildBanner(
            messenger.context,
            payload,
            onOpen: () {
              _dismissTimer?.cancel();
              messenger.hideCurrentMaterialBanner();
              unawaited(widget.onOpen(payload));
            },
            onDismiss: () {
              _dismissTimer?.cancel();
              messenger.hideCurrentMaterialBanner();
            },
          ),
        );

      _dismissTimer = Timer(widget.autoDismissDuration, () {
        widget.scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
      });
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

MaterialBanner _buildBanner(
  BuildContext context,
  NotificationPayload payload, {
  required VoidCallback onOpen,
  required VoidCallback onDismiss,
}) {
  final scheme = Theme.of(context).colorScheme;
  final title = payload.title;
  final body = payload.body;

  return MaterialBanner(
    backgroundColor: scheme.surfaceContainerHigh,
    elevation: 2,
    leading: Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.14),
        borderRadius: AppRadius.small,
      ),
      child: Icon(Icons.notifications_none_rounded, color: scheme.primary),
    ),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('AIKI', style: Theme.of(context).textTheme.labelMedium),
        if (title != null && title.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
        if (body != null && body.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    ),
    actions: [
      IconButton(
        onPressed: onDismiss,
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Cerrar',
      ),
      AppTertiaryButton(
        label: 'Abrir',
        icon: Icons.arrow_forward_rounded,
        height: 38,
        onPressed: onOpen,
      ),
    ],
  );
}
