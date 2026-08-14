import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/data/models/app_content_media.dart';
import '../../core/data/models/content_media_file_metadata.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_primary_button.dart';
import '../../shared/widgets/app_secondary_button.dart';
import '../../shared/widgets/app_logo.dart';
import 'content_item_media_display_policy.dart';
import 'content_media_presentation.dart';
import 'content_media_playback_selection.dart';
import 'content_playback_progress.dart';
import 'lesson_player_page.dart';
import 'models/content_item.dart';

class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final showsMediaStages = contentItemShowsMediaStages(item);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _DetailHero(item: item),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 128),
                      child: Column(
                        children: [
                          _StatsRow(item: item),
                          const SizedBox(height: 28),

                          Text(
                            item.description ??
                                'Un espacio para reconectar con tu cuerpo, tu mente y tu energía interior.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 28),

                          if (showsMediaStages &&
                              (item.uuidContentItem != null ||
                                  item.lessons != null)) ...[
                            const SizedBox(height: 18),
                            _ContentMediaList(
                              item: item,
                              showFallbackLessons: item.lessons != null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 26,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.descargable && item.uuidContentItem != null) ...[
                  _DownloadAction(item: item),
                  const SizedBox(height: 10),
                ],
                _ContentPlaybackAction(
                  item: item,
                  showsMediaStages: showsMediaStages,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadAction extends StatelessWidget {
  const _DownloadAction({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    if (!item.descargable || item.uuidContentItem == null) {
      return const SizedBox.shrink();
    }

    final downloadsController = AppDataScope.contentDownloads(context);
    final subscriptionController = AppDataScope.subscription(context);
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([
        downloadsController,
        subscriptionController,
      ]),
      builder: (context, _) {
        final contentUuid = item.uuidContentItem!;
        final downloaded = downloadsController.isContentDownloaded(contentUuid);
        final downloading = downloadsController.isContentDownloading(
          contentUuid,
        );

        if (!downloadsController.isSupported) {
          return const SizedBox.shrink();
        }

        if (!subscriptionController.hasDownloadAccess) {
          return Text(
            subscriptionController.hasPremiumAccess
                ? 'Tu suscripción actual no incluye descargas offline.'
                : 'Las descargas offline están disponibles con Premium.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
          );
        }

        if (downloading) {
          return _DownloadProgressLabel(
            progress: downloadsController.downloadProgressForContent(
              contentUuid,
            ),
          );
        }

        return AppSecondaryButton(
          label: downloaded ? 'Eliminar descarga' : 'Descargar',
          icon: downloaded
              ? Icons.delete_outline_rounded
              : Icons.download_outlined,
          height: 46,
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.surface,
          onPressed: () => downloaded
              ? _removeDownload(context, contentUuid)
              : _downloadContent(context, contentUuid),
        );
      },
    );
  }

  Future<void> _downloadContent(
    BuildContext context,
    String uuidContentItem,
  ) async {
    try {
      await AppDataScope.contentDownloads(context).downloadContent(
        uuidContentItem: uuidContentItem,
        descargable: item.descargable,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_downloadErrorMessage(error))));
    }
  }

  Future<void> _removeDownload(
    BuildContext context,
    String uuidContentItem,
  ) async {
    final controller = AppDataScope.contentDownloads(context);
    final media = controller.downloads
        .where((download) => download.uuidContentItem == uuidContentItem)
        .toList();
    for (final download in media) {
      await controller.removeDownload(
        uuidContentMedia: download.uuidContentMedia,
      );
    }
  }
}

class _DownloadProgressLabel extends StatelessWidget {
  const _DownloadProgressLabel({this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percentage = progress == null ? null : (progress! * 100).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage == null ? 'Descargando...' : 'Descargando $percentage%',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}

String _downloadErrorMessage(Object error) {
  if (error is StateError) {
    return error.message.toString();
  }
  return 'No se pudo descargar el contenido.';
}

class _ContentPlaybackAction extends StatelessWidget {
  const _ContentPlaybackAction({
    required this.item,
    required this.showsMediaStages,
  });

  final ContentItem item;
  final bool showsMediaStages;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userContentStatesController = AppDataScope.userContentStates(context);

    return AnimatedBuilder(
      animation: userContentStatesController,
      builder: (context, _) {
        final uuidContentItem = item.uuidContentItem?.trim();
        final state = uuidContentItem == null || uuidContentItem.isEmpty
            ? null
            : userContentStatesController.stateForContent(uuidContentItem);
        final summary = contentPlaybackProgressSummary(
          progresoPorcentaje: state?.progresoPorcentaje ?? 0,
          ultimaPosicionSegundos: state?.ultimaPosicionSegundos ?? 0,
          completado: state?.completado ?? false,
          showsMediaStages: showsMediaStages,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: summary.statusText == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey(summary.statusText),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PlaybackProgressPill(text: summary.statusText!),
                    ),
            ),
            AppPrimaryButton(
              label: summary.buttonLabel,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              labelStyle: const TextStyle(
                fontFamily: AppTypography.displayFont,
                fontWeight: FontWeight.w300,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonPlayerPage(item: item),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _PlaybackProgressPill extends StatelessWidget {
  const _PlaybackProgressPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.full,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final profileController = AppDataScope.currentProfile(context);
    final userContentStatesController = AppDataScope.userContentStates(context);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 430,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          profileController,
          userContentStatesController,
        ]),
        builder: (context, _) {
          final uuidProfile = profileController.profile?.uuidProfile;
          final uuidContentItem = item.uuidContentItem;
          final canFavorite = uuidProfile != null && uuidContentItem != null;
          final isFavorite = uuidContentItem == null
              ? item.isFavorite
              : userContentStatesController.isFavorite(uuidContentItem);

          return Stack(
            fit: StackFit.expand,
            children: [
              AppCoverImage(
                fallbackAsset: null,
                imagePath: item.imagePath,
                resolveImageUrl: AppDataScope.contentItems(
                  context,
                ).resolveCoverImageUrl,
                fallback: Container(
                  color: scheme.surface,
                  alignment: Alignment.center,
                  child: AppLogo(
                    width: 168,
                    light: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.18),
                      AppColors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppBackButton.overlay(
                            size: 48,
                            iconSize: 30,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          _HeroIcon(
                            icon: Icons.bookmark_border_rounded,
                            selectedIcon: Icons.bookmark_rounded,
                            isSelected: isFavorite,
                            enabled: canFavorite,
                            tooltip: isFavorite
                                ? 'Quitar de favoritos'
                                : 'Guardar en favoritos',
                            onTap: canFavorite
                                ? () {
                                    unawaited(
                                      _toggleFavorite(
                                        context,
                                        uuidProfile: uuidProfile,
                                        uuidContentItem: uuidContentItem,
                                        isFavorite: isFavorite,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.type.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context, {
    required String uuidProfile,
    required String uuidContentItem,
    required bool isFavorite,
  }) async {
    try {
      await AppDataScope.userContentStates(
        context,
      ).toggleFavorito(uuidProfile, uuidContentItem);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              isFavorite
                  ? 'Contenido eliminado de favoritos.'
                  : 'Contenido guardado en favoritos.',
            ),
          ),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No se pudo actualizar el favorito.'),
          ),
        );
    }
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({
    required this.icon,
    required this.tooltip,
    this.selectedIcon,
    this.isSelected = false,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final bool isSelected;
  final bool enabled;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentIcon = isSelected ? selectedIcon ?? icon : icon;

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      enabled: enabled,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Icon(
            currentIcon,
            key: ValueKey(currentIcon),
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(icon: Icons.spa_outlined, label: item.type),
        ),
        Expanded(
          child: _Stat(icon: Icons.schedule_rounded, label: item.duration),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: scheme.surface,
          child: Icon(icon, color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}

class _ContentMediaList extends StatefulWidget {
  const _ContentMediaList({
    required this.item,
    required this.showFallbackLessons,
  });

  final ContentItem item;
  final bool showFallbackLessons;

  @override
  State<_ContentMediaList> createState() => _ContentMediaListState();
}

class _ContentMediaListState extends State<_ContentMediaList> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    final uuidContentItem = widget.item.uuidContentItem;
    if (uuidContentItem != null && uuidContentItem.trim().isNotEmpty) {
      final mediaController = AppDataScope.contentMedia(context);
      mediaController.watchForContent(uuidContentItem);
      unawaited(mediaController.pullFromRemote());
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaController = AppDataScope.contentMedia(context);

    return AnimatedBuilder(
      animation: mediaController,
      builder: (context, _) {
        final media = playableContentMediaItems(mediaController.items);
        if (media.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Etapas del curso',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in media)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LessonPlayerPage(
                        item: widget.item,
                        initialMediaUuid: item.uuidContentMedia,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(
                      _mediaIcon(item),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(_mediaTitle(item)),
                  subtitle: Text(_mediaSubtitle(item)),
                ),
            ],
          );
        }

        if (!widget.showFallbackLessons) {
          return const SizedBox.shrink();
        }

        return _FallbackLessonList(item: widget.item);
      },
    );
  }
}

class _FallbackLessonList extends StatelessWidget {
  const _FallbackLessonList({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final lessons = [
      'Bienvenida e intención',
      'Respiración consciente',
      'Soltar para descansar',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Etapas del curso', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (var i = 0; i < lessons.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: AppRadius.small,
              child: Image.asset(
                item.imageAsset,
                width: 72,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(lessons[i]),
            subtitle: Text('${8 + i * 4}:30 min'),
          ),
      ],
    );
  }
}

String _mediaTitle(AppContentMedia item) {
  final title = item.titulo?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }

  return contentMediaKindLabel(item.tipo);
}

String _mediaSubtitle(AppContentMedia item) {
  return contentMediaSubtitle(item);
}

IconData _mediaIcon(AppContentMedia item) {
  final cleanType = item.tipo.trim().toLowerCase();
  if (ContentMediaFileMetadata.isVideoType(cleanType)) {
    return Icons.videocam_outlined;
  }

  return switch (cleanType) {
    'video' => Icons.videocam_outlined,
    'ambient_sound' => Icons.graphic_eq_rounded,
    _ => Icons.graphic_eq_rounded,
  };
}
