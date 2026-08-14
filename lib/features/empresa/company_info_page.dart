import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_company_info.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_responsive_container.dart';

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key});

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    final controller = AppDataScope.companyInfo(context);
    controller.watch();
    unawaited(controller.syncWithRemote());
    unawaited(
      precacheImage(const AssetImage(AppAssets.companyMission), context),
    );
    unawaited(
      precacheImage(const AssetImage(AppAssets.companyVision), context),
    );
    unawaited(
      precacheImage(const AssetImage(AppAssets.companyPhilosophy), context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppDataScope.companyInfo(context);

    return Scaffold(
      body: AppBackground(
        imageAsset: AppAssets.backgroundArchitecture,
        imageOpacity: 0.055,
        child: SafeArea(
          bottom: false,
          child: AppResponsiveContainer(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final info = controller.item;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _CompanyHeader(),
                            const SizedBox(height: AppSpacing.xl),
                            CompanyInfoContent(
                              info: info,
                              resolveImageUrl: controller.resolveInfoImageUrl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyInfoContent extends StatefulWidget {
  const CompanyInfoContent({
    super.key,
    required this.info,
    required this.resolveImageUrl,
  });

  final AppCompanyInfo info;
  final Future<String?> Function(String imagePath) resolveImageUrl;

  @override
  State<CompanyInfoContent> createState() => _CompanyInfoContentState();
}

class _CompanyInfoContentState extends State<CompanyInfoContent> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompanyInfoTabs(
          selectedIndex: _selectedIndex,
          onChanged: (index) {
            if (_selectedIndex == index) {
              return;
            }
            setState(() => _selectedIndex = index);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _selectedIndex == 0
              ? _CompanyFoundersTab(
                  key: const ValueKey('fundadores'),
                  info: info,
                  resolveImageUrl: widget.resolveImageUrl,
                )
              : _CompanyAboutTab(
                  key: const ValueKey('quienes-somos'),
                  info: info,
                ),
        ),
      ],
    );
  }
}

class _CompanyInfoTabs extends StatelessWidget {
  const _CompanyInfoTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.86),
        borderRadius: AppRadius.full,
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.darkStroke
              : AppColors.stroke,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CompanyInfoTabButton(
              label: 'Fundadores',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _CompanyInfoTabButton(
              label: '¿Quiénes somos?',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoTabButton extends StatelessWidget {
  const _CompanyInfoTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedColor = scheme.primary;
    final textColor = selected ? scheme.onPrimary : scheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      child: AppInteractive(
        borderRadius: AppRadius.full,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: AppRadius.full,
            border: Border.all(
              color: selected
                  ? selectedColor
                  : scheme.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textColor,
              fontFamily: AppTypography.displayFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyFoundersTab extends StatelessWidget {
  const _CompanyFoundersTab({
    super.key,
    required this.info,
    required this.resolveImageUrl,
  });

  final AppCompanyInfo info;
  final Future<String?> Function(String imagePath) resolveImageUrl;

  @override
  Widget build(BuildContext context) {
    if (!info.hasMensajeFundadores) {
      return _CompanyPlainSectionCard(
        title: 'Fundadores',
        body: info.textoEntrada,
      );
    }

    return _CompanyFoundersSectionCard(
      title: info.mensajeFundadoresTitulo,
      body: info.mensajeFundadoresTexto,
      imagePaths: info.mensajeFundadoresImagePaths,
      resolveImageUrl: resolveImageUrl,
    );
  }
}

class _CompanyAboutTab extends StatelessWidget {
  const _CompanyAboutTab({super.key, required this.info});

  final AppCompanyInfo info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompanyIntro(text: info.textoEntrada),
        const SizedBox(height: AppSpacing.lg),
        _CompanyPlainSectionCard(
          title: '¿Quiénes somos?',
          body: info.quienesSomos,
        ),
        const SizedBox(height: AppSpacing.xl),
        _CompanyFeaturedSectionCard(
          title: '¿Y qué significa Aiki?',
          body: info.significadoAiki,
          icon: Icons.self_improvement_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        _CompanyFeaturedSectionCard(
          title: 'MISIÓN',
          body: info.mision,
          imageAsset: AppAssets.companyMission,
        ),
        const SizedBox(height: AppSpacing.md),
        _CompanyFeaturedSectionCard(
          title: 'VISIÓN',
          body: info.vision,
          imageAsset: AppAssets.companyVision,
        ),
        const SizedBox(height: AppSpacing.md),
        _CompanyFeaturedSectionCard(
          title: 'FILOSOFÍA',
          body: info.filosofia,
          imageAsset: AppAssets.companyPhilosophy,
        ),
      ],
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(onTap: () => Navigator.of(context).pop()),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: AppLogo(width: 132)),
        const SizedBox(width: AppSpacing.md),
        const SizedBox(width: 56),
      ],
    );
  }
}

class _CompanyIntro extends StatelessWidget {
  const _CompanyIntro({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.darkStroke
              : AppColors.stroke,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFamily: AppTypography.displayFont,
          fontFamilyFallback: AppTypography.fallbackFonts,
          height: 1.42,
        ),
      ),
    );
  }
}

class _CompanyPlainSectionCard extends StatelessWidget {
  const _CompanyPlainSectionCard({required this.title, required this.body});

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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.darkStroke
              : AppColors.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: _companyTitleStyle(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.42),
          ),
        ],
      ),
    );
  }
}

class _CompanyFoundersSectionCard extends StatelessWidget {
  const _CompanyFoundersSectionCard({
    required this.title,
    required this.body,
    required this.imagePaths,
    required this.resolveImageUrl,
  });

  final String title;
  final String body;
  final List<String> imagePaths;
  final Future<String?> Function(String imagePath) resolveImageUrl;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;
    final cleanTitle = title.trim();
    final cleanBody = body.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.darkStroke
              : AppColors.stroke,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (cleanTitle.isNotEmpty) ...[
            Text(
              cleanTitle,
              textAlign: TextAlign.center,
              style: _companyTitleStyle(context),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (cleanBody.isNotEmpty)
            Text(
              cleanBody,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          if (imagePaths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _CompanyFoundersGallery(
              imagePaths: imagePaths,
              resolveImageUrl: resolveImageUrl,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanyFoundersGallery extends StatelessWidget {
  const _CompanyFoundersGallery({
    required this.imagePaths,
    required this.resolveImageUrl,
  });

  final List<String> imagePaths;
  final Future<String?> Function(String imagePath) resolveImageUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSingle = imagePaths.length == 1;
        final isWide = constraints.maxWidth >= 620;
        final tileWidth = isSingle
            ? constraints.maxWidth
            : isWide
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: [
            for (final imagePath in imagePaths)
              SizedBox(
                width: tileWidth,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: AppRadius.medium,
                    child: AppCoverImage(
                      imagePath: imagePath,
                      resolveImageUrl: resolveImageUrl,
                      fallback: _founderImageFallback(context),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _founderImageFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _CompanyFeaturedSectionCard extends StatelessWidget {
  const _CompanyFeaturedSectionCard({
    required this.title,
    required this.body,
    this.icon,
    this.imageAsset,
  });

  final String title;
  final String body;
  final IconData? icon;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;
    const iconSize = 74.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: iconSize / 2),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 52, 22, 24),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.9),
              borderRadius: AppRadius.large,
              border: Border.all(
                color: brightness == Brightness.dark
                    ? AppColors.darkStroke
                    : AppColors.stroke,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: _companyTitleStyle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.42),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: brightness == Brightness.dark
                  ? AppColors.darkStroke
                  : AppColors.stroke,
              width: 2,
            ),
            boxShadow: AppShadows.soft(brightness),
          ),
          child: Center(
            child: Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: _CompanySectionVisual(
                icon: icon,
                imageAsset: imageAsset,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanySectionVisual extends StatelessWidget {
  const _CompanySectionVisual({
    required this.color,
    this.icon,
    this.imageAsset,
  });

  final Color color;
  final IconData? icon;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        color: color,
        colorBlendMode: BlendMode.srcIn,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Icon(icon ?? Icons.spa_outlined, color: color, size: 34);
        },
      );
    }

    return Icon(icon ?? Icons.spa_outlined, color: color, size: 34);
  }
}

TextStyle? _companyTitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleLarge?.copyWith(
    fontFamily: AppTypography.displayFont,
    fontFamilyFallback: AppTypography.fallbackFonts,
    fontWeight: FontWeight.w500,
    height: 1.16,
  );
}
