import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_progress_card.dart';

class WellnessProgressCard extends StatelessWidget {
  const WellnessProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return AppProgressCard(
      title: 'Avances de bienestar',
      progress: 0.72,
      children: [
        _MetricBar(
          icon: Icons.bolt_outlined,
          label: 'Energía',
          value: 0.78,
          color: primary,
        ),
        _MetricBar(
          icon: Icons.spa_outlined,
          label: 'Calma',
          value: 0.86,
          color: secondary,
        ),
        _MetricBar(
          icon: Icons.dark_mode_outlined,
          label: 'Descanso',
          value: 0.66,
          color: primary,
        ),
        _MetricBar(
          icon: Icons.favorite_border_rounded,
          label: 'Conexión',
          value: 0.58,
          color: secondary,
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final track = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    color: color,
                    backgroundColor: track,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
