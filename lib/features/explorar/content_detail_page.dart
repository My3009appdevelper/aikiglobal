import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_primary_button.dart';
import 'lesson_player_page.dart';
import 'models/content_item.dart';

class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final isCourse = item.lessons != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _DetailHero(item: item),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 128),
                      child: Column(
                        children: [
                          Text(
                            item.description ??
                                'Un espacio para reconectar con tu cuerpo, tu mente y tu energía interior.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 28),
                          _StatsRow(item: item),
                          const SizedBox(height: 28),
                          _AboutCard(item: item),
                          if (isCourse) ...[
                            const SizedBox(height: 18),
                            _LessonList(item: item),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 26,
            child: AppPrimaryButton(
              label: isCourse ? 'Comenzar curso' : 'Reproducir ahora',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonPlayerPage(item: item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item.imageAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: 0.18),
                  AppColors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _HeroIcon(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Regresar',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      const _HeroIcon(
                        icon: Icons.bookmark_border_rounded,
                        selectedIcon: Icons.bookmark_rounded,
                        tooltip: 'Guardar contenido',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.type.toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppColors.sand),
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

class _HeroIcon extends StatefulWidget {
  const _HeroIcon({
    required this.icon,
    required this.tooltip,
    this.selectedIcon,
    this.onTap,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  State<_HeroIcon> createState() => _HeroIconState();
}

class _HeroIconState extends State<_HeroIcon> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final icon = _selected ? widget.selectedIcon ?? widget.icon : widget.icon;

    return AppInteractive(
      tooltip: _selected ? 'Guardado' : widget.tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1.08,
      pressedScale: 0.9,
      onTap: () {
        widget.onTap?.call();
        if (widget.selectedIcon != null) {
          setState(() => _selected = !_selected);
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(icon, key: ValueKey(icon), color: AppColors.white),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(icon: Icons.spa_outlined, label: item.type),
        ),
        Expanded(
          child: _Stat(icon: Icons.schedule_rounded, label: item.duration),
        ),
        Expanded(
          child: _Stat(
            icon: Icons.signal_cellular_alt_rounded,
            label: item.lessons == null
                ? 'Audio guía'
                : '${item.lessons} clases',
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final circleColor = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final iconColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: circleColor,
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final iconSurface = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconSurface,
            child: Icon(
              Icons.local_florist_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre este contenido',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  item.description ??
                      'Diseñado para acompañarte con calma, presencia y claridad.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final lessons = [
      'Bienvenida e intención',
      'Respiración consciente',
      'Soltar para descansar',
    ];

    return Column(
      children: [
        for (var i = 0; i < lessons.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: AppRadius.small,
              child: Image.asset(
                item.imageAsset,
                width: 72,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(lessons[i]),
            subtitle: Text('${8 + i * 4}:30 min'),
            trailing: const _DownloadActionButton(),
          ),
      ],
    );
  }
}

class _DownloadActionButton extends StatefulWidget {
  const _DownloadActionButton();

  @override
  State<_DownloadActionButton> createState() => _DownloadActionButtonState();
}

class _DownloadActionButtonState extends State<_DownloadActionButton> {
  bool _downloaded = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return AppInteractive(
      tooltip: _downloaded ? 'Descargado' : 'Descargar lección',
      borderRadius: AppRadius.full,
      hoverScale: 1.12,
      pressedScale: 0.88,
      onTap: () => setState(() => _downloaded = !_downloaded),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          _downloaded ? Icons.check_circle_rounded : Icons.download_outlined,
          key: ValueKey(_downloaded),
          color: _downloaded ? color : null,
        ),
      ),
    );
  }
}
