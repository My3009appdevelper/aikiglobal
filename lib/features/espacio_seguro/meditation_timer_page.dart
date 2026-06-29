import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_media.dart';
import '../../core/data/models/app_content_item.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_primary_button.dart';
import '../../shared/widgets/app_progress_celebration_overlay.dart';
import '../../shared/widgets/app_responsive_container.dart';
import 'meditation_timer_audio_policy.dart';

class MeditationTimerPage extends StatefulWidget {
  const MeditationTimerPage({super.key});

  @override
  State<MeditationTimerPage> createState() => _MeditationTimerPageState();
}

class _MeditationTimerPageState extends State<MeditationTimerPage> {
  int _durationMinutes = 10;
  int _remainingSeconds = 10 * 60;
  String? _selectedSoundId;
  bool _isRunning = false;
  bool _hasStarted = false;
  bool _completedSessionRecorded = false;
  bool _showCompletionOverlay = false;
  AppProgressCelebrationData? _progressOverlayData;
  VoidCallback? _progressOverlayOnClose;
  Timer? _timer;
  final AudioPlayer _ambientPlayer = AudioPlayer();
  List<AppContentItem> _timerSounds = const [];
  AppContentMedia? _selectedSoundMedia;
  bool _hasLoadedTimerSounds = false;
  bool _isLoadingTimerSounds = false;
  bool _isLoadingSoundMedia = false;
  Object? _timerSoundsError;
  Object? _soundMediaError;
  Object? _ambientSoundError;
  int _soundMediaLoadGeneration = 0;
  String? _loadedAmbientRemotePath;

  int get _totalSeconds => _durationMinutes * 60;
  bool get _isFinished => _hasStarted && _remainingSeconds == 0;
  bool get _canStopSession => _hasStarted && !_isFinished && !_isRunning;
  int get _elapsedSeconds {
    return (_totalSeconds - _remainingSeconds).clamp(0, _totalSeconds).toInt();
  }

  int get _elapsedFullMinutes => _elapsedSeconds ~/ 60;

  String get _primaryLabel {
    if (_isRunning) return 'Pausar';
    if (_isFinished) return 'Reiniciar';
    if (_hasStarted) return 'Continuar';
    return 'Empezar';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedTimerSounds) {
      return;
    }

    _hasLoadedTimerSounds = true;
    unawaited(_loadTimerSounds());
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_ambientPlayer.dispose());
    super.dispose();
  }

  AppContentItem? _selectedSound(List<AppContentItem> sounds) {
    if (sounds.isEmpty) {
      return null;
    }

    final selectedId = _selectedSoundId;
    if (selectedId == null) {
      return sounds.first;
    }

    for (final sound in sounds) {
      if (sound.uuidContentItem == selectedId) {
        return sound;
      }
    }

    return sounds.first;
  }

  Future<void> _loadTimerSounds() async {
    setState(() {
      _isLoadingTimerSounds = true;
      _timerSoundsError = null;
    });

    try {
      final contentController = AppDataScope.contentItems(context);
      final snapshot = await contentController.getPublishedSnapshot();
      final sounds = publishedMeditationTimerSounds(snapshot);
      final selectedSound = _selectedSound(sounds);

      if (!mounted) {
        return;
      }

      setState(() {
        _timerSounds = sounds;
        _selectedSoundId = selectedSound?.uuidContentItem;
        _isLoadingTimerSounds = false;
      });
      unawaited(_loadSoundMedia(selectedSound));
    } catch (error, stackTrace) {
      debugPrint('MeditationTimerPage.load sounds error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _timerSounds = const [];
        _selectedSoundMedia = null;
        _timerSoundsError = error;
        _isLoadingTimerSounds = false;
      });
    }
  }

  Future<void> _loadSoundMedia(AppContentItem? sound) async {
    final generation = ++_soundMediaLoadGeneration;
    if (sound == null) {
      setState(() {
        _selectedSoundMedia = null;
        _soundMediaError = null;
        _isLoadingSoundMedia = false;
      });
      return;
    }

    setState(() {
      _selectedSoundMedia = null;
      _soundMediaError = null;
      _ambientSoundError = null;
      _isLoadingSoundMedia = true;
    });

    try {
      final mediaController = AppDataScope.contentMedia(context);
      final mediaItems = await mediaController.getByContentSnapshot(
        sound.uuidContentItem,
      );
      final selectedMedia = selectMeditationTimerSoundMedia(
        mediaItems,
        uuidContentItem: sound.uuidContentItem,
      );

      if (!mounted || generation != _soundMediaLoadGeneration) {
        return;
      }

      setState(() {
        _selectedSoundMedia = selectedMedia;
        _isLoadingSoundMedia = false;
      });
    } catch (error, stackTrace) {
      debugPrint('MeditationTimerPage.load media error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted || generation != _soundMediaLoadGeneration) {
        return;
      }
      setState(() {
        _selectedSoundMedia = null;
        _soundMediaError = error;
        _isLoadingSoundMedia = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imageAsset: AppAssets.backgroundMeditation,
        imageOpacity: 0.04,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              AppResponsiveContainer(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 124),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TimerHeader(
                              onBack: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Center(
                              child: _TimerRing(
                                remainingSeconds: _remainingSeconds,
                                durationSeconds: _durationMinutes * 60,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _DurationSection(
                              enabled: !_isRunning,
                              minutes: _durationMinutes,
                              onChanged: _updateDuration,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Builder(
                              builder: (context) {
                                final contentController =
                                    AppDataScope.contentItems(context);
                                final selectedSound = _selectedSound(
                                  _timerSounds,
                                );

                                return Column(
                                  children: [
                                    _SoundSection(
                                      sounds: _timerSounds,
                                      selectedSoundId:
                                          selectedSound?.uuidContentItem,
                                      isLoading:
                                          _isLoadingTimerSounds ||
                                          _isLoadingSoundMedia,
                                      enabled: !_isRunning,
                                      resolveCoverImageUrl: contentController
                                          .resolveCoverImageUrl,
                                      onSelected: (sound) {
                                        setState(() {
                                          _selectedSoundId =
                                              sound.uuidContentItem;
                                        });
                                        unawaited(_loadSoundMedia(sound));
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    _SelectedSoundNote(
                                      sound: selectedSound,
                                      hasAudio: _selectedSoundMedia != null,
                                      isLoading:
                                          _isLoadingTimerSounds ||
                                          _isLoadingSoundMedia,
                                      error:
                                          _ambientSoundError ??
                                          _soundMediaError ??
                                          _timerSoundsError,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_canStopSession)
                          Row(
                            children: [
                              Expanded(child: _buildPrimaryTimerAction()),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: AppPrimaryButton(
                                  label: 'Detener',
                                  icon: Icons.stop_rounded,
                                  expand: true,
                                  height: 56,
                                  onPressed: _stopTimerAndRecordPartial,
                                ),
                              ),
                            ],
                          )
                        else
                          _buildPrimaryTimerAction(),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showCompletionOverlay,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final scale = Tween<double>(
                        begin: 0.96,
                        end: 1,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: scale, child: child),
                      );
                    },
                    child: _showCompletionOverlay
                        ? AppProgressCelebrationOverlay(
                            key: ValueKey(_progressOverlayData),
                            data: _progressOverlayData!,
                            onClose: _closeProgressCelebration,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateDuration(double value) {
    if (_isRunning) return;

    final nextMinutes = value.round();
    setState(() {
      _durationMinutes = nextMinutes;
      _remainingSeconds = nextMinutes * 60;
      _hasStarted = false;
      _completedSessionRecorded = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
      return;
    }

    if (_remainingSeconds <= 0) {
      _remainingSeconds = _durationMinutes * 60;
      _completedSessionRecorded = false;
    }

    setState(() {
      _isRunning = true;
      _hasStarted = true;
    });
    unawaited(_startAmbientSoundIfAvailable());

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        unawaited(_stopAmbientSound());
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
        unawaited(_recordCompletedMeditation(_durationMinutes));
        return;
      }

      setState(() => _remainingSeconds -= 1);
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    unawaited(_pauseAmbientSound());
    setState(() => _isRunning = false);
  }

  Future<void> _startAmbientSoundIfAvailable() async {
    final mediaController = AppDataScope.contentMedia(context);
    final sound = _selectedSound(_timerSounds);
    if (sound == null) {
      return;
    }

    try {
      setState(() => _ambientSoundError = null);
      final mediaItems = await mediaController.getByContentSnapshot(
        sound.uuidContentItem,
      );

      if (!mounted || !_isRunning) {
        return;
      }

      final selectedMedia =
          _selectedSoundMedia?.uuidContentItem == sound.uuidContentItem
          ? _selectedSoundMedia
          : selectMeditationTimerSoundMedia(
              mediaItems,
              uuidContentItem: sound.uuidContentItem,
            );

      if (selectedMedia == null) {
        throw StateError('El sonido seleccionado no tiene archivos.');
      }

      final remotePath = selectedMedia.storagePathSupabase.trim();
      if (remotePath.isEmpty) {
        throw StateError('El archivo del sonido no tiene ruta remota.');
      }

      final audioUrl = await mediaController.resolveMediaUrl(remotePath);
      if (!mounted || !_isRunning) {
        return;
      }
      if (audioUrl == null || audioUrl.isEmpty) {
        throw StateError('No se pudo generar la URL del sonido.');
      }

      setState(() {
        _selectedSoundMedia = selectedMedia;
      });

      await _ambientPlayer.setLoopMode(LoopMode.one);
      await _ambientPlayer.setVolume(1);
      if (_loadedAmbientRemotePath != remotePath) {
        await _ambientPlayer.setUrl(audioUrl);
        _loadedAmbientRemotePath = remotePath;
      }
      await _ambientPlayer.play();
    } catch (error, stackTrace) {
      debugPrint('MeditationTimerPage.play ambient sound error: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _ambientPlayer.stop();
      _loadedAmbientRemotePath = null;
      if (!mounted) {
        return;
      }
      setState(() {
        _ambientSoundError = error;
        _isRunning = false;
      });
      _timer?.cancel();
    }
  }

  Future<void> _pauseAmbientSound() async {
    await _ambientPlayer.pause();
  }

  Future<void> _stopAmbientSound() async {
    await _ambientPlayer.stop();
    _loadedAmbientRemotePath = null;
  }

  Widget _buildPrimaryTimerAction() {
    return AppPrimaryButton(
      label: _primaryLabel,
      icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
      onPressed: _toggleTimer,
      height: 56,
    );
  }

  void _stopTimerAndRecordPartial() {
    final minutesToRecord = _elapsedFullMinutes;
    _timer?.cancel();
    unawaited(_stopAmbientSound());
    setState(() {
      _remainingSeconds = _durationMinutes * 60;
      _isRunning = false;
      _hasStarted = false;
      _completedSessionRecorded = false;
    });

    if (minutesToRecord >= 1) {
      unawaited(_recordCompletedMeditation(minutesToRecord));
    }
  }

  Future<void> _recordCompletedMeditation(int minutesToRecord) async {
    if (_completedSessionRecorded || minutesToRecord <= 0) {
      return;
    }

    _completedSessionRecorded = true;

    final profile = AppDataScope.currentProfile(context).profile;
    if (profile == null) {
      return;
    }

    final streakEvent = await AppDataScope.wellnessDailyLogs(context)
        .markMeditationCompleted(
          uuidProfile: profile.uuidProfile,
          minutes: minutesToRecord,
        );

    if (!mounted) {
      return;
    }

    _showProgressCelebration(
      AppProgressCelebrationData(
        title: 'Meditación completada',
        body:
            'Sumaste ${_wellnessMinutesLabel(minutesToRecord)} a tu bienestar.',
        icon: Icons.self_improvement_rounded,
      ),
      onFinished: streakEvent == null
          ? null
          : () {
              _showProgressCelebration(
                AppProgressCelebrationData(
                  title: 'Racha actualizada',
                  body:
                      'Ya llevas ${_streakDaysLabel(streakEvent.streak)} cuidando de ti.',
                  icon: Icons.local_fire_department_rounded,
                  fromValue: streakEvent.previousStreak,
                  toValue: streakEvent.streak,
                  valueLabel: 'días',
                ),
              );
            },
    );
  }

  void _showProgressCelebration(
    AppProgressCelebrationData data, {
    VoidCallback? onFinished,
  }) {
    setState(() {
      _progressOverlayData = data;
      _progressOverlayOnClose = onFinished;
      _showCompletionOverlay = true;
    });
  }

  void _closeProgressCelebration() {
    final next = _progressOverlayOnClose;
    setState(() {
      _showCompletionOverlay = false;
      _progressOverlayOnClose = null;
    });

    if (next == null) {
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) {
        return;
      }
      next();
    });
  }
}

class _TimerHeader extends StatelessWidget {
  const _TimerHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppInteractive(
          borderRadius: AppRadius.full,
          onTap: onBack,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timer de meditación',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 3),
              Text(
                'Respira, suelta y vuelve a tu centro.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.remainingSeconds,
    required this.durationSeconds,
  });

  final int remainingSeconds;
  final int durationSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = durationSeconds <= 0
        ? 0.0
        : 1 - (remainingSeconds / durationSeconds).clamp(0.0, 1.0);
    final time = _formatTime(remainingSeconds);
    final brightness = Theme.of(context).brightness;

    return Container(
      width: 236,
      height: 236,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.white.withValues(alpha: 0.88),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 9,
            strokeCap: StrokeCap.round,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            color: Theme.of(context).colorScheme.primary,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text('minutos', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSection extends StatelessWidget {
  const _DurationSection({
    required this.enabled,
    required this.minutes,
    required this.onChanged,
  });

  final bool enabled;
  final int minutes;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TimerSection(
      title: 'Duración',
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$minutes minutos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          Slider(
            value: minutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            label: '$minutes min',
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _SoundSection extends StatelessWidget {
  const _SoundSection({
    required this.sounds,
    required this.selectedSoundId,
    required this.isLoading,
    required this.enabled,
    required this.resolveCoverImageUrl,
    required this.onSelected,
  });

  final List<AppContentItem> sounds;
  final String? selectedSoundId;
  final bool isLoading;
  final bool enabled;
  final Future<String?> Function(String imagePath) resolveCoverImageUrl;
  final ValueChanged<AppContentItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return _TimerSection(
      title: 'Sonido de ambiente',
      child: sounds.isEmpty
          ? _EmptySoundState(isLoading: isLoading)
          : SizedBox(
              height: 154,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: sounds.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final sound = sounds[index];
                  return _SoundCoverCard(
                    sound: sound,
                    selected: sound.uuidContentItem == selectedSoundId,
                    enabled: enabled,
                    resolveCoverImageUrl: resolveCoverImageUrl,
                    onTap: () => onSelected(sound),
                  );
                },
              ),
            ),
    );
  }
}

class _EmptySoundState extends StatelessWidget {
  const _EmptySoundState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? AppColors.darkSurfaceSoft
            : AppColors.sandLight,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLoading
                  ? 'Cargando sonidos de ambiente...'
                  : 'Todavía no hay sonidos de ambiente publicados.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundCoverCard extends StatelessWidget {
  const _SoundCoverCard({
    required this.sound,
    required this.selected,
    required this.enabled,
    required this.resolveCoverImageUrl,
    required this.onTap,
  });

  final AppContentItem sound;
  final bool selected;
  final bool enabled;
  final Future<String?> Function(String imagePath) resolveCoverImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.white;
    final stroke = selected
        ? scheme.primary
        : brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;
    final coverPath = _coverPathForSound(sound);

    return AppInteractive(
      tooltip: enabled ? 'Seleccionar ${sound.titulo}' : null,
      borderRadius: AppRadius.large,
      hoverScale: 1.015,
      pressedScale: 0.97,
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.58,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 128,
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.94),
            borderRadius: AppRadius.large,
            border: Border.all(color: stroke, width: selected ? 1.6 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.medium,
                    child: SizedBox(
                      width: double.infinity,
                      height: 74,
                      child: AppCoverImage(
                        imagePath: coverPath,
                        resolveImageUrl: resolveCoverImageUrl,
                        fallback: _SoundCoverFallback(
                          brightness: brightness,
                          color: scheme.primary,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: scheme.onPrimary,
                          size: 17,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 31,
                child: Text(
                  sound.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatSoundDuration(sound.duracionSegundos),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: muted, height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoundCoverFallback extends StatelessWidget {
  const _SoundCoverFallback({required this.brightness, required this.color});

  final Brightness brightness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.sandLight,
      alignment: Alignment.center,
      child: Image.asset(
        Theme.of(context).brightness == Brightness.dark
            ? AppAssets.logoCompleteColorWhiteLetters
            : AppAssets.logoCompleteColor,
        width: 82,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.graphic_eq_rounded, color: color);
        },
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SelectedSoundNote extends StatelessWidget {
  const _SelectedSoundNote({
    required this.sound,
    required this.hasAudio,
    required this.isLoading,
    required this.error,
  });

  final AppContentItem? sound;
  final bool hasAudio;
  final bool isLoading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final selectedSound = sound;
    final message = selectedSound == null
        ? 'Selecciona un sonido para acompañar tu meditación.'
        : error != null
        ? 'No se pudo preparar el sonido de ambiente.'
        : isLoading
        ? 'Preparando sonido de ambiente...'
        : hasAudio
        ? 'Ambiente seleccionado: ${selectedSound.titulo}'
        : 'Ambiente seleccionado: ${selectedSound.titulo}. Falta agregar audio.';

    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

String _formatTime(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _wellnessMinutesLabel(int minutes) {
  return minutes == 1 ? '1 minuto' : '$minutes minutos';
}

String _streakDaysLabel(int days) {
  return days == 1 ? '1 día seguido' : '$days días seguidos';
}

String _formatSoundDuration(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return 'Disponible';
  }

  final totalMinutes = (seconds / 60).round();
  if (totalMinutes < 60) {
    return '$totalMinutes min';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}

String? _coverPathForSound(AppContentItem sound) {
  final localPath = sound.coverPathLocal?.trim();
  if (localPath != null && localPath.isNotEmpty) {
    return localPath;
  }

  final remotePath = sound.coverPathSupabase?.trim();
  if (remotePath != null && remotePath.isNotEmpty) {
    return remotePath;
  }

  return null;
}
