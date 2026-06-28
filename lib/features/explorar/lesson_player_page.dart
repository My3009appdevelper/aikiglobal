import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/data/models/app_content_media.dart';
import '../../core/data/models/content_media_file_metadata.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/content_media_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import 'content_media_playback_selection.dart';
import 'models/content_item.dart';

class LessonPlayerPage extends StatefulWidget {
  const LessonPlayerPage({
    super.key,
    required this.item,
    this.initialMediaUuid,
  });

  final ContentItem item;
  final String? initialMediaUuid;

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  ContentMediaController? _mediaController;
  VideoPlayerController? _videoController;
  AppContentMedia? _selectedMedia;
  String? _requestedMediaUuid;
  bool _initialized = false;
  bool _isPreparing = false;
  Object? _playbackError;
  int _prepareGeneration = 0;
  bool _initialPlaybackRequested = false;

  @override
  void initState() {
    super.initState();
    _requestedMediaUuid = widget.initialMediaUuid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = AppDataScope.contentMedia(context);
    if (_mediaController != nextController) {
      _mediaController?.removeListener(_handleMediaControllerChanged);
      _mediaController = nextController;
      nextController.addListener(_handleMediaControllerChanged);
    }

    if (_initialized) {
      return;
    }

    _initialized = true;
    final uuidContentItem = widget.item.uuidContentItem;
    if (uuidContentItem != null && uuidContentItem.trim().isNotEmpty) {
      nextController.watchForContent(uuidContentItem);
      unawaited(nextController.pullFromRemote());
    }
    unawaited(_syncSelectedMedia(autoPlay: true));
  }

  @override
  void dispose() {
    _prepareGeneration++;
    _mediaController?.removeListener(_handleMediaControllerChanged);
    final controller = _videoController;
    if (controller != null) {
      controller.removeListener(_handleVideoChanged);
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  void _handleMediaControllerChanged() {
    unawaited(_syncSelectedMedia(autoPlay: !_initialPlaybackRequested));
    if (mounted) {
      setState(() {});
    }
  }

  void _handleVideoChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _syncSelectedMedia({required bool autoPlay}) async {
    final controller = _mediaController;
    if (controller == null) {
      return;
    }

    final selected = selectPlayableContentMedia(
      controller.items,
      selectedMediaUuid:
          _requestedMediaUuid ?? _selectedMedia?.uuidContentMedia,
    );

    if (selected == null) {
      await _clearPlayback();
      return;
    }

    if (_selectedMedia?.uuidContentMedia == selected.uuidContentMedia &&
        _videoController != null) {
      return;
    }

    await _prepareMedia(selected, autoPlay: autoPlay);
  }

  Future<void> _clearPlayback() async {
    _prepareGeneration++;
    await _disposeVideoController();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedMedia = null;
      _isPreparing = false;
      _playbackError = null;
    });
  }

  Future<void> _prepareMedia(
    AppContentMedia media, {
    required bool autoPlay,
  }) async {
    final generation = ++_prepareGeneration;
    if (autoPlay) {
      _initialPlaybackRequested = true;
    }

    setState(() {
      _selectedMedia = media;
      _isPreparing = true;
      _playbackError = null;
    });

    await _disposeVideoController();

    VideoPlayerController? nextVideoController;
    try {
      final signedUrl = await _mediaController?.resolveMediaUrl(
        media.storagePathSupabase,
      );
      if (!mounted || generation != _prepareGeneration) {
        return;
      }
      if (signedUrl == null || signedUrl.trim().isEmpty) {
        throw StateError('No se pudo preparar este archivo.');
      }

      nextVideoController = VideoPlayerController.networkUrl(
        Uri.parse(signedUrl),
      );
      await nextVideoController.initialize();
      nextVideoController.addListener(_handleVideoChanged);
      if (autoPlay) {
        await nextVideoController.play();
      }

      if (!mounted || generation != _prepareGeneration) {
        nextVideoController.removeListener(_handleVideoChanged);
        await nextVideoController.dispose();
        return;
      }

      setState(() {
        _videoController = nextVideoController;
        _isPreparing = false;
      });
    } catch (error) {
      nextVideoController?.removeListener(_handleVideoChanged);
      await nextVideoController?.dispose();
      if (!mounted || generation != _prepareGeneration) {
        return;
      }
      setState(() {
        _isPreparing = false;
        _playbackError = error;
      });
    }
  }

  Future<void> _disposeVideoController() async {
    final controller = _videoController;
    if (controller == null) {
      return;
    }

    controller.removeListener(_handleVideoChanged);
    _videoController = null;
    await controller.dispose();
  }

  Future<void> _selectMedia(AppContentMedia media) async {
    _requestedMediaUuid = media.uuidContentMedia;
    await _prepareMedia(media, autoPlay: true);
  }

  Future<void> _playAdjacent(int direction) async {
    final items = playableContentMediaItems(
      _mediaController?.items ?? const [],
    );
    final selectedUuid = _selectedMedia?.uuidContentMedia;
    final index = items.indexWhere(
      (item) => item.uuidContentMedia == selectedUuid,
    );
    final nextIndex = index + direction;
    if (index < 0 || nextIndex < 0 || nextIndex >= items.length) {
      return;
    }

    await _selectMedia(items[nextIndex]);
  }

  Future<void> _togglePlayback() async {
    if (_isPreparing) {
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      final selected = _selectedMedia;
      if (selected != null) {
        await _prepareMedia(selected, autoPlay: true);
      }
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
  }

  Future<void> _seekRelative(Duration offset) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final duration = controller.value.duration;
    final targetMs = (controller.value.position + offset).inMilliseconds.clamp(
      0,
      duration.inMilliseconds,
    );
    await controller.seekTo(Duration(milliseconds: targetMs));
  }

  Future<void> _seekTo(Duration position) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    await controller.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.colorScheme.onSurface;
    final bodyColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;
    final mediaController = _mediaController;
    final mediaItems = playableContentMediaItems(
      mediaController?.items ?? const [],
    );
    final selectedMedia =
        _selectedMedia ??
        selectPlayableContentMedia(
          mediaItems,
          selectedMediaUuid: _requestedMediaUuid,
        );
    final selectedIndex = selectedMedia == null
        ? -1
        : mediaItems.indexWhere(
            (item) => item.uuidContentMedia == selectedMedia.uuidContentMedia,
          );
    final videoController = _videoController;
    final canControl =
        videoController != null &&
        videoController.value.isInitialized &&
        !_isPreparing;
    final isLoadingMedia =
        (mediaController?.isLoading ?? false) ||
        (mediaController?.isSyncing ?? false);
    final displayTitle = selectedMedia == null
        ? widget.item.title
        : _mediaTitle(selectedMedia);
    final mediaLabel = selectedMedia == null || selectedIndex < 0
        ? widget.item.type.toUpperCase()
        : 'ARCHIVO ${selectedIndex + 1} DE ${mediaItems.length}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _CircleIcon(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Regresar',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const AppLogo(width: 132),
                    const Spacer(),
                    const _CircleIcon(
                      icon: Icons.more_horiz_rounded,
                      tooltip: 'Más opciones',
                    ),
                  ],
                ),
              ),
              _PlaybackStage(
                item: widget.item,
                selectedMedia: selectedMedia,
                controller: videoController,
                isPreparing: _isPreparing,
                isLoadingMedia: isLoadingMedia,
                playbackError: _playbackError,
                onPlayPause: _togglePlayback,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mediaLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.item.description ??
                          'Una práctica para revitalizar tu cuerpo y mente. Conecta contigo y eleva tu vitalidad.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: bodyColor),
                    ),
                    const SizedBox(height: 24),
                    _PlaybackProgress(
                      controller: videoController,
                      enabled: canControl,
                      onChanged: _seekTo,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PlayerIconButton(
                          Icons.skip_previous_rounded,
                          tooltip: 'Archivo anterior',
                          enabled: selectedIndex > 0,
                          onTap: () => unawaited(_playAdjacent(-1)),
                        ),
                        _PlayerIconButton(
                          Icons.replay_10_rounded,
                          tooltip: 'Retroceder 10 segundos',
                          enabled: canControl,
                          onTap: () => unawaited(
                            _seekRelative(const Duration(seconds: -10)),
                          ),
                        ),
                        _LargePlayButton(
                          isPlaying: videoController?.value.isPlaying ?? false,
                          isLoading: _isPreparing,
                          enabled: selectedMedia != null && !_isPreparing,
                          onTap: () => unawaited(_togglePlayback()),
                        ),
                        _PlayerIconButton(
                          Icons.forward_10_rounded,
                          tooltip: 'Adelantar 10 segundos',
                          enabled: canControl,
                          onTap: () => unawaited(
                            _seekRelative(const Duration(seconds: 10)),
                          ),
                        ),
                        _PlayerIconButton(
                          Icons.skip_next_rounded,
                          tooltip: 'Siguiente archivo',
                          enabled:
                              selectedIndex >= 0 &&
                              selectedIndex < mediaItems.length - 1,
                          onTap: () => unawaited(_playAdjacent(1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    _PlayerMediaList(
                      items: mediaItems,
                      selectedMediaUuid: selectedMedia?.uuidContentMedia,
                      isLoading: isLoadingMedia,
                      onSelected: (item) => unawaited(_selectMedia(item)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybackStage extends StatelessWidget {
  const _PlaybackStage({
    required this.item,
    required this.selectedMedia,
    required this.controller,
    required this.isPreparing,
    required this.isLoadingMedia,
    required this.playbackError,
    required this.onPlayPause,
  });

  final ContentItem item;
  final AppContentMedia? selectedMedia;
  final VideoPlayerController? controller;
  final bool isPreparing;
  final bool isLoadingMedia;
  final Object? playbackError;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final videoController = controller;
    final canShowVideo =
        videoController != null &&
        videoController.value.isInitialized &&
        _isVideoMedia(selectedMedia);
    final isPlaying = videoController?.value.isPlaying ?? false;

    return AspectRatio(
      aspectRatio: 1.05,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (canShowVideo)
            ColoredBox(
              color: AppColors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            )
          else
            AppCoverImage(
              fallbackAsset: null,
              imagePath: item.imagePath,
              resolveImageUrl: AppDataScope.contentItems(
                context,
              ).resolveCoverImageUrl,
              fallback: Container(
                color: isDark ? AppColors.darkSurface : AppColors.sandLight,
                alignment: Alignment.center,
                child: AppLogo(width: 146, light: isDark),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.transparent,
                  AppColors.black.withValues(alpha: isDark ? 0.65 : 0.35),
                ],
              ),
            ),
          ),
          Center(
            child: AppInteractive(
              tooltip: isPlaying ? 'Pausar' : 'Reproducir',
              borderRadius: AppRadius.full,
              enabled: selectedMedia != null && !isPreparing,
              onTap: onPlayPause,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: isPreparing || (isLoadingMedia && selectedMedia == null)
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 56,
                      ),
              ),
            ),
          ),
          if (selectedMedia != null && !_isVideoMedia(selectedMedia))
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      _mediaIcon(selectedMedia!),
                      color: AppColors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _mediaTypeLabel(selectedMedia!.tipo),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (playbackError != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: AppColors.black.withValues(alpha: 0.46),
                child: Text(
                  'No se pudo reproducir este archivo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaybackProgress extends StatelessWidget {
  const _PlaybackProgress({
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final VideoPlayerController? controller;
  final bool enabled;
  final ValueChanged<Duration> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = controller?.value;
    final duration = value?.duration ?? Duration.zero;
    final position = value?.position ?? Duration.zero;
    final maxMilliseconds = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final currentMilliseconds = position.inMilliseconds
        .clamp(0, maxMilliseconds.toInt())
        .toDouble();

    return Column(
      children: [
        Slider(
          value: currentMilliseconds,
          max: maxMilliseconds,
          onChanged: enabled
              ? (value) => onChanged(Duration(milliseconds: value.round()))
              : null,
        ),
        Row(
          children: [
            Text(
              _formatClock(position),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              _formatClock(duration),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerMediaList extends StatelessWidget {
  const _PlayerMediaList({
    required this.items,
    required this.selectedMediaUuid,
    required this.isLoading,
    required this.onSelected,
  });

  final List<AppContentMedia> items;
  final String? selectedMediaUuid;
  final bool isLoading;
  final ValueChanged<AppContentMedia> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _PlayerStatusMessage(
        text: isLoading
            ? 'Cargando archivos...'
            : 'No hay archivos disponibles para este contenido.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Archivos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlayerMediaTile(
              item: item,
              isSelected: item.uuidContentMedia == selectedMediaUuid,
              onTap: () => onSelected(item),
            ),
          ),
      ],
    );
  }
}

class _PlayerStatusMessage extends StatelessWidget {
  const _PlayerStatusMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.white.withValues(alpha: 0.94);
    final stroke = isDark ? AppColors.darkStroke : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: stroke),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _PlayerMediaTile extends StatelessWidget {
  const _PlayerMediaTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppContentMedia item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isSelected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
        : isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.white.withValues(alpha: 0.94);
    final stroke = isSelected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.42)
        : isDark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return AppInteractive(
      tooltip: 'Reproducir archivo',
      borderRadius: AppRadius.medium,
      hoverScale: 1.01,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: stroke),
        ),
        child: Row(
          children: [
            Icon(
              _mediaIcon(item),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mediaTitle(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_mediaTypeLabel(item.tipo)} · ${_formatMediaDuration(item.duracionSegundos)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.equalizer_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.black.withValues(alpha: 0.25)
        : AppColors.sandLight.withValues(alpha: 0.95);
    final iconColor = isDark ? AppColors.white : AppColors.primaryDeep;

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap ?? () {},
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton(
    this.icon, {
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? AppColors.white
        : AppColors.primaryDeep;

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      enabled: enabled,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap,
      child: SizedBox.square(
        dimension: 46,
        child: Icon(
          icon,
          color: enabled ? color : color.withValues(alpha: 0.32),
          size: 34,
        ),
      ),
    );
  }
}

class _LargePlayButton extends StatelessWidget {
  const _LargePlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.enabled,
    required this.onTap,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppInteractive(
      tooltip: isPlaying ? 'Pausar' : 'Reproducir',
      borderRadius: AppRadius.full,
      enabled: enabled,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap,
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: enabled
              ? scheme.primary
              : scheme.primary.withValues(alpha: 0.38),
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(26),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: scheme.onPrimary,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: scheme.onPrimary,
                size: 48,
              ),
      ),
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

String _formatClock(Duration value) {
  final totalSeconds = value.inSeconds;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

bool _isVideoMedia(AppContentMedia? item) {
  if (item == null) {
    return false;
  }
  return ContentMediaFileMetadata.isVideoType(item.tipo);
}
