import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_interactive.dart';

enum QuickCategoryType { meditations, audios, sounds, favorites }

class QuickCategoryRow extends StatelessWidget {
  const QuickCategoryRow({
    super.key,
    required this.meditationCount,
    required this.audioCount,
    required this.soundCount,
    required this.favoriteCount,
    this.selectedType,
    this.onSelected,
  });

  final int meditationCount;
  final int audioCount;
  final int soundCount;
  final int favoriteCount;
  final QuickCategoryType? selectedType;
  final ValueChanged<QuickCategoryType>? onSelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.12)),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final cardWidth = (constraints.maxWidth - spacing) / 2;
          final cardHeight = cardWidth < 150 ? 150.0 : 158.0;
          final gridHeight = cardHeight * 2 + spacing;

          return SizedBox(
            height: gridHeight,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: cardWidth / cardHeight,
              children: [
                _QuickActionCard(
                  type: QuickCategoryType.meditations,
                  icon: Icons.self_improvement_rounded,
                  label: 'Meditaciones',
                  caption: _countLabel(
                    meditationCount,
                    'práctica',
                    'prácticas',
                  ),
                  selected: selectedType == QuickCategoryType.meditations,
                  onTap: () => onSelected?.call(QuickCategoryType.meditations),
                ),
                _QuickActionCard(
                  type: QuickCategoryType.favorites,
                  icon: Icons.bookmark_border_rounded,
                  label: 'Favoritos',
                  caption: _countLabel(favoriteCount, 'guardado', 'guardados'),
                  selected: selectedType == QuickCategoryType.favorites,
                  onTap: () => onSelected?.call(QuickCategoryType.favorites),
                ),
                _QuickActionCard(
                  type: QuickCategoryType.audios,
                  icon: Icons.headphones_rounded,
                  label: 'Audios',
                  caption: _countLabel(audioCount, 'audio', 'audios'),
                  selected: selectedType == QuickCategoryType.audios,
                  onTap: () => onSelected?.call(QuickCategoryType.audios),
                ),
                _QuickActionCard(
                  type: QuickCategoryType.sounds,
                  icon: Icons.graphic_eq_rounded,
                  label: 'Sonidos',
                  caption: _countLabel(soundCount, 'sonido', 'sonidos'),
                  selected: selectedType == QuickCategoryType.sounds,
                  onTap: () => onSelected?.call(QuickCategoryType.sounds),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _countLabel(int count, String singular, String plural) {
    final label = count == 1 ? singular : plural;
    return '$count $label';
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.type,
    required this.icon,
    required this.label,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final QuickCategoryType type;
  final IconData icon;
  final String label;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppInteractive(
      tooltip: 'Abrir $label',
      borderRadius: AppRadius.medium,
      hoverScale: 1.015,
      pressedScale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(
            color: selected
                ? scheme.secondary
                : scheme.onSurface.withValues(alpha: 0.13),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            _QuickActionIllustration(type: type, icon: icon),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: AppTypography.displayFont,
                    fontWeight: FontWeight.w300,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  caption,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 42 : 28,
              height: 2,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: AppRadius.full,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionIllustration extends StatelessWidget {
  const _QuickActionIllustration({required this.type, required this.icon});

  final QuickCategoryType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 74,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _QuickActionPainter(
                type: type,
                gold: scheme.primary,
                wine: scheme.secondary,
                foreground: scheme.onSurface,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: scheme.onPrimary, size: 24),
          ),
        ],
      ),
    );
  }
}

class _QuickActionPainter extends CustomPainter {
  const _QuickActionPainter({
    required this.type,
    required this.gold,
    required this.wine,
    required this.foreground,
  });

  final QuickCategoryType type;
  final Color gold;
  final Color wine;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final haloPaint = Paint()
      ..color = gold.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = foreground.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()
      ..color = wine.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, size.height * 0.36, haloPaint);

    switch (type) {
      case QuickCategoryType.meditations:
        _paintMeditation(canvas, size, linePaint, accentPaint);
      case QuickCategoryType.audios:
        _paintLandscape(canvas, size, linePaint);
      case QuickCategoryType.sounds:
        _paintZen(canvas, size, linePaint, accentPaint);
      case QuickCategoryType.favorites:
        _paintWreath(canvas, size, linePaint, accentPaint);
    }
  }

  void _paintMeditation(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint accentPaint,
  ) {
    final y = size.height * 0.76;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.5),
        width: size.width * 0.72,
        height: size.height * 0.72,
      ),
      3.55,
      2.95,
      false,
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, y),
      Offset(size.width * 0.82, y),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, y - 8),
      Offset(size.width * 0.46, y),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, y - 8),
      Offset(size.width * 0.54, y),
      linePaint,
    );
  }

  void _paintLandscape(Canvas canvas, Size size, Paint linePaint) {
    final base = size.height * 0.76;
    final path = Path()
      ..moveTo(size.width * 0.12, base)
      ..quadraticBezierTo(size.width * 0.28, base - 18, size.width * 0.44, base)
      ..quadraticBezierTo(
        size.width * 0.62,
        base - 24,
        size.width * 0.88,
        base,
      );
    canvas.drawPath(path, linePaint);
  }

  void _paintZen(Canvas canvas, Size size, Paint linePaint, Paint accentPaint) {
    final center = Offset(size.width / 2, size.height * 0.74);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * (0.42 + i * 0.18),
          height: size.height * (0.08 + i * 0.035),
        ),
        i.isEven ? linePaint : accentPaint,
      );
    }
  }

  void _paintWreath(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint accentPaint,
  ) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.52),
      width: size.width * 0.66,
      height: size.height * 0.64,
    );
    canvas.drawArc(rect, 2.3, 1.35, false, linePaint);
    canvas.drawArc(rect, 5.75, 1.35, false, linePaint);
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.34),
      1.6,
      accentPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.34),
      1.6,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QuickActionPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.gold != gold ||
        oldDelegate.wine != wine ||
        oldDelegate.foreground != foreground;
  }
}
