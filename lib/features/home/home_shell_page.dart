import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../app/app_router.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../espacio_seguro/espacio_seguro_page.dart';
import '../explorar/explorar_page.dart';
import '../perfil/perfil_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;

  static const _pages = [ExplorarPage(), EspacioSeguroPage(), PerfilPage()];

  static const _items = [
    AppBottomNavItem(
      label: 'Explorar',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    AppBottomNavItem(
      label: 'Mi espacio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    AppBottomNavItem(
      label: 'Perfil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppDataScope.currentProfile(context),
      builder: (context, _) {
        final isAuthenticated = AppDataScope.currentProfile(
          context,
        ).isAuthenticated;
        if (!isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
            }
          });

          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          body: Stack(
            children: [
              AppBackground(
                animateEntry: true,
                entryDuration: const Duration(milliseconds: 3000),
                contentDelay: const Duration(milliseconds: 2000),
                imageAsset: AppAssets.backgroundGarden,
                imageOpacity: 0.045,
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AppBottomNavBar(
                    items: _items,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
