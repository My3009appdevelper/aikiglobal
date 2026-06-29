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
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/my_image.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _initialized = false;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

  List<AppProfile> _filteredUsers(List<AppProfile> profiles) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return profiles;
    }

    return profiles
        .where((profile) {
          final name = (profile.nombre ?? '').toLowerCase();
          final email = profile.email.toLowerCase();
          return name.contains(query) || email.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppDataScope.adminProfiles(context);

    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final users = _filteredUsers(controller.profiles);
            final hasSearchQuery = _searchController.text.trim().isNotEmpty;

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
                        AppTextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          hintText: 'Buscar por nombre o correo',
                          prefixIcon: Icons.search_rounded,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                          onTapOutside: (_) => _searchFocusNode.unfocus(),
                        ),
                        const SizedBox(height: AppSpacing.md),
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
                                'Revisa tu conexión o permisos de administrador.',
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (users.isEmpty &&
                            !controller.isLoading &&
                            !controller.isSyncing) ...[
                          _AdminUsersMessage(
                            icon: Icons.people_outline_rounded,
                            title: hasSearchQuery
                                ? 'No encontramos usuarios'
                                : 'Aún no hay usuarios para mostrar',
                            body: hasSearchQuery
                                ? 'Intenta buscar por otro nombre o correo.'
                                : 'Aparecerán aquí cuando haya perfiles activos en la base de datos.',
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

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({required this.profile, required this.streakDays});

  final AppProfile profile;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final name = _userDisplayName(profile);
    final email = profile.email;
    final roleLabel = profile.role.trim().toLowerCase() == 'admin'
        ? 'Admin'
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UserAvatar(profile: profile, label: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [_SmallBadge(label: roleLabel)],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: -5,
            right: -5,
            child: _StreakCornerBadge(streakDays: streakDays, active: isActive),
          ),
        ],
      ),
    );
  }
}

class _StreakCornerBadge extends StatelessWidget {
  const _StreakCornerBadge({required this.streakDays, required this.active});

  final int streakDays;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : AppColors.textMuted;

    return Tooltip(
      message: 'Días de racha',
      child: Container(
        constraints: const BoxConstraints(minWidth: 40),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.full,
          boxShadow: AppShadows.soft(Theme.of(context).brightness),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 3),
            Text(
              streakDays.toString(),
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.12);

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
            color: Theme.of(context).colorScheme.primary,
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
  const _UserAvatar({required this.profile, required this.label});

  final AppProfile profile;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: MyImage(
        imagePath: _profilePhotoPath(profile),
        initials: _initialsFor(profile),
        resolveImageUrl: AppDataScope.currentProfile(
          context,
        ).createProfilePhotoSignedUrl,
        size: 48,
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

String? _profilePhotoPath(AppProfile profile) {
  final localPath = profile.fotoPathLocal?.trim();
  if (localPath != null && localPath.isNotEmpty) {
    return localPath;
  }

  final remotePath = profile.fotoPathSupabase?.trim();
  if (remotePath != null && remotePath.isNotEmpty) {
    return remotePath;
  }

  return null;
}

String _initialsFor(AppProfile profile) {
  final source = profile.nombre?.trim().isNotEmpty == true
      ? profile.nombre!.trim()
      : profile.email.trim();
  final parts = source
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return 'A';
  }

  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }

  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
