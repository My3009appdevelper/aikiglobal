import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_responsive_container.dart';
import 'widgets/settings_section.dart';
import 'widgets/subscription_card.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final profileController = AppDataScope.currentProfile(context);

    try {
      await profileController.signOut();
    } catch (_) {
      if (!context.mounted) return;
    }

    if (!context.mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const _ProfileHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  const SubscriptionCard(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Configuración',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsSection(onLogout: () => _logout(context)),
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(children: [AppLogo(width: 148), Spacer()]);
  }
}
