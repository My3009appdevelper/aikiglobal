import 'package:flutter/material.dart';

import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/home/home_shell_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/splash/splash_page.dart';

class AppRouter {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final isSplash = settings.name == splash;

    return PageRouteBuilder<void>(
      settings: settings,
      opaque: isSplash,
      transitionDuration: isSplash
          ? Duration.zero
          : const Duration(milliseconds: 1300),
      reverseTransitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) {
        return switch (settings.name) {
          splash => const SplashPage(),
          onboarding => const OnboardingPage(),
          login => const LoginPage(),
          register => const RegisterPage(),
          home => const HomeShellPage(),
          _ => const SplashPage(),
        };
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (isSplash) return child;

        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.06, 1, curve: Curves.easeOutQuart),
        );
        final motion = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(motion),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(motion),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
