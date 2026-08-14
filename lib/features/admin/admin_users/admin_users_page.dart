import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/data/models/app_profile.dart';
import '../../../core/data/models/app_subscription.dart';
import '../../../core/data/providers/admin_profiles_controller.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/app_load_coordinator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_segmented_tabs.dart';
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
  String _subscriptionFilterCode = 'none';

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
    AppDataScope.adminProfiles(context).watchProfiles(pullRemote: false);
    unawaited(
      AppDataScope.loadCoordinator(
        context,
      ).syncWithRemote(scope: AppLoadScope.adminUsers),
    );
  }

  Future<void> _refresh() {
    return AppDataScope.loadCoordinator(
      context,
    ).syncWithRemote(scope: AppLoadScope.adminUsers);
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

  List<AppProfile> _filterBySubscription(
    List<AppProfile> profiles,
    String filterCode,
    AdminProfilesController controller,
  ) {
    if (filterCode == 'none') {
      return profiles
          .where(
            (profile) => !controller.hasActiveSubscriptionForProfile(
              profile.uuidProfile,
            ),
          )
          .toList(growable: false);
    }

    return profiles
        .where(
          (profile) =>
              controller.subscriptionProductCodeForProfile(
                profile.uuidProfile,
              ) ==
              filterCode,
        )
        .toList(growable: false);
  }

  Future<void> _showSubscriptionDialog(
    BuildContext context,
    AppProfile profile,
    AdminProfilesController controller,
  ) async {
    final subscription = controller.subscriptionForProfile(profile.uuidProfile);
    if (subscription?.hasPremiumAccess == true) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Revocar suscripción'),
          content: Text(
            '¿Quieres revocar la suscripción de ${_userDisplayName(profile)}? '
            'El acceso Premium se desactivará inmediatamente.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontFamilyFallback: AppTypography.fallbackFonts,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                textStyle: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontFamilyFallback: AppTypography.fallbackFonts,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Revocar'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      try {
        await controller.revokeSubscription(subscription!.uuidUserSubscription);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Suscripción revocada.')));
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo revocar la suscripción.')),
        );
      }
      return;
    }

    final products = controller.subscriptionProducts
        .where((product) => product.isAvailable)
        .toList(growable: false);
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay planes activos para asignar.')),
      );
      return;
    }

    final request = await showDialog<_GrantSubscriptionRequest>(
      context: context,
      builder: (dialogContext) => _GrantSubscriptionDialog(
        profile: profile,
        products: products,
        initialProduct: _productForFilter(products),
      ),
    );

    if (request == null || !context.mounted) {
      return;
    }

    try {
      await controller.grantSubscription(
        uuidProfile: profile.uuidProfile,
        product: request.product,
        currentPeriodEnd: request.lifetime
            ? null
            : DateTime.now().toUtc().add(const Duration(days: 30)),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suscripción ${request.product.nombre} asignada.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo asignar la suscripción.')),
      );
    }
  }

  AppSubscriptionProduct _productForFilter(
    List<AppSubscriptionProduct> products,
  ) {
    for (final product in products) {
      if (product.codigo == _subscriptionFilterCode) {
        return product;
      }
    }
    return products.first;
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
            final filterCodes = [
              'none',
              ...controller.subscriptionProducts.map(
                (product) => product.codigo,
              ),
            ];
            final selectedFilter = filterCodes.contains(_subscriptionFilterCode)
                ? _subscriptionFilterCode
                : 'none';
            final users = _filteredUsers(
              _filterBySubscription(
                controller.profiles,
                selectedFilter,
                controller,
              ),
            );
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
                        AdminUsersHeader(
                          total: controller.totalUsers,
                          active: controller.activeUsers,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AdminUsersSearchField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (_) => setState(() {}),
                          onTapOutside: (_) => _searchFocusNode.unfocus(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AdminSubscriptionTabs(
                          key: ValueKey(filterCodes.join('|')),
                          products: controller.subscriptionProducts,
                          selectedCode: selectedFilter,
                          onSelected: (code) {
                            setState(() => _subscriptionFilterCode = code);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (controller.subscriptionError != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const _AdminUsersMessage(
                            icon: Icons.workspace_premium_outlined,
                            title: 'No se pudieron cargar las suscripciones',
                            body:
                                'Verifica que las tablas y permisos de suscripciones estén configurados.',
                          ),
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
                              child: AdminUserCard(
                                profile: profile,
                                streakDays: controller.currentStreakForProfile(
                                  profile.uuidProfile,
                                ),
                                onTap: () => _showSubscriptionDialog(
                                  context,
                                  profile,
                                  controller,
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

class AdminSubscriptionTabs extends StatelessWidget {
  const AdminSubscriptionTabs({
    super.key,
    required this.products,
    required this.selectedCode,
    required this.onSelected,
  });

  final List<AppSubscriptionProduct> products;
  final String selectedCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <({String code, String label})>[
      (code: 'none', label: 'Sin suscripción'),
      ...products.map(
        (product) => (code: product.codigo, label: product.nombre),
      ),
    ];
    final selectedIndex = filters.indexWhere(
      (filter) => filter.code == selectedCode,
    );

    return AppSegmentedTabs(
      labels: [for (final filter in filters) filter.label],
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onChanged: (index) => onSelected(filters[index].code),
    );
  }
}

class _GrantSubscriptionRequest {
  const _GrantSubscriptionRequest({
    required this.product,
    required this.lifetime,
  });

  final AppSubscriptionProduct product;
  final bool lifetime;
}

class _GrantSubscriptionDialog extends StatefulWidget {
  const _GrantSubscriptionDialog({
    required this.profile,
    required this.products,
    required this.initialProduct,
  });

  final AppProfile profile;
  final List<AppSubscriptionProduct> products;
  final AppSubscriptionProduct initialProduct;

  @override
  State<_GrantSubscriptionDialog> createState() =>
      _GrantSubscriptionDialogState();
}

class _GrantSubscriptionDialogState extends State<_GrantSubscriptionDialog> {
  late AppSubscriptionProduct _selectedProduct;
  bool _lifetime = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Dar suscripción'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asigna un plan a ${_userDisplayName(widget.profile)}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.products.length > 1) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedProduct.codigo,
                decoration: const InputDecoration(labelText: 'Plan'),
                items: [
                  for (final product in widget.products)
                    DropdownMenuItem(
                      value: product.codigo,
                      child: Text(product.nombre),
                    ),
                ],
                onChanged: (code) {
                  if (code == null) return;
                  setState(
                    () => _selectedProduct = widget.products.firstWhere(
                      (product) => product.codigo == code,
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: false, label: Text('30 días')),
                  ButtonSegment<bool>(value: true, label: Text('De por vida')),
                ],
                selected: {_lifetime},
                showSelectedIcon: false,
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontFamilyFallback: AppTypography.fallbackFonts,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? scheme.primary
                        : scheme.surface,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? scheme.onPrimary
                        : scheme.onSurface,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: scheme.primary),
                  ),
                ),
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    setState(() => _lifetime = selection.first);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(
            _GrantSubscriptionRequest(
              product: _selectedProduct,
              lifetime: _lifetime,
            ),
          ),
          child: const Text('Dar suscripción'),
        ),
      ],
    );
  }
}

class AdminUsersHeader extends StatelessWidget {
  const AdminUsersHeader({
    super.key,
    required this.total,
    required this.active,
  });

  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usuarios',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: scheme.onSurface,
              fontFamily: AppTypography.displayFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Administra miembros, roles y estado de acceso de la comunidad Aiki.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontFamily: AppTypography.primaryFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AdminUsersStat(label: 'Total', value: total),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminUsersStat(
                  label: 'Activos',
                  value: active,
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminUsersStat extends StatelessWidget {
  const AdminUsersStat({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final int value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = highlight ? scheme.primary : scheme.onSurface;
    final weight = highlight ? FontWeight.w700 : FontWeight.w500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontFamily: AppTypography.displayFont,
            fontFamilyFallback: AppTypography.fallbackFonts,
            fontWeight: weight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontFamily: AppTypography.displayFont,
            fontFamilyFallback: AppTypography.fallbackFonts,
            fontWeight: weight,
          ),
        ),
      ],
    );
  }
}

class AdminUsersSearchField extends StatelessWidget {
  const AdminUsersSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onTapOutside,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final TapRegionCallback onTapOutside;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: 'Buscar por nombre o correo',
      prefixIcon: Icons.search_rounded,
      textInputAction: TextInputAction.search,
      fillColor: Theme.of(context).colorScheme.surface,
      onChanged: onChanged,
      onTapOutside: onTapOutside,
    );
  }
}

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({
    super.key,
    required this.profile,
    required this.streakDays,
    this.onTap,
  });

  final AppProfile profile;
  final int streakDays;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = _userDisplayName(profile);
    final email = profile.email;
    final roleLabel = profile.role.trim().toLowerCase() == 'admin'
        ? 'Admin'
        : 'Usuario';

    final brightness = Theme.of(context).brightness;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
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
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontFamily: AppTypography.displayFont,
                        fontFamilyFallback: AppTypography.fallbackFonts,
                      ),
                    ),
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
                      children: [UserTypeChip(label: roleLabel)],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: -5,
            right: -5,
            child: StreakCornerBadge(streakDays: streakDays),
          ),
        ],
      ),
    );

    return AppInteractive(
      onTap: onTap,
      tooltip: onTap == null ? null : 'Administrar suscripción',
      borderRadius: AppRadius.large,
      hoverScale: 1.01,
      child: card,
    );
  }
}

class StreakCornerBadge extends StatelessWidget {
  const StreakCornerBadge({super.key, required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Días de progreso',
      child: Container(
        constraints: const BoxConstraints(minWidth: 40),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: AppRadius.full,
          boxShadow: AppShadows.soft(Theme.of(context).brightness),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 14,
              color: scheme.onPrimary,
            ),
            const SizedBox(width: 3),
            Text(
              streakDays.toString(),
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onPrimary,
                fontFamily: AppTypography.displayFont,
                fontFamilyFallback: AppTypography.fallbackFonts,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserTypeChip extends StatelessWidget {
  const UserTypeChip({super.key, required this.label});

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
            fontFamily: AppTypography.displayFont,
            fontFamilyFallback: AppTypography.fallbackFonts,
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
        : AppColors.background;

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
    final imagePath = _profilePhotoPath(profile);

    return Tooltip(
      message: label,
      child: MyImage(
        imagePath: imagePath,
        initials: _initialsFor(profile),
        resolveImageUrl: imagePath == null
            ? null
            : AppDataScope.currentProfile(context).createProfilePhotoSignedUrl,
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
