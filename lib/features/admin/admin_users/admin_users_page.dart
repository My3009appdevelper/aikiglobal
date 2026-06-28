import 'package:flutter/material.dart';

import '../../../core/data/models/app_profile.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_responsive_container.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    AppDataScope.adminProfiles(context).watchProfiles();
  }

  Future<void> _refresh() {
    return AppDataScope.adminProfiles(context).pullFromRemote();
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = AppDataScope.currentProfile(context).profile;
    final controller = AppDataScope.adminProfiles(context);

    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final users = controller.profiles;

            return AppRefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        const AppLogo(width: 148),
                        const SizedBox(height: AppSpacing.lg),
                        _AdminUsersHeader(
                          total: controller.totalUsers,
                          active: controller.activeUsers,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (currentProfile != null) ...[
                          _AdminUsersNotice(
                            title: 'Administrador actual',
                            body: currentProfile.nombre ?? currentProfile.email,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (controller.isLoading || controller.isSyncing) ...[
                          const LinearProgressIndicator(minHeight: 2),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (controller.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _AdminUsersMessage(
                            icon: Icons.warning_amber_rounded,
                            title: 'No se pudo cargar usuarios',
                            body:
                                'Revisa tu conexi\u00f3n o permisos de administrador.',
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (users.isEmpty &&
                            !controller.isLoading &&
                            !controller.isSyncing) ...[
                          _AdminUsersMessage(
                            icon: Icons.people_outline_rounded,
                            title: 'A\u00fan no hay usuarios para mostrar',
                            body:
                                'Aparecer\u00e1n aqu\u00ed cuando haya perfiles activos en la base de datos.',
                          ),
                        ] else ...[
                          ...users.map(
                            (profile) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _AdminUserCard(
                                profile: profile,
                                streakDays: controller.currentStreakForProfile(
                                  profile.uuidProfile,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 130),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminUsersHeader extends StatelessWidget {
  const _AdminUsersHeader({required this.total, required this.active});

  final int total;
  final int active;

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
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Usuarios', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Administra miembros, roles y estado de acceso de la comunidad Aiki.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AdminUsersStat(label: 'Total', value: total),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AdminUsersStat(label: 'Activos', value: active),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminUsersStat extends StatelessWidget {
  const _AdminUsersStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AdminUsersNotice extends StatelessWidget {
  const _AdminUsersNotice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({required this.profile, required this.streakDays});

  final AppProfile profile;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final name = _userDisplayName(profile);
    final email = profile.email;
    final roleLabel = profile.role.trim().toLowerCase() == 'admin'
        ? 'Administrador'
        : 'Usuario';
    final isActive = profile.activo;

    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _UserAvatar(label: name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallBadge(label: roleLabel),
                    _SmallBadge(
                      label: isActive ? 'Activo' : 'Inactivo',
                      muted: !isActive,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'D\u00edas de racha',
            child: Container(
              width: 84,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12)
                    : AppColors.textMuted.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Racha',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streakDays.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    streakDays == 1 ? 'd\u00eda' : 'd\u00edas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = muted
        ? (brightness == Brightness.dark
              ? AppColors.darkSurfaceSoft
              : AppColors.sandLight)
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: muted
                ? (brightness == Brightness.dark
                      ? AppColors.darkTextMuted
                      : AppColors.textSecondary)
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AdminUsersMessage extends StatelessWidget {
  const _AdminUsersMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final initials = label.isNotEmpty
        ? label.characters.first.toUpperCase()
        : '?';

    return Tooltip(
      message: label,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.14),
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _userDisplayName(AppProfile profile) {
  final rawName = profile.nombre?.trim();
  if (rawName != null && rawName.isNotEmpty) {
    return rawName;
  }

  final emailPrefix = profile.email.split('@').first.trim();
  return emailPrefix.isEmpty ? 'Sin nombre' : emailPrefix;
}
