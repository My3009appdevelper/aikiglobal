import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/data/models/app_content_media.dart';
import '../../core/data/models/content_media_file_metadata.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_primary_button.dart';
import '../../shared/widgets/app_logo.dart';
import 'content_media_playback_selection.dart';
import 'lesson_player_page.dart';
import 'models/content_item.dart';

class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final isCourse = item.lessons != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          Text(
                            item.description ??
                                'Un espacio para reconectar con tu cuerpo, tu mente y tu energía interior.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 28),
                          _StatsRow(item: item),
                          const SizedBox(height: 28),
                          _AboutCard(item: item),
                          if (item.uuidContentItem != null || isCourse) ...[
                            const SizedBox(height: 18),
                            _ContentMediaList(
                              item: item,
                              showFallbackLessons: isCourse,
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
            child: AppPrimaryButton(
              label: isCourse ? 'Comenzar curso' : 'Reproducir ahora',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonPlayerPage(item: item),
                  ),
                );
              },
            ),
          ),
        ],
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : AppColors.sandLight,
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
                          _HeroIcon(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Regresar',
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
                            ?.copyWith(color: AppColors.sand),
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
        Expanded(
          child: _Stat(
            icon: Icons.signal_cellular_alt_rounded,
            label: item.lessons == null
                ? 'Audio guía'
                : '${item.lessons} clases',
          ),
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
    final brightness = Theme.of(context).brightness;
    final circleColor = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final iconColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: circleColor,
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final iconSurface = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconSurface,
            child: Icon(
              Icons.local_florist_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre este contenido',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  item.description ??
                      'Diseñado para acompañarte con calma, presencia y claridad.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
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
            children: [
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
      children: [
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

  return _mediaTypeLabel(item.tipo);
}

String _mediaSubtitle(AppContentMedia item) {
  return '${_mediaTypeLabel(item.tipo)} · ${_formatMediaDuration(item.duracionSegundos)}';
}

String _mediaTypeLabel(String tipo) {
  final cleanType = tipo.trim().toLowerCase();
  if (ContentMediaFileMetadata.isSupportedType(cleanType)) {
    return cleanType.toUpperCase();
  }

  return switch (cleanType) {
    'video' => 'Video',
    'audio' => 'Audio',
    'ambient_sound' => 'Sonido ambiental',
    _ => tipo,
  };
}

IconData _mediaIcon(AppContentMedia item) {
  final cleanType = item.tipo.trim().toLowerCase();
  if (ContentMediaFileMetadata.isVideoType(cleanType)) {
    return Icons.videocam_outlined;
  }

  return switch (cleanType) {
    'video' => Icons.videocam_outlined,
    'ambient_sound' => Icons.graphic_eq_rounded,
    _ => Icons.mic_none_rounded,
  };
}

String _formatMediaDuration(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return 'Duración pendiente';
  }

  final totalMinutes = (seconds / 60).round();
  if (totalMinutes < 60) {
    return '$totalMinutes min';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}
