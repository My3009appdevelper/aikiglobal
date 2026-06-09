import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_primary_button.dart';
import '../../shared/widgets/app_responsive_container.dart';
import 'widgets/onboarding_dots.dart';
import 'widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentIndex = 0;

  static const _slides = [
    _OnboardingData(
      title: 'Respira y vuelve a ti',
      subtitle: 'Encuentra paz, claridad y equilibrio en cada momento del día.',
      imageAsset: AppAssets.backgroundMeditation,
    ),
    _OnboardingData(
      title: 'Explora cursos y meditaciones',
      subtitle:
          'Descubre cursos, audios, meditaciones y sesiones diseñados para acompañarte en tu bienestar.',
      imageAsset: AppAssets.backgroundArchitecture,
    ),
    _OnboardingData(
      title: 'Tu lugar seguro, siempre contigo',
      subtitle:
          'Sigue tu racha diaria, cuida tu descanso y celebra tu avance de bienestar.',
      imageAsset: AppAssets.backgroundSafeSpace,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() async {
    await AppDataScope.currentProfile(context).markOnboardingCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  void _next() {
    if (_currentIndex == _slides.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        animateEntry: true,
        entryDuration: const Duration(milliseconds: 3000),
        contentDelay: const Duration(milliseconds: 2000),
        imageAsset: AppAssets.backgroundGarden,
        imageOpacity: 0.05,
        child: SafeArea(
          child: AppResponsiveContainer(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const AppLogo(width: 150),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('Omitir'),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: OnboardingSlide(
                          title: slide.title,
                          subtitle: slide.subtitle,
                          imageAsset: slide.imageAsset,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                OnboardingDots(
                  count: _slides.length,
                  currentIndex: _currentIndex,
                ),
                const SizedBox(height: 26),
                AppPrimaryButton(
                  label: _currentIndex == _slides.length - 1
                      ? 'Comenzar'
                      : 'Siguiente',
                  onPressed: _next,
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('Omitir'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
}
