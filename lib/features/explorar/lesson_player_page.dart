import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../core/data/models/app_content_media.dart';
import '../../core/data/models/app_user_content_state.dart';
import '../../core/data/models/content_media_file_metadata.dart';
import '../../core/data/media/content_media_playback_source.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/content_media_controller.dart';
import '../../core/data/providers/user_content_states_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import 'content_item_media_display_policy.dart';
import 'content_media_playback_selection.dart';
import 'content_media_presentation.dart';
import 'content_playback_progress.dart';
import 'models/content_item.dart';
import 'player_autoplay_policy.dart';
import 'player_seek_position.dart';
import 'player_stage_controls_visibility.dart';

const _playerControlsAutoHideDelay = Duration(seconds: 2);
const _playbackProgressSaveInterval = Duration(seconds: 10);

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
  UserContentStatesController? _userContentStatesController;
  VideoPlayerController? _videoController;
  AppContentMedia? _selectedMedia;
  String? _requestedMediaUuid;
  String? _activeProfileUuid;
  bool _initialized = false;
  bool _isPreparing = false;
  Object? _playbackError;
  int _prepareGeneration = 0;
  bool _initialPlaybackRequested = false;
  bool _stageControlsRequested = true;
  bool _audioScreenDarkened = false;
  bool _resumeSeekApplied = false;
  bool _completionSaved = false;
  bool _isClosing = false;
  int? _lastSavedProgressSecond;
  Timer? _stageControlsAutoHideTimer;

  @override
  void initState() {
    super.initState();
    _requestedMediaUuid = widget.initialMediaUuid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = AppDataScope.contentMedia(context);
    final nextUserContentStatesController = AppDataScope.userContentStates(
      context,
    );
    _activeProfileUuid = AppDataScope.currentProfile(
      context,
    ).profile?.uuidProfile;

    if (_userContentStatesController != nextUserContentStatesController) {
      _userContentStatesController?.removeListener(
        _handleUserContentStatesChanged,
      );
      _userContentStatesController = nextUserContentStatesController;
      nextUserContentStatesController.addListener(
        _handleUserContentStatesChanged,
      );
    }

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
    if (_audioScreenDarkened) {
      _setAudioDarkSystemUi(false);
    }
    _prepareGeneration++;
    _stageControlsAutoHideTimer?.cancel();
    unawaited(_savePlaybackProgress(force: true));
    _userContentStatesController?.removeListener(
      _handleUserContentStatesChanged,
    );
    _mediaController?.removeListener(_handleMediaControllerChanged);
    final controller = _videoController;
    if (controller != null) {
      controller.removeListener(_handleVideoChanged);
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  void _handleMediaControllerChanged() {
    unawaited(
      _syncSelectedMedia(
        autoPlay: shouldRequestAutoplayOnMediaSync(
          initialAutoplayConsumed: _initialPlaybackRequested,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _handleUserContentStatesChanged() {
    unawaited(_applySavedPlaybackPositionIfNeeded());
  }

  String? get _uuidContentItem {
    final uuidContentItem = widget.item.uuidContentItem?.trim();
    return uuidContentItem == null || uuidContentItem.isEmpty
        ? null
        : uuidContentItem;
  }

  AppUserContentState? get _currentContentState {
    final uuidContentItem = _uuidContentItem;
    if (uuidContentItem == null) {
      return null;
    }

    return _userContentStatesController?.stateForContent(uuidContentItem);
  }

  bool get _canTrackPlaybackProgress {
    final uuidProfile = _activeProfileUuid?.trim();
    final uuidContentItem = _uuidContentItem;
    return _userContentStatesController != null &&
        uuidProfile != null &&
        uuidProfile.isNotEmpty &&
        uuidContentItem != null &&
        uuidContentItem.isNotEmpty;
  }

  Future<void> _applySavedPlaybackPositionIfNeeded() async {
    if (_resumeSeekApplied) {
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying || controller.value.position.inSeconds > 0) {
      _resumeSeekApplied = true;
      return;
    }

    final state = _currentContentState;
    if (state == null ||
        state.completado ||
        state.ultimaPosicionSegundos <= 0) {
      return;
    }

    final duration = controller.value.duration;
    if (duration.inSeconds <= 1) {
      return;
    }

    final maxSecond = duration.inSeconds - 1;
    final targetSeconds = state.ultimaPosicionSegundos
        .clamp(0, maxSecond)
        .toInt();
    if (targetSeconds <= 0) {
      return;
    }

    _resumeSeekApplied = true;
    _lastSavedProgressSecond = targetSeconds;
    await controller.seekTo(Duration(seconds: targetSeconds));
  }

  Future<void> _savePlaybackProgress({required bool force}) async {
    if (!_canTrackPlaybackProgress) {
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final value = controller.value;
    final position = value.position;
    final duration = value.duration;
    if (duration.inMilliseconds <= 0 || position.inSeconds <= 0) {
      return;
    }

    if (shouldMarkPlaybackCompleted(position: position, duration: duration)) {
      await _markPlaybackCompleted();
      return;
    }

    if (!force &&
        !shouldSavePlaybackProgress(
          position: position,
          lastSavedPositionSeconds: _lastSavedProgressSecond,
          interval: _playbackProgressSaveInterval,
        )) {
      return;
    }

    final uuidProfile = _activeProfileUuid?.trim();
    final uuidContentItem = _uuidContentItem;
    final controllerStates = _userContentStatesController;
    if (uuidProfile == null ||
        uuidProfile.isEmpty ||
        uuidContentItem == null ||
        controllerStates == null) {
      return;
    }

    _lastSavedProgressSecond = position.inSeconds;
    await controllerStates.updateProgress(
      uuidProfile,
      uuidContentItem,
      playbackProgressPercentage(position: position, duration: duration),
      position.inSeconds,
    );
    if (playbackProgressPercentage(position: position, duration: duration) <
        100) {
      _completionSaved = false;
    }
  }

  Future<void> _markPlaybackCompleted() async {
    if (_completionSaved || !_canTrackPlaybackProgress) {
      return;
    }

    final state = _currentContentState;
    if (state?.completado ?? false) {
      _completionSaved = true;
      return;
    }

    final uuidProfile = _activeProfileUuid?.trim();
    final uuidContentItem = _uuidContentItem;
    final controllerStates = _userContentStatesController;
    if (uuidProfile == null ||
        uuidProfile.isEmpty ||
        uuidContentItem == null ||
        controllerStates == null) {
      return;
    }

    _completionSaved = true;
    final value = _videoController?.value;
    final position = value == null
        ? null
        : value.duration.inSeconds > 0
        ? value.duration.inSeconds
        : value.position.inSeconds;
    if (position != null && position > 0) {
      _lastSavedProgressSecond = position;
    }
    await controllerStates.markCompleted(
      uuidProfile,
      uuidContentItem,
      ultimaPosicionSegundos: position,
    );
  }

  void _handleVideoChanged() {
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      final value = controller.value;
      if (shouldMarkPlaybackCompleted(
        position: value.position,
        duration: value.duration,
      )) {
        unawaited(_markPlaybackCompleted());
      } else if (value.isPlaying) {
        unawaited(_savePlaybackProgress(force: false));
      }
    }

    if (mounted) {
      final shouldRevealControls =
          !_stageControlsRequested &&
          (controller == null ||
              !controller.value.isInitialized ||
              !controller.value.isPlaying);
      setState(() {
        if (shouldRevealControls) {
          _stageControlsRequested = true;
        }
      });
    }
  }

  void _showStageControls({required bool autoHide}) {
    _stageControlsAutoHideTimer?.cancel();
    if (!mounted) {
      _stageControlsRequested = true;
      return;
    }

    if (!_stageControlsRequested) {
      setState(() {
        _stageControlsRequested = true;
      });
    }

    if (autoHide) {
      _scheduleStageControlsAutoHide();
    }
  }

  void _hideStageControls() {
    _stageControlsAutoHideTimer?.cancel();
    if (!mounted || !_stageControlsRequested) {
      return;
    }

    setState(() {
      _stageControlsRequested = false;
    });
  }

  void _scheduleStageControlsAutoHide() {
    _stageControlsAutoHideTimer?.cancel();
    final controller = _videoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isPlaying ||
        _isPreparing ||
        _playbackError != null) {
      return;
    }

    _stageControlsAutoHideTimer = Timer(_playerControlsAutoHideDelay, () {
      if (!mounted) {
        return;
      }

      final controller = _videoController;
      if (controller == null ||
          !controller.value.isInitialized ||
          !controller.value.isPlaying ||
          _isPreparing ||
          _playbackError != null) {
        return;
      }

      setState(() {
        _stageControlsRequested = false;
      });
    });
  }

  void _handleStageTap() {
    final isPlaying = _videoController?.value.isPlaying ?? false;
    if (_stageControlsRequested && isPlaying) {
      _hideStageControls();
      return;
    }

    _showStageControls(autoHide: isPlaying);
  }

  void _enableAudioDarkScreen() {
    if (!contentItemSupportsAudioDarkScreen(
      widget.item,
      selectedMedia: _selectedMedia,
    )) {
      return;
    }

    setState(() {
      _audioScreenDarkened = true;
    });
    _setAudioDarkSystemUi(true);
  }

  void _disableAudioDarkScreen() {
    if (!_audioScreenDarkened) {
      return;
    }

    final isPlaying = _videoController?.value.isPlaying ?? false;
    setState(() {
      _audioScreenDarkened = false;
    });
    _setAudioDarkSystemUi(false);
    _showStageControls(autoHide: isPlaying);
  }

  void _setAudioDarkSystemUi(bool darkened) {
    final scheme = Theme.of(context).colorScheme;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final style = darkened
        ? const SystemUiOverlayStyle(
            statusBarColor: AppColors.black,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.black,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: AppColors.black,
            systemNavigationBarContrastEnforced: false,
          )
        : SystemUiOverlayStyle(
            statusBarColor: scheme.surface,
            statusBarIconBrightness: isDarkTheme
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: scheme.surface,
            systemNavigationBarIconBrightness: isDarkTheme
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarDividerColor: scheme.surface,
            systemNavigationBarContrastEnforced: false,
          );

    SystemChrome.setSystemUIOverlayStyle(style);
  }

  Future<void> _openFullscreen() async {
    final controller = _videoController;
    final selectedMedia = _selectedMedia;
    if (controller == null ||
        !controller.value.isInitialized ||
        !_isVideoMedia(selectedMedia)) {
      return;
    }

    _showStageControls(autoHide: false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullscreenMediaPlayer(
          controller: controller,
          title: _mediaTitle(selectedMedia!),
          onPlayPause: _togglePlayback,
          onSeek: _seekTo,
          onSeekRelative: _seekRelative,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    _showStageControls(autoHide: controller.value.isPlaying);
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

    final currentController = _videoController;
    if (_selectedMedia?.uuidContentMedia == selected.uuidContentMedia &&
        currentController != null) {
      if (autoPlay &&
          currentController.value.isInitialized &&
          !currentController.value.isPlaying) {
        await currentController.play();
        _initialPlaybackRequested = true;
        _scheduleStageControlsAutoHide();
      }
      return;
    }

    await _prepareMedia(selected, autoPlay: autoPlay);
  }

  Future<void> _clearPlayback() async {
    _prepareGeneration++;
    _stageControlsAutoHideTimer?.cancel();
    await _disposeVideoController();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedMedia = null;
      _isPreparing = false;
      _playbackError = null;
      _stageControlsRequested = true;
      _audioScreenDarkened = false;
    });
  }

  Future<void> _prepareMedia(
    AppContentMedia media, {
    required bool autoPlay,
  }) async {
    final generation = ++_prepareGeneration;
    final downloadsController = AppDataScope.contentDownloads(context);

    _stageControlsAutoHideTimer?.cancel();
    setState(() {
      _selectedMedia = media;
      _isPreparing = true;
      _playbackError = null;
      _stageControlsRequested = true;
      _audioScreenDarkened = false;
    });

    await _disposeVideoController();

    VideoPlayerController? nextVideoController;
    try {
      final localPath = await downloadsController.openDownloadedMedia(
        uuidContentMedia: media.uuidContentMedia,
      );
      if (!mounted || generation != _prepareGeneration) {
        return;
      }

      if (localPath != null && localPath.trim().isNotEmpty) {
        nextVideoController = await createLocalContentMediaController(
          localPath,
        );
      }

      if (nextVideoController == null) {
        final signedUrl = await _mediaController?.resolveMediaUrl(
          media.storagePathSupabase,
        );
        if (!mounted || generation != _prepareGeneration) {
          return;
        }
        if (signedUrl == null || signedUrl.trim().isEmpty) {
          throw StateError('No se pudo preparar este contenido.');
        }

        nextVideoController = VideoPlayerController.networkUrl(
          Uri.parse(signedUrl),
        );
      }

      await nextVideoController.initialize();
      nextVideoController.addListener(_handleVideoChanged);

      if (!mounted || generation != _prepareGeneration) {
        nextVideoController.removeListener(_handleVideoChanged);
        await nextVideoController.dispose();
        return;
      }

      setState(() {
        _videoController = nextVideoController;
        _isPreparing = false;
      });

      await _applySavedPlaybackPositionIfNeeded();
      if (!mounted || generation != _prepareGeneration) {
        return;
      }

      if (autoPlay) {
        await nextVideoController.play();
        if (shouldConsumeInitialAutoplay(
          requestedAutoplay: autoPlay,
          mediaPrepared: true,
        )) {
          _initialPlaybackRequested = true;
        }
        _scheduleStageControlsAutoHide();
      }
    } catch (error) {
      nextVideoController?.removeListener(_handleVideoChanged);
      await nextVideoController?.dispose();
      if (!mounted || generation != _prepareGeneration) {
        return;
      }
      setState(() {
        if (_videoController == nextVideoController) {
          _videoController = null;
        }
        _isPreparing = false;
        _playbackError = error;
        _stageControlsRequested = true;
      });
    }
  }

  Future<void> _disposeVideoController() async {
    final controller = _videoController;
    if (controller == null) {
      return;
    }

    await _savePlaybackProgress(force: true);
    controller.removeListener(_handleVideoChanged);
    _videoController = null;
    await controller.dispose();
  }

  Future<void> _closePlayer() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    await _savePlaybackProgress(force: true);
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _selectMedia(AppContentMedia media) async {
    _requestedMediaUuid = media.uuidContentMedia;
    await _prepareMedia(media, autoPlay: true);
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
      await _savePlaybackProgress(force: true);
      _showStageControls(autoHide: false);
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
        _completionSaved = false;
        _lastSavedProgressSecond = null;
      }
      await controller.play();
      _showStageControls(autoHide: true);
    }
  }

  Future<void> _seekRelative(Duration offset) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final targetPosition = clampRelativeSeekPosition(
      position: controller.value.position,
      offset: offset,
      duration: controller.value.duration,
    );
    await controller.seekTo(targetPosition);
    await _savePlaybackProgress(force: true);
  }

  Future<void> _seekTo(Duration position) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    await controller.seekTo(position);
    await _savePlaybackProgress(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleColor = scheme.onSurface;
    final bodyColor = scheme.onSurface;
    final mediaController = _mediaController;
    final mediaItems = playableContentMediaItems(
      mediaController?.items ?? const [],
    );
    final showsMediaStages = contentItemShowsMediaStages(widget.item);
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
    final isLoadingMedia =
        (mediaController?.isLoading ?? false) ||
        (mediaController?.isSyncing ?? false);
    final stageControlsVisible = shouldShowPlayerStageControls(
      controlsRequested: _stageControlsRequested,
      isPreparing: _isPreparing,
      isLoadingMedia: isLoadingMedia,
      hasSelectedMedia: selectedMedia != null,
      isPlaying: videoController?.value.isPlaying ?? false,
      hasPlaybackError: _playbackError != null,
    );
    final displayTitle = selectedMedia == null
        ? widget.item.title
        : _mediaTitle(selectedMedia);
    final mediaLabel =
        selectedMedia == null || selectedIndex < 0 || !showsMediaStages
        ? widget.item.type.toUpperCase()
        : 'ETAPA ${selectedIndex + 1} DE ${mediaItems.length}';
    final canDarkenScreen = contentItemSupportsAudioDarkScreen(
      widget.item,
      selectedMedia: selectedMedia,
    );

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_closePlayer());
        }
      },
      child: Scaffold(
        backgroundColor: _audioScreenDarkened
            ? AppColors.black
            : scheme.surface,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          AppBackButton(onTap: _closePlayer),
                          const Spacer(),
                          const AppLogo(width: 132),
                          const Spacer(),
                          const SizedBox(width: 56),
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
                      controlsVisible: stageControlsVisible,
                      canDarkenScreen: canDarkenScreen,
                      onStageTap: _handleStageTap,
                      onPlayPause: _togglePlayback,
                      onSeek: _seekTo,
                      onReplay10: () => unawaited(
                        _seekRelative(const Duration(seconds: -10)),
                      ),
                      onForward10: () =>
                          unawaited(_seekRelative(const Duration(seconds: 10))),
                      onFullscreen: _openFullscreen,
                      onDarkenScreen: _enableAudioDarkScreen,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontFamily: AppTypography.displayFont,
                                  color: scheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            displayTitle,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(color: titleColor),
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
                          if (showsMediaStages) ...[
                            const SizedBox(height: 34),
                            _PlayerMediaList(
                              items: mediaItems,
                              selectedMediaUuid:
                                  selectedMedia?.uuidContentMedia,
                              isLoading: isLoadingMedia,
                              onSelected: (item) =>
                                  unawaited(_selectMedia(item)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_audioScreenDarkened)
              Positioned.fill(
                child: _AudioDarkScreen(onTap: _disableAudioDarkScreen),
              ),
          ],
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
    required this.controlsVisible,
    required this.canDarkenScreen,
    required this.onStageTap,
    required this.onPlayPause,
    required this.onSeek,
    required this.onReplay10,
    required this.onForward10,
    required this.onFullscreen,
    required this.onDarkenScreen,
  });

  final ContentItem item;
  final AppContentMedia? selectedMedia;
  final VideoPlayerController? controller;
  final bool isPreparing;
  final bool isLoadingMedia;
  final Object? playbackError;
  final bool controlsVisible;
  final bool canDarkenScreen;
  final VoidCallback onStageTap;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onReplay10;
  final VoidCallback onForward10;
  final VoidCallback onFullscreen;
  final VoidCallback onDarkenScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final videoController = controller;
    final canShowVideo =
        videoController != null &&
        videoController.value.isInitialized &&
        _isVideoMedia(selectedMedia);
    final isPlaying = videoController?.value.isPlaying ?? false;
    final canOpenFullscreen = canShowVideo && playbackError == null;
    final canControl =
        videoController != null &&
        videoController.value.isInitialized &&
        !isPreparing;
    final canShowBottomControls =
        selectedMedia != null && playbackError == null;

    return AspectRatio(
      aspectRatio: 1.05,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onStageTap,
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
                  color: scheme.surface,
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
              child: AnimatedOpacity(
                opacity: controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: IgnorePointer(
                  ignoring: !controlsVisible,
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
                      child:
                          isPreparing ||
                              (isLoadingMedia && selectedMedia == null)
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
              ),
            ),
            if (canShowBottomControls)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AnimatedOpacity(
                  opacity: controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: IgnorePointer(
                    ignoring: !controlsVisible,
                    child: _StageBottomControls(
                      controller: videoController,
                      enabled: canControl,
                      canOpenFullscreen: canOpenFullscreen,
                      canDarkenScreen: canDarkenScreen,
                      onSeek: onSeek,
                      onReplay10: onReplay10,
                      onForward10: onForward10,
                      onFullscreen: onFullscreen,
                      onDarkenScreen: onDarkenScreen,
                    ),
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
                    'No se pudo reproducir este contenido.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageBottomControls extends StatelessWidget {
  const _StageBottomControls({
    required this.controller,
    required this.enabled,
    required this.canOpenFullscreen,
    required this.canDarkenScreen,
    required this.onSeek,
    required this.onReplay10,
    required this.onForward10,
    required this.onFullscreen,
    required this.onDarkenScreen,
  });

  final VideoPlayerController? controller;
  final bool enabled;
  final bool canOpenFullscreen;
  final bool canDarkenScreen;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onReplay10;
  final VoidCallback onForward10;
  final VoidCallback onFullscreen;
  final VoidCallback onDarkenScreen;

  @override
  Widget build(BuildContext context) {
    final canShowCornerAction = canOpenFullscreen || canDarkenScreen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlaybackProgress(
          controller: controller,
          enabled: enabled,
          onChanged: onSeek,
          activeColor: AppColors.white,
          inactiveColor: AppColors.white.withValues(alpha: 0.30),
          textColor: AppColors.white,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StageOverlayButton(
              icon: Icons.replay_10_rounded,
              tooltip: 'Retroceder 10 segundos',
              enabled: enabled,
              onTap: onReplay10,
            ),
            const SizedBox(width: 10),
            _StageOverlayButton(
              icon: Icons.forward_10_rounded,
              tooltip: 'Adelantar 10 segundos',
              enabled: enabled,
              onTap: onForward10,
            ),
            const Spacer(),
            if (canShowCornerAction)
              _StageOverlayButton(
                icon: canOpenFullscreen
                    ? Icons.fullscreen_rounded
                    : Icons.dark_mode_rounded,
                tooltip: canOpenFullscreen
                    ? 'Pantalla completa'
                    : 'Oscurecer pantalla',
                onTap: canOpenFullscreen ? onFullscreen : onDarkenScreen,
              ),
          ],
        ),
      ],
    );
  }
}

class _StageOverlayButton extends StatelessWidget {
  const _StageOverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? AppColors.white
        : AppColors.white.withValues(alpha: 0.45);

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      enabled: enabled,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: enabled ? 0.34 : 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: foreground, size: 28),
      ),
    );
  }
}

class _AudioDarkScreen extends StatelessWidget {
  const _AudioDarkScreen({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pantalla oscura. Toca para volver al reproductor.',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const ColoredBox(color: AppColors.black),
      ),
    );
  }
}

class _FullscreenMediaPlayer extends StatefulWidget {
  const _FullscreenMediaPlayer({
    required this.controller,
    required this.title,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSeekRelative,
  });

  final VideoPlayerController controller;
  final String title;
  final Future<void> Function() onPlayPause;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function(Duration offset) onSeekRelative;

  @override
  State<_FullscreenMediaPlayer> createState() => _FullscreenMediaPlayerState();
}

class _FullscreenMediaPlayerState extends State<_FullscreenMediaPlayer> {
  bool _controlsVisible = true;
  Timer? _controlsAutoHideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    _scheduleControlsAutoHide();
  }

  @override
  void dispose() {
    _controlsAutoHideTimer?.cancel();
    widget.controller.removeListener(_handleControllerChanged);
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    final shouldRevealControls =
        !_controlsVisible && !widget.controller.value.isPlaying;
    setState(() {
      if (shouldRevealControls) {
        _controlsVisible = true;
      }
    });
  }

  void _showControls({required bool autoHide}) {
    _controlsAutoHideTimer?.cancel();
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }

    if (autoHide) {
      _scheduleControlsAutoHide();
    }
  }

  void _hideControls() {
    _controlsAutoHideTimer?.cancel();
    if (!_controlsVisible) {
      return;
    }

    setState(() {
      _controlsVisible = false;
    });
  }

  void _scheduleControlsAutoHide() {
    _controlsAutoHideTimer?.cancel();
    if (!widget.controller.value.isPlaying) {
      return;
    }

    _controlsAutoHideTimer = Timer(_playerControlsAutoHideDelay, () {
      if (!mounted || !widget.controller.value.isPlaying) {
        return;
      }

      setState(() {
        _controlsVisible = false;
      });
    });
  }

  void _handleStageTap() {
    if (_controlsVisible && widget.controller.value.isPlaying) {
      _hideControls();
      return;
    }

    _showControls(autoHide: widget.controller.value.isPlaying);
  }

  Future<void> _togglePlayback() async {
    await widget.onPlayPause();
    if (!mounted) {
      return;
    }

    _showControls(autoHide: widget.controller.value.isPlaying);
  }

  Future<void> _seekRelative(Duration offset) async {
    await widget.onSeekRelative(offset);
    if (!mounted) {
      return;
    }

    _showControls(autoHide: widget.controller.value.isPlaying);
  }

  Future<void> _seekTo(Duration position) async {
    await widget.onSeek(position);
    if (!mounted) {
      return;
    }

    _showControls(autoHide: widget.controller.value.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final isPlaying = value.isPlaying;
    final duration = value.duration;
    final position = value.position;
    final maxMilliseconds = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final currentMilliseconds = position.inMilliseconds
        .clamp(0, maxMilliseconds.toInt())
        .toDouble();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleStageTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.42),
                          AppColors.transparent,
                          AppColors.black.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: _StageOverlayButton(
                        icon: Icons.fullscreen_exit_rounded,
                        tooltip: 'Salir de pantalla completa',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StageOverlayButton(
                        icon: Icons.replay_10_rounded,
                        tooltip: 'Retroceder 10 segundos',
                        onTap: () => unawaited(
                          _seekRelative(const Duration(seconds: -10)),
                        ),
                      ),
                      const SizedBox(width: 18),
                      AppInteractive(
                        tooltip: isPlaying ? 'Pausar' : 'Reproducir',
                        borderRadius: AppRadius.full,
                        onTap: () => unawaited(_togglePlayback()),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.36),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.white,
                            size: 58,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      _StageOverlayButton(
                        icon: Icons.forward_10_rounded,
                        tooltip: 'Adelantar 10 segundos',
                        onTap: () => unawaited(
                          _seekRelative(const Duration(seconds: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SafeArea(
                top: false,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                          ),
                          child: Slider(
                            value: currentMilliseconds,
                            max: maxMilliseconds,
                            onChanged: (value) => unawaited(
                              _seekTo(Duration(milliseconds: value.round())),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatClock(position),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.white),
                            ),
                            const Spacer(),
                            Text(
                              _formatClock(duration),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackProgress extends StatelessWidget {
  const _PlaybackProgress({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.textColor,
  });

  final VideoPlayerController? controller;
  final bool enabled;
  final ValueChanged<Duration> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedActiveColor = activeColor ?? scheme.primary;
    final resolvedInactiveColor =
        inactiveColor ?? scheme.primary.withValues(alpha: 0.24);
    final resolvedTextColor = textColor ?? scheme.onSurface;

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
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: resolvedActiveColor,
            inactiveTrackColor: resolvedInactiveColor,
            thumbColor: resolvedActiveColor,
            overlayColor: resolvedActiveColor.withValues(alpha: 0.14),
          ),
          child: Slider(
            value: currentMilliseconds,
            max: maxMilliseconds,
            onChanged: enabled
                ? (value) => onChanged(Duration(milliseconds: value.round()))
                : null,
          ),
        ),
        Row(
          children: [
            Text(
              _formatClock(position),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: resolvedTextColor),
            ),
            const Spacer(),
            Text(
              _formatClock(duration),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: resolvedTextColor),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty) {
      return _PlayerStatusMessage(
        text: isLoading
            ? 'Cargando etapas...'
            : 'No hay etapas disponibles para este curso.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etapas del curso',
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontFamily: AppTypography.displayFont,
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = isSelected
        ? scheme.primary.withValues(alpha: 0.12)
        : scheme.surface;
    final stroke = isSelected
        ? scheme.primary.withValues(alpha: 0.42)
        : scheme.onSurface.withValues(alpha: 0.14);

    return AppInteractive(
      tooltip: 'Reproducir etapa',
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
            Icon(_mediaIcon(item), color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mediaTitle(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontFamily: AppTypography.displayFont,
                    ),
                  ),
                  Text(
                    contentMediaSubtitle(item),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.76),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.equalizer_rounded, color: scheme.primary),
          ],
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

  return contentMediaKindLabel(item.tipo);
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
