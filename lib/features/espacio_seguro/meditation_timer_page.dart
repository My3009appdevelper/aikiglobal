import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_item.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_primary_button.dart';
import '../../shared/widgets/app_responsive_container.dart';

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
  _ProgressOverlayData? _progressOverlayData;
  Timer? _timer;
  Timer? _completionOverlayTimer;

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
  void dispose() {
    _timer?.cancel();
    _completionOverlayTimer?.cancel();
    super.dispose();
  }

  List<AppContentItem> _publishedSounds(List<AppContentItem> items) {
    return items.where((item) {
      return item.tipo.trim().toLowerCase() == 'sound' && item.isPublished;
    }).toList();
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
                            AnimatedBuilder(
                              animation: AppDataScope.contentItems(context),
                              builder: (context, _) {
                                final contentController =
                                    AppDataScope.contentItems(context);
                                final sounds = _publishedSounds(
                                  contentController.items,
                                );
                                final selectedSound = _selectedSound(sounds);

                                return Column(
                                  children: [
                                    _SoundSection(
                                      sounds: sounds,
                                      selectedSoundId:
                                          selectedSound?.uuidContentItem,
                                      isLoading:
                                          contentController.isLoading ||
                                          contentController.isSyncing,
                                      enabled: !_isRunning,
                                      onSelected: (sound) {
                                        setState(() {
                                          _selectedSoundId =
                                              sound.uuidContentItem;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    _SelectedSoundNote(sound: selectedSound),
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
                        ? _ProgressCelebrationOverlay(
                            key: ValueKey(_progressOverlayData),
                            data: _progressOverlayData!,
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

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_remainingSeconds <= 1) {
        _timer?.cancel();
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
    setState(() => _isRunning = false);
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

    final newStreak = await AppDataScope.wellnessDailyLogs(context)
        .markMeditationCompleted(
          uuidProfile: profile.uuidProfile,
          minutes: minutesToRecord,
        );

    if (!mounted) {
      return;
    }

    _showProgressCelebration(
      _ProgressOverlayData(
        title: 'Meditación completada',
        body:
            'Sumaste ${_wellnessMinutesLabel(minutesToRecord)} a tu bienestar.',
        icon: Icons.self_improvement_rounded,
      ),
      onFinished: newStreak == null
          ? null
          : () {
              _showProgressCelebration(
                _ProgressOverlayData(
                  title: 'Racha actualizada',
                  body:
                      'Ya llevas ${_streakDaysLabel(newStreak)} cuidando de ti.',
                  icon: Icons.local_fire_department_rounded,
                ),
              );
            },
    );
  }

  void _showProgressCelebration(
    _ProgressOverlayData data, {
    VoidCallback? onFinished,
  }) {
    _completionOverlayTimer?.cancel();
    setState(() {
      _progressOverlayData = data;
      _showCompletionOverlay = true;
    });

    _completionOverlayTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) {
        return;
      }

      setState(() => _showCompletionOverlay = false);
      if (onFinished != null) {
        Timer(const Duration(milliseconds: 220), () {
          if (!mounted) {
            return;
          }
          onFinished();
        });
      }
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

class _ProgressCelebrationOverlay extends StatelessWidget {
  const _ProgressCelebrationOverlay({super.key, required this.data});

  final _ProgressOverlayData data;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Container(
      color: AppColors.primaryDeep.withValues(
        alpha: brightness == Brightness.dark ? 0.62 : 0.34,
      ),
      padding: const EdgeInsets.all(28),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 760),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.88 + (0.12 * value),
              child: Opacity(opacity: value.clamp(0, 1), child: child),
            );
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.96),
              borderRadius: AppRadius.large,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
              boxShadow: AppShadows.soft(brightness),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, color: scheme.primary, size: 40),
                ),
                const SizedBox(height: 18),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: muted, height: 1.25),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  minHeight: 5,
                  borderRadius: AppRadius.full,
                  value: 1,
                  color: scheme.primary,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressOverlayData {
  const _ProgressOverlayData({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
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
    required this.onSelected,
  });

  final List<AppContentItem> sounds;
  final String? selectedSoundId;
  final bool isLoading;
  final bool enabled;
  final ValueChanged<AppContentItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return _TimerSection(
      title: 'Sonido de ambiente',
      child: sounds.isEmpty
          ? _EmptySoundState(isLoading: isLoading)
          : SizedBox(
              height: 178,
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
                    fallbackAsset: _fallbackSoundCover(index),
                    selected: sound.uuidContentItem == selectedSoundId,
                    enabled: enabled,
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
    required this.fallbackAsset,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final AppContentItem sound;
  final String fallbackAsset;
  final bool selected;
  final bool enabled;
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
    final coverAsset = _coverAssetForSound(sound, fallbackAsset);

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
          width: 154,
          padding: const EdgeInsets.all(10),
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
                    child: Image.asset(
                      coverAsset,
                      width: double.infinity,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 92,
                          color: brightness == Brightness.dark
                              ? AppColors.darkSurface
                              : AppColors.sandLight,
                          child: Icon(
                            Icons.graphic_eq_rounded,
                            color: scheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: scheme.onPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                sound.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                _formatSoundDuration(sound.duracionSegundos),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
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
  const _SelectedSoundNote({required this.sound});

  final AppContentItem? sound;

  @override
  Widget build(BuildContext context) {
    final message = sound == null
        ? 'Selecciona un sonido para acompañar tu meditación.'
        : 'Ambiente seleccionado: ${sound!.titulo}';

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

String _coverAssetForSound(AppContentItem sound, String fallbackAsset) {
  final localPath = sound.coverPathLocal?.trim();
  if (localPath != null && localPath.startsWith('assets/')) {
    return localPath;
  }

  return fallbackAsset;
}

String _fallbackSoundCover(int index) {
  const covers = [
    AppAssets.audio1,
    AppAssets.audio2,
    AppAssets.audio3,
    AppAssets.audio4,
    AppAssets.audio5,
    AppAssets.audio6,
    AppAssets.audio7,
    AppAssets.audio8,
    AppAssets.audio9,
    AppAssets.audio10,
    AppAssets.audio11,
    AppAssets.audio12,
    AppAssets.audio13,
    AppAssets.audio14,
    AppAssets.audio15,
  ];

  return covers[index % covers.length];
}
