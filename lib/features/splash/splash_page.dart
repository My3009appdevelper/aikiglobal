import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../app/app_router.dart';
import '../../core/constants/app_assets.dart';
import '../../core/data/providers/app_data_scope.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _fallbackDuration = Duration(seconds: 10);
  static const _splashPlaybackSpeed = 5.0;

  VideoPlayerController? _videoController;
  late final AnimationController _fadeController;
  Timer? _fallbackTimer;
  bool _ready = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(AppAssets.aikiLogoAnimation);
    _videoController = controller;
    try {
      await controller.initialize();
      await controller.setPlaybackSpeed(_splashPlaybackSpeed);
      await controller.setLooping(false);
      await controller.setVolume(0);
      await controller.seekTo(Duration.zero);
      await controller.play();
      _scheduleFallback(controller.value.duration);
      controller.addListener(() {
        final value = controller.value;
        if (value.isInitialized &&
            value.position >= value.duration &&
            value.duration > Duration.zero) {
          _goNext();
        }
      });
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _ready = false);
      _scheduleFallback(Duration.zero);
    }
  }

  void _scheduleFallback(Duration duration) {
    _fallbackTimer?.cancel();
    final Duration wait;
    if (duration > Duration.zero) {
      final adjustedMs = (duration.inMilliseconds / _splashPlaybackSpeed)
          .ceil()
          .clamp(1000, 30000);
      wait = Duration(milliseconds: adjustedMs);
    } else {
      wait = _fallbackDuration;
    }
    _fallbackTimer = Timer(wait + const Duration(milliseconds: 250), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();

    final currentProfileController = AppDataScope.currentProfile(context);
    await currentProfileController.enforceRememberPreferenceOnStartup();
    final rememberSession = await currentProfileController.rememberSessionEnabled();
    final isAuthenticated = rememberSession && currentProfileController.isAuthenticated;
    final hasSeenOnboarding = await currentProfileController.hasSeenOnboarding();
    if (!mounted) return;

    final target = isAuthenticated
        ? AppRouter.home
        : hasSeenOnboarding
        ? AppRouter.login
        : AppRouter.onboarding;

    final navigator = Navigator.of(context);
    navigator.pushReplacementNamed(target);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _videoController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOut,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _ready && _videoController != null
              ? _FullScreenVideo(controller: _videoController!)
              : const SizedBox.expand(child: ColoredBox(color: Colors.white)),
        ),
      ),
    );
  }
}

class _FullScreenVideo extends StatelessWidget {
  const _FullScreenVideo({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;

    if (size.isEmpty) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.white));
    }

    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
